import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:sqflite/sqflite.dart';

class GoogleDriveService {
  static final GoogleDriveService instance = GoogleDriveService._();
  GoogleDriveService._();

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _isInitialized = false;

  Future<void> _initIfNeeded() async {
    if (!_isInitialized) {
      await _googleSignIn.initialize();
      _isInitialized = true;
    }
  }

  GoogleSignInAccount? _currentUser;
  drive.DriveApi? _driveApi;

  // Folder name in Google Drive where backups are stored
  static const String _backupFolderName = 'InternetBillingBackups';
  String? _backupFolderId;

  /// Check if user is signed in
  bool get isSignedIn => _currentUser != null;

  /// Get current user email
  String? get userEmail => _currentUser?.email;

  /// Initialize and sign in to Google
  Future<bool> signIn() async {
    try {
      await _initIfNeeded();
      final account = await _googleSignIn.authenticate(
        scopeHint: [drive.DriveApi.driveFileScope],
      );
      _currentUser = account;
      
      // Get authenticated HTTP client
      final authz = await _googleSignIn.authorizationClient.authorizeScopes([drive.DriveApi.driveFileScope]);
      final authClient = authz.authClient(scopes: [drive.DriveApi.driveFileScope]);

      _driveApi = drive.DriveApi(authClient);
      
      // Ensure backup folder exists
      await _ensureBackupFolder();
      
      return true;
    } catch (e) {
      print('Error signing in: $e');
      return false;
    }
  }

  /// Sign out from Google
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _currentUser = null;
    _driveApi = null;
    _backupFolderId = null;
  }

  /// Try to sign in silently (if previously signed in)
  Future<bool> signInSilently() async {
    try {
      await _initIfNeeded();
      final future = _googleSignIn.attemptLightweightAuthentication();
      if (future == null) return false;
      
      final account = await future;
      if (account == null) {
        return false;
      }

      _currentUser = account;
      
      final authz = await _googleSignIn.authorizationClient.authorizationForScopes([drive.DriveApi.driveFileScope]);
      if (authz == null) {
        return false;
      }
      
      final authClient = authz.authClient(scopes: [drive.DriveApi.driveFileScope]);

      _driveApi = drive.DriveApi(authClient);
      await _ensureBackupFolder();
      
      return true;
    } catch (e) {
      print('Error signing in silently: $e');
      return false;
    }
  }

  /// Ensure backup folder exists in Google Drive
  Future<void> _ensureBackupFolder() async {
    if (_driveApi == null) return;

    try {
      // Search for existing folder
      final fileList = await _driveApi!.files.list(
        q: "name='$_backupFolderName' and mimeType='application/vnd.google-apps.folder' and trashed=false",
        spaces: 'drive',
      );

      if (fileList.files != null && fileList.files!.isNotEmpty) {
        _backupFolderId = fileList.files!.first.id;
      } else {
        // Create folder
        final folder = drive.File()
          ..name = _backupFolderName
          ..mimeType = 'application/vnd.google-apps.folder';

        final createdFolder = await _driveApi!.files.create(folder);
        _backupFolderId = createdFolder.id;
      }
    } catch (e) {
      print('Error ensuring backup folder: $e');
      throw Exception('Failed to create backup folder: $e');
    }
  }

  /// Upload database file to Google Drive
  Future<String?> uploadBackup(String dbPath) async {
    if (_driveApi == null || _backupFolderId == null) {
      throw Exception('Not signed in to Google Drive');
    }

    try {
      final dbFile = File(dbPath);
      if (!await dbFile.exists()) {
        throw Exception('Database file not found');
      }

      final fileName = 'backup_${DateTime.now().millisecondsSinceEpoch}.db';
      
      final driveFile = drive.File()
        ..name = fileName
        ..parents = [_backupFolderId!]
        ..description = 'Internet Billing Database Backup - ${DateTime.now().toIso8601String()}';

      final media = drive.Media(dbFile.openRead(), await dbFile.length());
      
      final uploadedFile = await _driveApi!.files.create(
        driveFile,
        uploadMedia: media,
      );

      return uploadedFile.id;
    } catch (e) {
      print('Error uploading backup: $e');
      throw Exception('Failed to upload backup: $e');
    }
  }

  /// List all backups from Google Drive
  Future<List<BackupFile>> listBackups() async {
    if (_driveApi == null || _backupFolderId == null) {
      throw Exception('Not signed in to Google Drive');
    }

    try {
      final fileList = await _driveApi!.files.list(
        q: "'$_backupFolderId' in parents and trashed=false",
        orderBy: 'createdTime desc',
        spaces: 'drive',
        $fields: 'files(id, name, size, createdTime, modifiedTime)',
      );

      if (fileList.files == null || fileList.files!.isEmpty) {
        return [];
      }

      return fileList.files!.map((file) {
        return BackupFile(
          id: file.id!,
          name: file.name!,
          size: file.size != null ? int.parse(file.size!) : 0,
          createdTime: file.createdTime ?? DateTime.now(),
          modifiedTime: file.modifiedTime ?? DateTime.now(),
        );
      }).toList();
    } catch (e) {
      print('Error listing backups: $e');
      throw Exception('Failed to list backups: $e');
    }
  }

  /// Download and restore backup from Google Drive
  Future<bool> downloadAndRestoreBackup(String fileId, String dbPath) async {
    if (_driveApi == null) {
      throw Exception('Not signed in to Google Drive');
    }

    try {
      // Get database instance and close it
      final db = await openDatabase(dbPath);
      await db.close();

      // Download file
      final media = await _driveApi!.files.get(
        fileId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      // Create temporary file
      final tempFile = File('$dbPath.temp');
      final sink = tempFile.openWrite();

      await for (var data in media.stream) {
        sink.add(data);
      }
      await sink.close();

      // Replace current database with downloaded one
      final dbFile = File(dbPath);
      if (await dbFile.exists()) {
        await dbFile.delete();
      }
      await tempFile.rename(dbPath);

      // Reopen database to ensure it's ready
      await openDatabase(dbPath);

      return true;
    } catch (e) {
      print('Error downloading backup: $e');
      throw Exception('Failed to download backup: $e');
    }
  }

  /// Delete backup from Google Drive
  Future<bool> deleteBackup(String fileId) async {
    if (_driveApi == null) {
      throw Exception('Not signed in to Google Drive');
    }

    try {
      await _driveApi!.files.delete(fileId);
      return true;
    } catch (e) {
      print('Error deleting backup: $e');
      throw Exception('Failed to delete backup: $e');
    }
  }
}

/// Model class for backup file information
class BackupFile {
  final String id;
  final String name;
  final int size;
  final DateTime createdTime;
  final DateTime modifiedTime;

  BackupFile({
    required this.id,
    required this.name,
    required this.size,
    required this.createdTime,
    required this.modifiedTime,
  });

  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

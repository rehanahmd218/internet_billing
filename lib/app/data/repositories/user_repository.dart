import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:wifi_billing/app/core/constants/app_constants.dart';
import 'package:wifi_billing/app/core/utils/firebase_utils.dart';
import 'package:wifi_billing/app/core/utils/logger_utils.dart';
import 'package:wifi_billing/app/data/models/user_model.dart';
import 'package:wifi_billing/app/data/services/firestore_service.dart';

class UserRepository {
  final FirestoreService _firestoreService = FirestoreService();
  final String _collection = AppConstants.usersCollection;

  // Create user
  Future<String?> createUser(UserModel user, {RxBool? loader}) async {
    AppLogger.info('Creating user: ${user.name}');
    return runFirebaseSafely(() async {
      final docId = await _firestoreService.create(_collection, user.toJson());
      AppLogger.info('User created successfully');
      return docId;
    }, loader: loader);
  }

  // Get user by ID
  Future<UserModel?> getUserById(String userId, {RxBool? loader}) async {
    AppLogger.info('Getting user by ID: $userId');
    return runFirebaseSafely(() async {
      final doc = await _firestoreService.read(_collection, userId);
      if (doc != null && doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    }, loader: loader);
  }

  // Get user by UID
  Future<UserModel?> getUserByUid(String uid, {RxBool? loader}) async {
    AppLogger.info('Getting user by UID: $uid');
    return runFirebaseSafely(() async {
      final docs = await _firestoreService.query(
        _collection,
        [QueryCondition(field: 'uid', isEqualTo: uid)],
        limit: 1,
      );
      if (docs.isNotEmpty) {
        return UserModel.fromFirestore(docs.first);
      }
      return null;
    }, loader: loader);
  }

  // Update user
  Future<void> updateUser(String userId, UserModel user, {RxBool? loader}) async {
    AppLogger.info('Updating user: $userId');
    return runFirebaseSafely(() async {
      final data = user.toJson();
      data['updatedAt'] = Timestamp.now();
      await _firestoreService.update(_collection, userId, data);
      AppLogger.info('User updated successfully');
    }, loader: loader);
  }

  // Delete user
  Future<void> deleteUser(String userId, {RxBool? loader}) async {
    AppLogger.info('Deleting user: $userId');
    return runFirebaseSafely(() async {
      await _firestoreService.delete(_collection, userId);
      AppLogger.info('User deleted successfully');
    }, loader: loader);
  }

  // Get all users
  Future<List<UserModel>> getAllUsers({RxBool? loader}) async {
    AppLogger.info('Getting all users');
    return runFirebaseSafely(() async {
      final docs = await _firestoreService.getAll(_collection);
      return docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    }, loader: loader);
  }

  // Stream all users
  Stream<List<UserModel>> streamAllUsers() {
    try {
      AppLogger.info('Streaming all users');
      return _firestoreService.streamAll(_collection).map(
            (docs) => docs.map((doc) => UserModel.fromFirestore(doc)).toList(),
          );
    } catch (e, stackTrace) {
      AppLogger.error('Error streaming users', e, stackTrace);
      rethrow;
    }
  }

  // Get users by status
  Future<List<UserModel>> getUsersByStatus(String status, {RxBool? loader}) async {
    AppLogger.info('Getting users by status: $status');
    return runFirebaseSafely(() async {
      final docs = await _firestoreService.query(
        _collection,
        [QueryCondition(field: 'status', isEqualTo: status)],
        orderBy: 'name',
      );
      return docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    }, loader: loader);
  }

  // Search users by name, phone, or UID
  Future<List<UserModel>> searchUsers(String query, {RxBool? loader}) async {
    AppLogger.info('Searching users with query: $query');
    return runFirebaseSafely(() async {
      final allUsers = await _firestoreService.getAll(_collection);
      
      final lowerQuery = query.toLowerCase();
      return allUsers.where((doc) {
        final user = UserModel.fromFirestore(doc);
        return user.name.toLowerCase().contains(lowerQuery) ||
            user.phone.contains(query) ||
            user.uid.toLowerCase().contains(lowerQuery);
      }).map((doc) => UserModel.fromFirestore(doc)).toList();
    }, loader: loader);
  }

  // Check if UID exists
  Future<bool> isUidExists(String uid, {RxBool? loader}) async {
    return runFirebaseSafely(() async {
      final user = await getUserByUid(uid);
      return user != null;
    }, loader: loader);
  }

  // Get user count
  Future<int> getUserCount({RxBool? loader}) async {
    return runFirebaseSafely(() async {
      final users = await _firestoreService.getAll(_collection);
      return users.length;
    }, loader: loader);
  }

  // Get active user count
  Future<int> getActiveUserCount({RxBool? loader}) async {
    return runFirebaseSafely(() async {
      final docs = await _firestoreService.query(
        _collection,
        [QueryCondition(field: 'status', isEqualTo: AppConstants.statusActive)],
      );
      return docs.length;
    }, loader: loader);
  }
}

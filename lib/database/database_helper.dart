import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';
import '../models/bill_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('internet_billing.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 4, // Incremented version to add 'internet_speed' field
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Drop existing tables and recreate if version changes
    if (oldVersion < newVersion) {
      // For version 4, we need to add 'internet_speed' field
      if (oldVersion < 4) {
        try {
          final usersColumns = await db.rawQuery('PRAGMA table_info(users)');
          final hasInternetSpeed = usersColumns.any((col) => col['name'] == 'internet_speed');
          
          if (!hasInternetSpeed) {
            // Add 'internet_speed' column with default value 0
            await db.execute('ALTER TABLE users ADD COLUMN internet_speed INTEGER NOT NULL DEFAULT 0');
          }
        } catch (e) {
          // If migration fails, recreate tables
          await db.execute('DROP TABLE IF EXISTS bills');
          await db.execute('DROP TABLE IF EXISTS users');
          await _createDB(db, newVersion);
        }
      }
      
      // For version 3, we need to add 'no' field
      if (oldVersion < 3) {
        try {
          // Check if 'no' column exists
          final usersColumns = await db.rawQuery('PRAGMA table_info(users)');
          final hasNo = usersColumns.any((col) => col['name'] == 'no');
          
          if (!hasNo) {
            // Add 'no' column with default values
            await db.execute('ALTER TABLE users ADD COLUMN no INTEGER NOT NULL DEFAULT 0');
            // Update existing records with sequential numbers
            final users = await db.query('users', orderBy: 'id');
            for (int i = 0; i < users.length; i++) {
              await db.update('users', {'no': i + 1}, where: 'id = ?', whereArgs: [users[i]['id']]);
            }
          }
        } catch (e) {
          // If migration fails, recreate tables
          await db.execute('DROP TABLE IF EXISTS bills');
          await db.execute('DROP TABLE IF EXISTS users');
          await _createDB(db, newVersion);
        }
      }
      
      // If major version change (v1 to v2), recreate tables
      if (oldVersion < 2) {
        await db.execute('DROP TABLE IF EXISTS bills');
        await db.execute('DROP TABLE IF EXISTS users');
        await _createDB(db, newVersion);
      }
    }
  }

  Future<void> _verifyTables(Database db) async {
    try {
      // Check if bills table has user_uid column
      final billsColumns = await db.rawQuery('PRAGMA table_info(bills)');
      final hasUserUid = billsColumns.any((col) => col['name'] == 'user_uid');
      
      final hasNo = billsColumns.any((col) => col['name'] == 'no');
      
      if (!hasUserUid || !hasNo) {
        // Recreate tables if schema is incorrect
        await db.execute('DROP TABLE IF EXISTS bills');
        await db.execute('DROP TABLE IF EXISTS users');
        await _createDB(db, 4);
      }
    } catch (e) {
      // If tables don't exist, create them
      await _createDB(db, 3);
    }
  }
  
  // Method to reset database (for debugging)
  Future<void> resetDatabase() async {
    final db = await database;
    await db.execute('DROP TABLE IF EXISTS bills');
    await db.execute('DROP TABLE IF EXISTS users');
    await _createDB(db, 4);
  }

  Future<void> _createDB(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        no INTEGER NOT NULL,
        uid TEXT UNIQUE NOT NULL,
        name TEXT NOT NULL,
        mobile_number TEXT NOT NULL,
        address TEXT NOT NULL,
        internet_speed INTEGER NOT NULL DEFAULT 0,
        created_date TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // Bills table
    await db.execute('''
      CREATE TABLE bills (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_uid TEXT NOT NULL,
        year INTEGER NOT NULL,
        month INTEGER NOT NULL,
        amount REAL NOT NULL DEFAULT 0,
        bill_date TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        UNIQUE(user_uid, year, month),
        FOREIGN KEY (user_uid) REFERENCES users(uid) ON DELETE CASCADE
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_bills_user_uid ON bills(user_uid)');
    await db.execute('CREATE INDEX idx_bills_year_month ON bills(year, month)');
  }

  // User CRUD operations
  Future<int> insertUser(UserModel user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<void> insertMultipleUsers(List<UserModel> users) async {
    final db = await database;
    await db.transaction((txn) async {
      for (var user in users) {
        await txn.insert('users', user.toMap());
      }
    });
  }

  Future<List<UserModel>> getAllUsers() async {
    final db = await database;
    final result = await db.query('users', orderBy: 'created_date DESC');
    return result.map((map) => UserModel.fromMap(map)).toList();
  }

  Future<List<UserModel>> searchUsers(String query) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'name LIKE ? OR uid LIKE ? OR mobile_number LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'created_date DESC',
    );
    return result.map((map) => UserModel.fromMap(map)).toList();
  }

  Future<UserModel?> getUserByUid(String uid) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'uid = ?',
      whereArgs: [uid],
    );
    if (result.isEmpty) return null;
    return UserModel.fromMap(result.first);
  }

  Future<UserModel?> getUserById(int id) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return UserModel.fromMap(result.first);
  }

  Future<int> updateUser(UserModel user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    // Delete related bills first (CASCADE should handle this, but being explicit)
    await db.delete('bills', where: 'user_uid = ?', whereArgs: [
      (await getUserById(id))?.uid,
    ]);
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  /// Get users filtered by bill status
  /// [status] - 'pending', 'paid', or null for all
  /// [year] - filter by year
  /// [startDate] - filter bills from this date (month-based)
  /// [endDate] - filter bills to this date (month-based)
  /// 
  /// Logic: For a given year and month range (e.g., Jan to Dec 2025):
  /// - PAID: User has bills for ALL months in range AND all are paid
  /// - PENDING: User has unpaid bills OR missing bills in the range
  Future<List<UserModel>> getUsersByBillStatus({
    String? status, // 'pending', 'paid', or null for all
    int? year,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await database;
    
    if (status == null) {
      // Return all users
      return getAllUsers();
    }

    // Determine the month range to check
    int startMonth = 1;
    int endMonth = 12;
    int filterYear = year ?? DateTime.now().year;

    if (startDate != null) {
      startMonth = startDate.month;
      if (year == null) filterYear = startDate.year;
    }
    
    if (endDate != null) {
      endMonth = endDate.month;
    }

    // Calculate expected number of bills
    int expectedBills = endMonth - startMonth + 1;

    if (status == 'paid') {
      // Users who have ALL bills PAID in the specified month range
      // Must have exactly expectedBills bills, all paid
      final result = await db.rawQuery('''
        SELECT DISTINCT u.* 
        FROM users u
        WHERE (
          SELECT COUNT(*) 
          FROM bills b
          WHERE b.user_uid = u.uid
            AND b.year = ?
            AND b.month >= ?
            AND b.month <= ?
            AND b.bill_date IS NOT NULL
            AND b.amount > 0
        ) = ?
        ORDER BY u.created_date DESC
      ''', [filterYear, startMonth, endMonth, expectedBills]);
      
      return result.map((map) => UserModel.fromMap(map)).toList();
    } else if (status == 'pending') {
      // Users who have:
      // 1. At least one unpaid bill in range, OR
      // 2. Fewer bills than expected (missing bills)
      final result = await db.rawQuery('''
        SELECT DISTINCT u.* 
        FROM users u
        WHERE (
          SELECT COUNT(*) 
          FROM bills b
          WHERE b.user_uid = u.uid
            AND b.year = ?
            AND b.month >= ?
            AND b.month <= ?
        ) < ?
        OR EXISTS (
          SELECT 1 FROM bills b
          WHERE b.user_uid = u.uid
            AND b.year = ?
            AND b.month >= ?
            AND b.month <= ?
            AND (b.bill_date IS NULL OR b.amount = 0)
        )
        ORDER BY u.created_date DESC
      ''', [filterYear, startMonth, endMonth, expectedBills, filterYear, startMonth, endMonth]);
      
      return result.map((map) => UserModel.fromMap(map)).toList();
    } else {
      // Invalid status
      return [];
    }
  }

  // Bill CRUD operations
  Future<int> insertBill(BillModel bill) async {
    final db = await database;
    // Check if bill exists, if so update it
    final existing = await getBill(bill.userUid, bill.year, bill.month);
    if (existing != null) {
      return await updateBill(bill.copyWith(id: existing.id));
    }
    return await db.insert('bills', bill.toMap());
  }

  Future<BillModel?> getBill(String userUid, int year, int month) async {
    final db = await database;
    final result = await db.query(
      'bills',
      where: 'user_uid = ? AND year = ? AND month = ?',
      whereArgs: [userUid, year, month],
    );
    if (result.isEmpty) return null;
    return BillModel.fromMap(result.first);
  }

  Future<List<BillModel>> getUserBills(String userUid, int? year) async {
    final db = await database;
    List<Map<String, dynamic>> result;
    if (year != null) {
      result = await db.query(
        'bills',
        where: 'user_uid = ? AND year = ?',
        whereArgs: [userUid, year],
        orderBy: 'month ASC',
      );
    } else {
      result = await db.query(
        'bills',
        where: 'user_uid = ?',
        whereArgs: [userUid],
        orderBy: 'year DESC, month DESC',
      );
    }
    return result.map((map) => BillModel.fromMap(map)).toList();
  }

  Future<List<BillModel>> getAllBills({int? year}) async {
    final db = await database;
    List<Map<String, dynamic>> result;
    if (year != null) {
      result = await db.query(
        'bills',
        where: 'year = ?',
        whereArgs: [year],
        orderBy: 'month ASC',
      );
    } else {
      result = await db.query('bills', orderBy: 'year DESC, month DESC');
    }
    return result.map((map) => BillModel.fromMap(map)).toList();
  }

  Future<int> updateBill(BillModel bill) async {
    final db = await database;
    return await db.update(
      'bills',
      bill.toMap(),
      where: 'id = ?',
      whereArgs: [bill.id],
    );
  }

  Future<int> deleteBill(int id) async {
    final db = await database;
    return await db.delete('bills', where: 'id = ?', whereArgs: [id]);
  }

  // Analytics queries
  Future<double> getTotalEarnings() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM bills WHERE amount > 0',
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<double> getCurrentMonthEarnings() async {
    final db = await database;
    final now = DateTime.now();
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM bills WHERE year = ? AND month = ? AND amount > 0',
      [now.year, now.month],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<double> getYearEarnings(int year) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM bills WHERE year = ? AND amount > 0',
      [year],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<double> getMonthEarnings(int year, int month) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM bills WHERE year = ? AND month = ? AND amount > 0',
      [year, month],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<int> getTotalUsers() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM users');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getPendingBillsCount({
    int? year,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await database;
    
    // Determine the month range
    int startMonth = 1;
    int endMonth = 12;
    int filterYear = year ?? DateTime.now().year;

    if (startDate != null) {
      startMonth = startDate.month;
      if (year == null) filterYear = startDate.year;
    }
    
    if (endDate != null) {
      endMonth = endDate.month;
    }

    // Calculate expected bills: total users × months in range
    final totalUsers = await getTotalUsers();
    final monthsInRange = endMonth - startMonth + 1;
    final expectedBills = totalUsers * monthsInRange;

    // Count paid bills in the range
    final paidBillsResult = await db.rawQuery('''
      SELECT COUNT(*) as count 
      FROM bills 
      WHERE year = ?
        AND month >= ?
        AND month <= ?
        AND bill_date IS NOT NULL
        AND amount > 0
    ''', [filterYear, startMonth, endMonth]);
    
    final paidBills = Sqflite.firstIntValue(paidBillsResult) ?? 0;

    // Pending = Expected - Paid (includes both unpaid and missing bills)
    return expectedBills - paidBills;
  }

  Future<double> getPendingAmount({
    int? year,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await database;
    
    // Determine the month range
    int startMonth = 1;
    int endMonth = 12;
    int filterYear = year ?? DateTime.now().year;

    if (startDate != null) {
      startMonth = startDate.month;
      if (year == null) filterYear = startDate.year;
    }
    
    if (endDate != null) {
      endMonth = endDate.month;
    }

    // Sum amounts of unpaid bills (bill_date IS NULL but amount > 0)
    // Note: Bills with amount = 0 don't contribute to pending amount
    // Missing bills also have no amount to sum
    final result = await db.rawQuery('''
      SELECT SUM(amount) as total 
      FROM bills 
      WHERE year = ?
        AND month >= ?
        AND month <= ?
        AND bill_date IS NULL
        AND amount > 0
    ''', [filterYear, startMonth, endMonth]);
    
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<int> getPayingUsersCount({int? year}) async {
    final db = await database;
    List<Map<String, dynamic>> result;
    if (year != null) {
      result = await db.rawQuery(
        'SELECT COUNT(DISTINCT user_uid) as count FROM bills WHERE year = ? AND amount > 0',
        [year],
      );
    } else {
      result = await db.rawQuery(
        'SELECT COUNT(DISTINCT user_uid) as count FROM bills WHERE amount > 0',
      );
    }
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<List<Map<String, dynamic>>> getEarningsByYear() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT year, SUM(amount) as total 
      FROM bills 
      WHERE amount > 0 
      GROUP BY year 
      ORDER BY year DESC
    ''');
  }

  // Backup and Restore
  Future<Map<String, dynamic>> exportData() async {
    final db = await database;
    final users = await db.query('users');
    final bills = await db.query('bills');
    return {
      'users': users,
      'bills': bills,
      'exported_at': DateTime.now().toIso8601String(),
    };
  }

  Future<void> importData(Map<String, dynamic> data) async {
    final db = await database;
    await db.transaction((txn) async {
      // Clear existing data
      await txn.delete('bills');
      await txn.delete('users');

      // Import users
      if (data['users'] != null) {
        for (var user in data['users'] as List) {
          await txn.insert('users', user as Map<String, dynamic>);
        }
      }

      // Import bills
      if (data['bills'] != null) {
        for (var bill in data['bills'] as List) {
          await txn.insert('bills', bill as Map<String, dynamic>);
        }
      }
    });
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  /// Reinitialize database after restore operations
  /// This fixes the "database_closed" error after restoring from backup
  Future<void> reinitializeDatabase() async {
    try {
      // Close existing database if open
      if (_database != null) {
        await _database!.close();
        _database = null;
      }
      
      // Reinitialize database
      _database = await _initDB('internet_billing.db');
    } catch (e) {
      print('Error reinitializing database: $e');
      rethrow;
    }
  }
}


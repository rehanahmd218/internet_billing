import 'dart:math';
import '../models/user_model.dart';
import '../database/database_helper.dart';
import '../common/widgets/custom_snackbar.dart';

class SeedUsersHelper {
  static final Random _random = Random();

  static final List<String> _firstNames = [
    'Ahmed', 'Ali', 'Hassan', 'Muhammad', 'Omar', 'Fatima', 'Aisha', 'Zainab',
    'Sara', 'Layla', 'Noor', 'Karim', 'Samir', 'Nabil', 'Rania', 'Leila',
    'Mariam', 'Dina', 'Hana', 'Jamal', 'Khalid', 'Ibrahim', 'Youssef', 'Amina',
    'Huda', 'Mona', 'Rana', 'Salma', 'Tariq', 'Walid', 'Yasin', 'Ziad',
  ];

  static final List<String> _lastNames = [
    'Khan', 'Ahmed', 'Hassan', 'Ali', 'Mohamed', 'Ibrahim', 'Abdullah', 'Malik',
    'Rahman', 'Hussain', 'Siddiqui', 'Farooq', 'Hanif', 'Majid', 'Nasir', 'Rashid',
    'Saleem', 'Shaikh', 'Mirza', 'Qazi', 'Baig', 'Sahib', 'Sahib', 'Mian',
  ];

  static final List<String> _cities = [
    'Karachi', 'Lahore', 'Islamabad', 'Rawalpindi', 'Multan', 'Faisalabad',
    'Gujranwala', 'Peshawar', 'Quetta', 'Hyderabad', 'Sukkur', 'Sargodha',
  ];

  static String _generateRandomUid() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = _random.nextInt(10000).toString().padLeft(4, '0');
    return 'USR${timestamp.toString().substring(7, 13)}$random';
  }

  static String _generateRandomPhone() {
    final prefix = '300${_random.nextInt(9) + 1}'; // 3001-3009
    final number = _random.nextInt(9999999).toString().padLeft(7, '0');
    return '$prefix$number';
  }

  static String _generateRandomAddress() {
    final streetNum = _random.nextInt(999) + 1;
    final cityIndex = _random.nextInt(_cities.length);
    return '$streetNum Street, ${_cities[cityIndex]}, Pakistan';
  }

  static Future<void> seedRandomUsers(int count) async {
    try {
      CustomSnackbar.showInfo('Seeding $count users...');

      final db = DatabaseHelper.instance;
      final users = <UserModel>[];

      for (int i = 0; i < count; i++) {
        final firstName = _firstNames[_random.nextInt(_firstNames.length)];
        final lastName = _lastNames[_random.nextInt(_lastNames.length)];

        final user = UserModel(
          no: _random.nextInt(1000000),
        
          uid: _generateRandomUid() + _random.nextInt(100000).toString().padLeft(2, '0'),
          name: '$firstName $lastName',
          mobileNumber: _generateRandomPhone(),
          address: _generateRandomAddress(),
          internetSpeed: [10, 20, 50, 100][_random.nextInt(4)],
          createdDate: DateTime.now(),
          isActive: true,
        );

        users.add(user);
      }

      // Batch insert using transactions for better performance
      await db.insertMultipleUsers(users);

      CustomSnackbar.showSuccess('Successfully seeded $count users!');
    } catch (e) {
      CustomSnackbar.showError('Error seeding users: $e');
    }
  }
}

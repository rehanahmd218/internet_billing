class AppConstants {
  // App Info
  static const String appName = 'NetManager';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Simplified ISP Solutions';

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String billsCollection = 'bills';

  // User Status
  static const String statusActive = 'active';
  static const String statusInactive = 'inactive';

  // Bill Status
  static const String billStatusPaid = 'paid';
  static const String billStatusPending = 'pending';
  static const String billStatusOverdue = 'overdue';

  // Default Values
  static const double defaultBillAmount = 0.0;
  static const String currencySymbol = 'Rs';

  // Validation
  static const int minPhoneLength = 10;
  static const int maxPhoneLength = 15;
  static const int minUidLength = 5;
  static const int maxUidLength = 20;

  // Months
  static const List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  // Month Abbreviations
  static const List<String> monthAbbr = [
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MAY',
    'JUN',
    'JUL',
    'AUG',
    'SEP',
    'OCT',
    'NOV',
    'DEC',
  ];
}

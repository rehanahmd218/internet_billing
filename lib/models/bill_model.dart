class BillModel {
  final int? id;
  final String userUid;
  final int year;
  final int month;
  final double amount;
  final DateTime? billDate;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  BillModel({
    this.id,
    required this.userUid,
    required this.year,
    required this.month,
    required this.amount,
    this.billDate,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isPaid => amount > 0;
  String get status => isPaid ? 'Paid' : 'Pending';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_uid': userUid,
      'year': year,
      'month': month,
      'amount': amount,
      'bill_date': billDate?.toIso8601String(),
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory BillModel.fromMap(Map<String, dynamic> map) {
    return BillModel(
      id: map['id'] as int?,
      userUid: map['user_uid'] as String,
      year: map['year'] as int,
      month: map['month'] as int,
      amount: (map['amount'] as num).toDouble(),
      billDate: map['bill_date'] != null
          ? DateTime.parse(map['bill_date'] as String)
          : null,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  BillModel copyWith({
    int? id,
    String? userUid,
    int? year,
    int? month,
    double? amount,
    DateTime? billDate,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BillModel(
      id: id ?? this.id,
      userUid: userUid ?? this.userUid,
      year: year ?? this.year,
      month: month ?? this.month,
      amount: amount ?? this.amount,
      billDate: billDate ?? this.billDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}


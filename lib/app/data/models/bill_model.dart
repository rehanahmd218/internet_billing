import 'package:cloud_firestore/cloud_firestore.dart';

class BillModel {
  final String? id;
  final String userId;
  final double amount;
  final int month;
  final int year;
  final String status;
  final DateTime? paidDate;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  BillModel({
    this.id,
    required this.userId,
    required this.amount,
    required this.month,
    required this.year,
    required this.status,
    this.paidDate,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  // Create from Firestore document
  factory BillModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BillModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      month: data['month'] ?? 1,
      year: data['year'] ?? DateTime.now().year,
      status: data['status'] ?? 'pending',
      paidDate: (data['paidDate'] as Timestamp?)?.toDate(),
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  // Create from JSON
  factory BillModel.fromJson(Map<String, dynamic> json) {
    return BillModel(
      id: json['id'],
      userId: json['userId'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      month: json['month'] ?? 1,
      year: json['year'] ?? DateTime.now().year,
      status: json['status'] ?? 'pending',
      paidDate: json['paidDate'] != null
          ? (json['paidDate'] is Timestamp
              ? (json['paidDate'] as Timestamp).toDate()
              : DateTime.parse(json['paidDate']))
          : null,
      notes: json['notes'],
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] is Timestamp
              ? (json['updatedAt'] as Timestamp).toDate()
              : DateTime.parse(json['updatedAt']))
          : null,
    );
  }

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'amount': amount,
      'month': month,
      'year': year,
      'status': status,
      'paidDate': paidDate != null ? Timestamp.fromDate(paidDate!) : null,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'month': month,
      'year': year,
      'status': status,
      'paidDate': paidDate?.toIso8601String(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Copy with method for updates
  BillModel copyWith({
    String? id,
    String? userId,
    double? amount,
    int? month,
    int? year,
    String? status,
    DateTime? paidDate,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BillModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      month: month ?? this.month,
      year: year ?? this.year,
      status: status ?? this.status,
      paidDate: paidDate ?? this.paidDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Check if bill is paid
  bool get isPaid => status.toLowerCase() == 'paid';

  // Check if bill is pending
  bool get isPending => status.toLowerCase() == 'pending';

  // Check if bill is overdue
  bool get isOverdue => status.toLowerCase() == 'overdue';

  // Get month-year identifier
  String get monthYearKey => '$year-${month.toString().padLeft(2, '0')}';

  @override
  String toString() {
    return 'BillModel(id: $id, userId: $userId, amount: $amount, month: $month, year: $year, status: $status)';
  }
}

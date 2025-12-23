import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:wifi_billing/app/core/constants/app_constants.dart';
import 'package:wifi_billing/app/core/utils/firebase_utils.dart';
import 'package:wifi_billing/app/core/utils/logger_utils.dart';
import 'package:wifi_billing/app/data/models/bill_model.dart';
import 'package:wifi_billing/app/data/services/firestore_service.dart';

class BillRepository {
  final FirestoreService _firestoreService = FirestoreService();
  final String _collection = AppConstants.billsCollection;

  // Create bill
  Future<String?> createBill(BillModel bill, {RxBool? loader}) async {
    AppLogger.info('Creating bill for user: ${bill.userId}');
    return runFirebaseSafely(() async {
      final docId = await _firestoreService.create(_collection, bill.toJson());
      AppLogger.info('Bill created successfully');
      return docId;
    }, loader: loader);
  }

  // Get bill by ID
  Future<BillModel?> getBillById(String billId, {RxBool? loader}) async {
    AppLogger.info('Getting bill by ID: $billId');
    return runFirebaseSafely(() async {
      final doc = await _firestoreService.read(_collection, billId);
      if (doc != null && doc.exists) {
        return BillModel.fromFirestore(doc);
      }
      return null;
    }, loader: loader);
  }

  // Update bill
  Future<void> updateBill(String billId, BillModel bill, {RxBool? loader}) async {
    AppLogger.info('Updating bill: $billId');
    return runFirebaseSafely(() async {
      final data = bill.toJson();
      data['updatedAt'] = Timestamp.now();
      await _firestoreService.update(_collection, billId, data);
      AppLogger.info('Bill updated successfully');
    }, loader: loader);
  }

  // Delete bill
  Future<void> deleteBill(String billId, {RxBool? loader}) async {
    AppLogger.info('Deleting bill: $billId');
    return runFirebaseSafely(() async {
      await _firestoreService.delete(_collection, billId);
      AppLogger.info('Bill deleted successfully');
    }, loader: loader);
  }

  // Get bills by user ID
  Future<List<BillModel>> getBillsByUserId(String userId, {RxBool? loader}) async {
    AppLogger.info('Getting bills for user: $userId');
    return runFirebaseSafely(() async {
      final docs = await _firestoreService.query(
        _collection,
        [QueryCondition(field: 'userId', isEqualTo: userId)],
        orderBy: 'year',
        descending: true,
      );
      return docs.map((doc) => BillModel.fromFirestore(doc)).toList();
    }, loader: loader);
  }

  // Stream bills by user ID
  Stream<List<BillModel>> streamBillsByUserId(String userId) {
    try {
      AppLogger.info('Streaming bills for user: $userId');
      return _firestoreService
          .streamQuery(
            _collection,
            [QueryCondition(field: 'userId', isEqualTo: userId)],
            orderBy: 'year',
            descending: true,
          )
          .map((docs) => docs.map((doc) => BillModel.fromFirestore(doc)).toList());
    } catch (e, stackTrace) {
      AppLogger.error('Error streaming bills by user ID', e, stackTrace);
      rethrow;
    }
  }

  // Get bills by year
  Future<List<BillModel>> getBillsByYear(int year, {RxBool? loader}) async {
    AppLogger.info('Getting bills for year: $year');
    return runFirebaseSafely(() async {
      final docs = await _firestoreService.query(
        _collection,
        [QueryCondition(field: 'year', isEqualTo: year)],
        orderBy: 'month',
      );
      return docs.map((doc) => BillModel.fromFirestore(doc)).toList();
    }, loader: loader);
  }

  // Get bills by month and year
  Future<List<BillModel>> getBillsByMonthYear(int month, int year, {RxBool? loader}) async {
    AppLogger.info('Getting bills for $month/$year');
    return runFirebaseSafely(() async {
      final docs = await _firestoreService.query(
        _collection,
        [
          QueryCondition(field: 'month', isEqualTo: month),
          QueryCondition(field: 'year', isEqualTo: year),
        ],
      );
      return docs.map((doc) => BillModel.fromFirestore(doc)).toList();
    }, loader: loader);
  }

  // Get bill for specific user, month, and year
  Future<BillModel?> getBillByUserMonthYear(
    String userId,
    int month,
    int year, {
    RxBool? loader,
  }) async {
    AppLogger.info('Getting bill for user $userId, $month/$year');
    return runFirebaseSafely(() async {
      final docs = await _firestoreService.query(
        _collection,
        [
          QueryCondition(field: 'userId', isEqualTo: userId),
          QueryCondition(field: 'month', isEqualTo: month),
          QueryCondition(field: 'year', isEqualTo: year),
        ],
        limit: 1,
      );
      if (docs.isNotEmpty) {
        return BillModel.fromFirestore(docs.first);
      }
      return null;
    }, loader: loader);
  }

  // Get bills by status
  Future<List<BillModel>> getBillsByStatus(String status, {RxBool? loader}) async {
    AppLogger.info('Getting bills by status: $status');
    return runFirebaseSafely(() async {
      final docs = await _firestoreService.query(
        _collection,
        [QueryCondition(field: 'status', isEqualTo: status)],
        orderBy: 'createdAt',
        descending: true,
      );
      return docs.map((doc) => BillModel.fromFirestore(doc)).toList();
    }, loader: loader);
  }

  // Get all bills
  Future<List<BillModel>> getAllBills({RxBool? loader}) async {
    AppLogger.info('Getting all bills');
    return runFirebaseSafely(() async {
      final docs = await _firestoreService.getAll(_collection);
      return docs.map((doc) => BillModel.fromFirestore(doc)).toList();
    }, loader: loader);
  }

  // Stream all bills
  Stream<List<BillModel>> streamAllBills() {
    try {
      AppLogger.info('Streaming all bills');
      return _firestoreService.streamAll(_collection).map(
            (docs) => docs.map((doc) => BillModel.fromFirestore(doc)).toList(),
          );
    } catch (e, stackTrace) {
      AppLogger.error('Error streaming bills', e, stackTrace);
      rethrow;
    }
  }

  // Get total earnings
  Future<double> getTotalEarnings({RxBool? loader}) async {
    return runFirebaseSafely(() async {
      final bills = await getBillsByStatus(AppConstants.billStatusPaid);
      return bills.fold<double>(0.0, (total, bill) => total + bill.amount);
    }, loader: loader);
  }

  // Get total pending amount
  Future<double> getTotalPending({RxBool? loader}) async {
    return runFirebaseSafely(() async {
      final bills = await getBillsByStatus(AppConstants.billStatusPending);
      return bills.fold<double>(0.0, (total, bill) => total + bill.amount);
    }, loader: loader);
  }

  // Get pending bill count
  Future<int> getPendingBillCount({RxBool? loader}) async {
    return runFirebaseSafely(() async {
      final bills = await getBillsByStatus(AppConstants.billStatusPending);
      return bills.length;
    }, loader: loader);
  }

  // Get earnings by year
  Future<double> getEarningsByYear(int year, {RxBool? loader}) async {
    return runFirebaseSafely(() async {
      final bills = await getBillsByYear(year);
      final paidBills = bills.where((bill) => bill.isPaid).toList();
      return paidBills.fold<double>(0.0, (total, bill) => total + bill.amount);
    }, loader: loader);
  }

  // Get current month earnings
  Future<double> getCurrentMonthEarnings({RxBool? loader}) async {
    return runFirebaseSafely(() async {
      final now = DateTime.now();
      final bills = await getBillsByMonthYear(now.month, now.year);
      final paidBills = bills.where((bill) => bill.isPaid).toList();
      return paidBills.fold<double>(0.0, (total, bill) => total + bill.amount);
    }, loader: loader);
  }

  // Get user's total paid amount
  Future<double> getUserTotalPaid(String userId, {RxBool? loader}) async {
    return runFirebaseSafely(() async {
      final bills = await getBillsByUserId(userId);
      final paidBills = bills.where((bill) => bill.isPaid).toList();
      return paidBills.fold<double>(0.0, (total, bill) => total + bill.amount);
    }, loader: loader);
  }

  // Get user's pending amount
  Future<double> getUserPendingAmount(String userId, {RxBool? loader}) async {
    return runFirebaseSafely(() async {
      final bills = await getBillsByUserId(userId);
      final pendingBills = bills.where((bill) => bill.isPending).toList();
      return pendingBills.fold<double>(0.0, (total, bill) => total + bill.amount);
    }, loader: loader);
  }
}

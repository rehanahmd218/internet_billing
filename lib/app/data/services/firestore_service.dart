import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi_billing/app/core/utils/logger_utils.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create document
  Future<String?> create(String collection, Map<String, dynamic> data) async {
    try {
      AppLogger.info('Creating document in $collection');
      final docRef = await _firestore.collection(collection).add(data);
      AppLogger.info('Document created with ID: ${docRef.id}');
      return docRef.id;
    } catch (e, stackTrace) {
      AppLogger.error('Error creating document in $collection', e, stackTrace);
      rethrow;
    }
  }

  // Read document by ID
  Future<DocumentSnapshot?> read(String collection, String docId) async {
    try {
      AppLogger.info('Reading document $docId from $collection');
      final doc = await _firestore.collection(collection).doc(docId).get();
      if (doc.exists) {
        AppLogger.info('Document found');
        return doc;
      } else {
        AppLogger.warning('Document not found');
        return null;
      }
    } catch (e, stackTrace) {
      AppLogger.error('Error reading document from $collection', e, stackTrace);
      rethrow;
    }
  }

  // Update document
  Future<void> update(
    String collection,
    String docId,
    Map<String, dynamic> data,
  ) async {
    try {
      AppLogger.info('Updating document $docId in $collection');
      await _firestore.collection(collection).doc(docId).update(data);
      AppLogger.info('Document updated successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Error updating document in $collection', e, stackTrace);
      rethrow;
    }
  }

  // Delete document
  Future<void> delete(String collection, String docId) async {
    try {
      AppLogger.info('Deleting document $docId from $collection');
      await _firestore.collection(collection).doc(docId).delete();
      AppLogger.info('Document deleted successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Error deleting document from $collection', e, stackTrace);
      rethrow;
    }
  }

  // Get all documents
  Future<List<DocumentSnapshot>> getAll(String collection) async {
    try {
      AppLogger.info('Getting all documents from $collection');
      final snapshot = await _firestore.collection(collection).get();
      AppLogger.info('Found ${snapshot.docs.length} documents');
      return snapshot.docs;
    } catch (e, stackTrace) {
      AppLogger.error('Error getting documents from $collection', e, stackTrace);
      rethrow;
    }
  }

  // Get documents with query
  Future<List<DocumentSnapshot>> query(
    String collection,
    List<QueryCondition> conditions, {
    String? orderBy,
    bool descending = false,
    int? limit,
  }) async {
    try {
      AppLogger.info('Querying documents from $collection');
      Query query = _firestore.collection(collection);

      // Apply conditions
      for (final condition in conditions) {
        query = query.where(
          condition.field,
          isEqualTo: condition.isEqualTo,
          isNotEqualTo: condition.isNotEqualTo,
          isLessThan: condition.isLessThan,
          isLessThanOrEqualTo: condition.isLessThanOrEqualTo,
          isGreaterThan: condition.isGreaterThan,
          isGreaterThanOrEqualTo: condition.isGreaterThanOrEqualTo,
          arrayContains: condition.arrayContains,
          arrayContainsAny: condition.arrayContainsAny,
          whereIn: condition.whereIn,
          whereNotIn: condition.whereNotIn,
          isNull: condition.isNull,
        );
      }

      // Apply ordering
      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }

      // Apply limit
      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      AppLogger.info('Query returned ${snapshot.docs.length} documents');
      return snapshot.docs;
    } catch (e, stackTrace) {
      AppLogger.error('Error querying documents from $collection', e, stackTrace);
      rethrow;
    }
  }

  // Stream all documents
  Stream<List<DocumentSnapshot>> streamAll(String collection) {
    try {
      AppLogger.info('Streaming all documents from $collection');
      return _firestore.collection(collection).snapshots().map(
            (snapshot) => snapshot.docs,
          );
    } catch (e, stackTrace) {
      AppLogger.error('Error streaming documents from $collection', e, stackTrace);
      rethrow;
    }
  }

  // Stream documents with query
  Stream<List<DocumentSnapshot>> streamQuery(
    String collection,
    List<QueryCondition> conditions, {
    String? orderBy,
    bool descending = false,
    int? limit,
  }) {
    try {
      AppLogger.info('Streaming query from $collection');
      Query query = _firestore.collection(collection);

      // Apply conditions
      for (final condition in conditions) {
        query = query.where(
          condition.field,
          isEqualTo: condition.isEqualTo,
          isNotEqualTo: condition.isNotEqualTo,
          isLessThan: condition.isLessThan,
          isLessThanOrEqualTo: condition.isLessThanOrEqualTo,
          isGreaterThan: condition.isGreaterThan,
          isGreaterThanOrEqualTo: condition.isGreaterThanOrEqualTo,
          arrayContains: condition.arrayContains,
          arrayContainsAny: condition.arrayContainsAny,
          whereIn: condition.whereIn,
          whereNotIn: condition.whereNotIn,
          isNull: condition.isNull,
        );
      }

      // Apply ordering
      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }

      // Apply limit
      if (limit != null) {
        query = query.limit(limit);
      }

      return query.snapshots().map((snapshot) => snapshot.docs);
    } catch (e, stackTrace) {
      AppLogger.error('Error streaming query from $collection', e, stackTrace);
      rethrow;
    }
  }

  // Batch write
  Future<void> batchWrite(List<BatchOperation> operations) async {
    try {
      AppLogger.info('Executing batch write with ${operations.length} operations');
      final batch = _firestore.batch();

      for (final operation in operations) {
        final docRef = _firestore.collection(operation.collection).doc(operation.docId);

        switch (operation.type) {
          case BatchOperationType.create:
            batch.set(docRef, operation.data!);
            break;
          case BatchOperationType.update:
            batch.update(docRef, operation.data!);
            break;
          case BatchOperationType.delete:
            batch.delete(docRef);
            break;
        }
      }

      await batch.commit();
      AppLogger.info('Batch write completed successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Error executing batch write', e, stackTrace);
      rethrow;
    }
  }
}

// Query condition helper class
class QueryCondition {
  final String field;
  final dynamic isEqualTo;
  final dynamic isNotEqualTo;
  final dynamic isLessThan;
  final dynamic isLessThanOrEqualTo;
  final dynamic isGreaterThan;
  final dynamic isGreaterThanOrEqualTo;
  final dynamic arrayContains;
  final List<dynamic>? arrayContainsAny;
  final List<dynamic>? whereIn;
  final List<dynamic>? whereNotIn;
  final bool? isNull;

  QueryCondition({
    required this.field,
    this.isEqualTo,
    this.isNotEqualTo,
    this.isLessThan,
    this.isLessThanOrEqualTo,
    this.isGreaterThan,
    this.isGreaterThanOrEqualTo,
    this.arrayContains,
    this.arrayContainsAny,
    this.whereIn,
    this.whereNotIn,
    this.isNull,
  });
}

// Batch operation helper class
class BatchOperation {
  final String collection;
  final String? docId;
  final BatchOperationType type;
  final Map<String, dynamic>? data;

  BatchOperation({
    required this.collection,
    this.docId,
    required this.type,
    this.data,
  });
}

enum BatchOperationType {
  create,
  update,
  delete,
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/certification.dart';

class CertificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user's certifications stream
  /// Sorted by expiration date (soonest first)
  Stream<List<Certification>> getUserCertifications() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('certifications')
        .orderBy('expiresAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Certification.fromFirestore(doc))
            .toList());
  }

  /// Get all active certification types
  Stream<List<CertificationType>> getCertificationTypes() {
    return _firestore
        .collection('certification_types')
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CertificationType.fromFirestore(doc))
            .toList());
  }

  /// Add a new certification
  Future<void> addCertification({
    required String typeId,
    required String typeName,
    required DateTime expiresAt,
    DateTime? issuedDate,
    String? notes,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final cert = Certification(
      id: '', // Will be set by Firestore
      userId: userId,
      typeId: typeId,
      typeName: typeName,
      expiresAt: expiresAt,
      issuedDate: issuedDate,
      notes: notes,
    );

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('certifications')
        .add(cert.toFirestore());
  }

  /// Update an existing certification
  Future<void> updateCertification(String certId, {
    String? typeId,
    String? typeName,
    DateTime? expiresAt,
    DateTime? issuedDate,
    String? notes,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final updates = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (typeId != null) updates['typeId'] = typeId;
    if (typeName != null) updates['typeName'] = typeName;
    if (expiresAt != null) updates['expiresAt'] = Timestamp.fromDate(expiresAt);
    if (issuedDate != null) {
      updates['issuedDate'] = Timestamp.fromDate(issuedDate);
    }
    if (notes != null) updates['notes'] = notes;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('certifications')
        .doc(certId)
        .update(updates);
  }

  /// Delete a certification
  Future<void> deleteCertification(String certId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('certifications')
        .doc(certId)
        .delete();
  }

  /// Get the next expiring certification
  Future<Certification?> getNextExpiring() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return null;
    }

    final now = DateTime.now();
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('certifications')
        .where('expiresAt', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
        .orderBy('expiresAt', descending: false)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    return Certification.fromFirestore(snapshot.docs.first);
  }

  /// Get count of certifications by status
  Future<Map<CertificationStatus, int>> getCertificationCounts() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return {
        CertificationStatus.valid: 0,
        CertificationStatus.expiringSoon: 0,
        CertificationStatus.expired: 0,
      };
    }

    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('certifications')
        .get();

    final counts = {
      CertificationStatus.valid: 0,
      CertificationStatus.expiringSoon: 0,
      CertificationStatus.expired: 0,
    };

    for (final doc in snapshot.docs) {
      final cert = Certification.fromFirestore(doc);
      final status = cert.getStatus();
      counts[status] = (counts[status] ?? 0) + 1;
    }

    return counts;
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

enum CertificationStatus {
  valid,
  expiringSoon,
  expired,
}

/// Certification model with flexible type system
/// Uses typeId to reference certification_types collection
class Certification {
  final String id;
  final String userId;
  final String typeId; // Reference to certification_types doc
  final String typeName; // Denormalized for display
  final DateTime expiresAt;
  final DateTime? issuedDate;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Certification({
    required this.id,
    required this.userId,
    required this.typeId,
    required this.typeName,
    required this.expiresAt,
    this.issuedDate,
    this.notes,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Certification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Certification(
      id: doc.id,
      userId: data['userId'] ?? '',
      typeId: data['typeId'] ?? '',
      typeName: data['typeName'] ?? '',
      expiresAt: (data['expiresAt'] as Timestamp).toDate(),
      issuedDate: data['issuedDate'] != null 
          ? (data['issuedDate'] as Timestamp).toDate() 
          : null,
      notes: data['notes'],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'typeId': typeId,
      'typeName': typeName,
      'expiresAt': Timestamp.fromDate(expiresAt),
      'issuedDate': issuedDate != null ? Timestamp.fromDate(issuedDate!) : null,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Get certification status based on expiration date
  /// - Expired: expiresAt < today
  /// - Expiring Soon: expiresAt within 60 days
  /// - Valid: otherwise
  CertificationStatus getStatus({int expiringDaysThreshold = 60}) {
    final now = DateTime.now();
    final difference = expiresAt.difference(now).inDays;
    
    if (expiresAt.isBefore(now)) {
      return CertificationStatus.expired;
    } else if (difference <= expiringDaysThreshold) {
      return CertificationStatus.expiringSoon;
    } else {
      return CertificationStatus.valid;
    }
  }

  /// Get days remaining until expiration (negative if expired)
  int getDaysRemaining() {
    final now = DateTime.now();
    return expiresAt.difference(now).inDays;
  }

  Certification copyWith({
    String? id,
    String? userId,
    String? typeId,
    String? typeName,
    DateTime? expiresAt,
    DateTime? issuedDate,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Certification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      typeId: typeId ?? this.typeId,
      typeName: typeName ?? this.typeName,
      expiresAt: expiresAt ?? this.expiresAt,
      issuedDate: issuedDate ?? this.issuedDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Certification Type model - represents available certification types
/// Managed globally (admin-curated list)
class CertificationType {
  final String id;
  final String name;
  final String? category;
  final bool isActive;
  final DateTime? createdAt;

  CertificationType({
    required this.id,
    required this.name,
    this.category,
    this.isActive = true,
    this.createdAt,
  });

  factory CertificationType.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CertificationType(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'],
      isActive: data['isActive'] ?? true,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'category': category,
      'isActive': isActive,
      'createdAt': createdAt != null 
          ? Timestamp.fromDate(createdAt!) 
          : FieldValue.serverTimestamp(),
    };
  }
}

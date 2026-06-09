import 'package:flutter/material.dart';

enum VerificationStatus {
  pending,
  approved,
  rejected,
  not_submitted,
}

enum DocumentType {
  nationalId,
  farmLicense,
  landOwnership,
  certificate,
}

class VerificationDocument {
  final String id;
  final DocumentType type;
  final String documentName;
  final String fileUrl;
  final DateTime uploadedAt;
  final VerificationStatus status;
  final String? rejectionReason;
  
  VerificationDocument({
    required this.id,
    required this.type,
    required this.documentName,
    required this.fileUrl,
    required this.uploadedAt,
    required this.status,
    this.rejectionReason,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString(),
      'documentName': documentName,
      'fileUrl': fileUrl,
      'uploadedAt': uploadedAt.toIso8601String(),
      'status': status.toString(),
    };
  }
}

class FarmerVerification {
  final String farmerId;
  final String farmerName;
  final String farmName;
  final String farmLocation;
  final int yearsOfExperience;
  final List<VerificationDocument> documents;
  final VerificationStatus status;
  final DateTime submittedAt;
  final DateTime? reviewedAt;
  final String? reviewedBy;
  final String? notes;
  final double trustScore;
  
  FarmerVerification({
    required this.farmerId,
    required this.farmerName,
    required this.farmName,
    required this.farmLocation,
    required this.yearsOfExperience,
    required this.documents,
    required this.status,
    required this.submittedAt,
    this.reviewedAt,
    this.reviewedBy,
    this.notes,
    this.trustScore = 0.0,
  });
  
  String get statusText {
    switch (status) {
      case VerificationStatus.pending:
        return 'Pending Review';
      case VerificationStatus.approved:
        return 'Verified ✓';
      case VerificationStatus.rejected:
        return 'Rejected ✗';
      case VerificationStatus.not_submitted:
        return 'Not Submitted';
    }
  }
  
  Color get statusColor {
    switch (status) {
      case VerificationStatus.pending:
        return Colors.orange;
      case VerificationStatus.approved:
        return Colors.green;
      case VerificationStatus.rejected:
        return Colors.red;
      case VerificationStatus.not_submitted:
        return Colors.grey;
    }
  }
  
  IconData get statusIcon {
    switch (status) {
      case VerificationStatus.pending:
        return Icons.hourglass_empty;
      case VerificationStatus.approved:
        return Icons.verified;
      case VerificationStatus.rejected:
        return Icons.cancel;
      case VerificationStatus.not_submitted:
        return Icons.pending;
    }
  }
}

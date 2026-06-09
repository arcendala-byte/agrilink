import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/verification/verification_models.dart';

class VerificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // Upload document
  Future<String?> uploadDocument(File file, String documentType) async {
    try {
      final userId = currentUserId;
      if (userId == null) return null;
      
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_$documentType.jpg';
      final ref = _storage.ref().child('verification/$userId/$fileName');
      
      await ref.putFile(file);
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading document: $e');
      return null;
    }
  }

  // Submit verification request
  Future<bool> submitVerification({
    required String farmName,
    required String farmLocation,
    required int yearsOfExperience,
    required List<VerificationDocument> documents,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) return false;
      
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final farmerName = userDoc.data()?['name'] ?? 'Farmer';
      
      final verificationData = {
        'farmerId': userId,
        'farmerName': farmerName,
        'farmName': farmName,
        'farmLocation': farmLocation,
        'yearsOfExperience': yearsOfExperience,
        'documents': documents.map((doc) => doc.toJson()).toList(),
        'status': 'pending',
        'submittedAt': FieldValue.serverTimestamp(),
        'trustScore': 0.0,
      };
      
      await _firestore.collection('verifications').doc(userId).set(verificationData);
      
      // Update user with pending verification
      await _firestore.collection('users').doc(userId).update({
        'verificationStatus': 'pending',
        'verificationSubmittedAt': FieldValue.serverTimestamp(),
      });
      
      return true;
    } catch (e) {
      print('Error submitting verification: $e');
      return false;
    }
  }

  // Get verification status for a farmer
  Future<FarmerVerification?> getVerificationStatus(String farmerId) async {
    try {
      final doc = await _firestore.collection('verifications').doc(farmerId).get();
      if (!doc.exists) return null;
      
      final data = doc.data()!;
      return FarmerVerification(
        farmerId: data['farmerId'],
        farmerName: data['farmerName'],
        farmName: data['farmName'],
        farmLocation: data['farmLocation'],
        yearsOfExperience: data['yearsOfExperience'],
        documents: [],
        status: _getStatusFromString(data['status']),
        submittedAt: (data['submittedAt'] as Timestamp).toDate(),
        reviewedAt: data['reviewedAt']?.toDate(),
        reviewedBy: data['reviewedBy'],
        notes: data['notes'],
        trustScore: (data['trustScore'] ?? 0.0).toDouble(),
      );
    } catch (e) {
      print('Error getting verification: $e');
      return null;
    }
  }

  // Admin: Get all pending verifications
  Stream<List<FarmerVerification>> getPendingVerifications() {
    return _firestore
        .collection('verifications')
        .where('status', isEqualTo: 'pending')
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return FarmerVerification(
              farmerId: data['farmerId'],
              farmerName: data['farmerName'],
              farmName: data['farmName'],
              farmLocation: data['farmLocation'],
              yearsOfExperience: data['yearsOfExperience'],
              documents: [],
              status: VerificationStatus.pending,
              submittedAt: (data['submittedAt'] as Timestamp).toDate(),
              trustScore: (data['trustScore'] ?? 0.0).toDouble(),
            );
          }).toList();
        });
  }

  // Admin: Approve verification
  Future<bool> approveVerification(String farmerId, String adminId, String notes) async {
    try {
      await _firestore.collection('verifications').doc(farmerId).update({
        'status': 'approved',
        'reviewedAt': FieldValue.serverTimestamp(),
        'reviewedBy': adminId,
        'notes': notes,
        'trustScore': 100,
      });
      
      await _firestore.collection('users').doc(farmerId).update({
        'verificationStatus': 'approved',
        'isVerified': true,
        'verifiedAt': FieldValue.serverTimestamp(),
      });
      
      return true;
    } catch (e) {
      print('Error approving verification: $e');
      return false;
    }
  }

  // Admin: Reject verification
  Future<bool> rejectVerification(String farmerId, String adminId, String reason) async {
    try {
      await _firestore.collection('verifications').doc(farmerId).update({
        'status': 'rejected',
        'reviewedAt': FieldValue.serverTimestamp(),
        'reviewedBy': adminId,
        'notes': reason,
      });
      
      await _firestore.collection('users').doc(farmerId).update({
        'verificationStatus': 'rejected',
        'isVerified': false,
      });
      
      return true;
    } catch (e) {
      print('Error rejecting verification: $e');
      return false;
    }
  }

  VerificationStatus _getStatusFromString(String status) {
    switch (status) {
      case 'pending': return VerificationStatus.pending;
      case 'approved': return VerificationStatus.approved;
      case 'rejected': return VerificationStatus.rejected;
      default: return VerificationStatus.not_submitted;
    }
  }
}

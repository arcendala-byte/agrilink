import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileNotifier extends StateNotifier<Map<String, dynamic>> {
  ProfileNotifier() : super({});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> loadProfile() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        state = doc.data() ?? {};
      } else {
        state = {
          'name': user.displayName ?? '',
          'email': user.email ?? '',
          'phone': '',
          'userType': 'farmer',
          'farmName': '',
          'farmLocation': '',
          'farmSize': '',
          'bio': '',
          'profileImageUrl': '',
        };
      }
    }
  }

  Future<void> updateProfile(Map<String, dynamic> updates) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update(updates);
      state = {...state, ...updates};
      
      if (updates.containsKey('name')) {
        await user.updateDisplayName(updates['name']);
      }
    }
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, Map<String, dynamic>>((ref) {
  final notifier = ProfileNotifier();
  notifier.loadProfile();
  return notifier;
});

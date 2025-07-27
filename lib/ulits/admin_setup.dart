// lib/utils/admin_setup.dart
// Script untuk membuat admin pertama kali

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminSetup {
  static Future<void> createFirstAdmin() async {
    try {
      // Ganti dengan email dan password admin yang diinginkan
      const String adminEmail = 'admin@example.com';
      const String adminPassword = 'admin123456';
      const String adminName = 'Administrator';

      print('Creating admin account...');

      // Create user account
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: adminEmail,
            password: adminPassword,
          );

      print('Admin user created: ${userCredential.user!.uid}');

      // Add admin role to Firestore
      await FirebaseFirestore.instance
          .collection('admins')
          .doc(userCredential.user!.uid)
          .set({
            'name': adminName,
            'email': adminEmail,
            'role': 'admin',
            'createdAt': FieldValue.serverTimestamp(),
            'isActive': true,
          });

      // Update display name
      await userCredential.user!.updateDisplayName(adminName);

      print('Admin setup completed successfully!');
      print('Email: $adminEmail');
      print('Password: $adminPassword');
      print('Please change the password after first login.');
    } catch (e) {
      print('Error creating admin: $e');
    }
  }

  // Helper method to add admin role to existing user
  static Future<void> makeUserAdmin(String userEmail) async {
    try {
      // Get user by email
      List<String> signInMethods = await FirebaseAuth.instance
          .fetchSignInMethodsForEmail(userEmail);

      if (signInMethods.isEmpty) {
        print('User with email $userEmail not found');
        return;
      }

      print('User found. Please get the UID and add admin role manually.');
    } catch (e) {
      print('Error: $e');
    }
  }

  // Method to remove admin role
  static Future<void> removeAdminRole(String userId) async {
    try {
      await FirebaseFirestore.instance
          .collection('admins')
          .doc(userId)
          .delete();

      print('Admin role removed for user: $userId');
    } catch (e) {
      print('Error removing admin role: $e');
    }
  }

  // Method to list all admins
  static Future<void> listAllAdmins() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('admins')
          .get();

      print('Current admins:');
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        print('- ${data['name']} (${data['email']}) - ID: ${doc.id}');
      }
    } catch (e) {
      print('Error listing admins: $e');
    }
  }
}

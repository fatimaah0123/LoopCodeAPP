import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import 'login_page.dart';
import '../pages/admin/admin_dashboard.dart';
import '../pages/dashboard/dashboard_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FirebaseService firebaseService = FirebaseService();

    return StreamBuilder<User?>(
      stream: firebaseService.authStateChanges,
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF1E1E2E),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF7C3AED)),
            ),
          );
        }

        // User not logged in
        if (snapshot.data == null) {
          return const LoginPage();
        }

        // User logged in - check role
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(snapshot.data!.uid)
              .get(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                backgroundColor: Color(0xFF1E1E2E),
                body: Center(
                  child: CircularProgressIndicator(color: Color(0xFF7C3AED)),
                ),
              );
            }

            // Check user role and redirect accordingly
            if (userSnapshot.hasData && userSnapshot.data!.exists) {
              String role = userSnapshot.data!.get('role') ?? 'user';

              if (role == 'admin') {
                return AdminDashboard();
              } else {
                return DashboardPage();
              }
            } else {
              // If user document doesn't exist, redirect to user dashboard
              return DashboardPage();
            }
          },
        );
      },
    );
  }
}

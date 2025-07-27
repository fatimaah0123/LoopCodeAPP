import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'routes/app_routes.dart';
import 'theme/app_theme.dart';
import 'pages/admin/admin_auth_page.dart';
import 'pages/admin/admin_dashboard.dart';
import 'services/firebase_service.dart';
import 'auth/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const LoopCodeApp());
}

class LoopCodeApp extends StatelessWidget {
  const LoopCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Loop Code',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
      routes: {
        ...AppRoutes.routes,
        '/admin-login': (context) => AdminAuthPage(),
        '/admin-dashboard': (context) => AdminDashboard(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firebaseService = FirebaseService(); // ✅ buat instance di sini

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return FutureBuilder<bool>(
            future: firebaseService.isAdmin(
              snapshot.data!.uid,
            ), // ✅ pakai instance
            builder: (context, adminSnapshot) {
              if (adminSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (adminSnapshot.hasError) {
                return const Scaffold(
                  body: Center(child: Text('Terjadi kesalahan')),
                );
              }

              if (adminSnapshot.data == true) {
                return AdminDashboard();
              } else {
                return MainApp();
              }
            },
          );
        } else {
          return const MainApp();
        }
      },
    );
  }
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loop Code'),
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            onPressed: () {
              Navigator.pushNamed(context, '/admin-login');
            },
            tooltip: 'Admin Panel',
          ),
        ],
      ),
      body: const Center(child: Text('Welcome to Loop Code!')),
    );
  }
}

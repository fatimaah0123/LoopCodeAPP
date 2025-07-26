import 'package:flutter/material.dart';

class NavbarWidget extends StatelessWidget {
  const NavbarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple[200]!, Colors.purple[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo dan Nama App
          Row(
            children: [
              Image.asset(
                'assets/images/logo.png',
                width: 70,
                height: 70,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback jika logo tidak ditemukan
                  return const Icon(Icons.code, color: Colors.purple, size: 32);
                },
              ),
            ],
          ),

          // Hamburger Menu
          PopupMenuButton<String>(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.menu, color: Colors.purple, size: 24),
            ),
            offset: const Offset(0, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person, color: Colors.purple),
                    SizedBox(width: 12),
                    Text('Profil Saya'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'progress',
                child: Row(
                  children: [
                    Icon(Icons.trending_up, color: Colors.purple),
                    SizedBox(width: 12),
                    Text('My Progress'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, color: Colors.purple),
                    SizedBox(width: 12),
                    Text('Pengaturan'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'about',
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.purple),
                    SizedBox(width: 12),
                    Text('Tentang Kami'),
                  ],
                ),
              ),
            ],
            onSelected: (String value) {
              switch (value) {
                case 'profile':
                  // Navigate to profile page
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Halaman Profil')),
                  );
                  break;
                case 'progress':
                  // Navigate to progress page
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Halaman Progress')),
                  );
                  break;
                case 'settings':
                  // Navigate to settings page
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Halaman Pengaturan')),
                  );
                  break;
                case 'about':
                  // Navigate to about page
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Halaman Tentang Kami')),
                  );
                  break;
              }
            },
          ),
        ],
      ),
    );
  }
}

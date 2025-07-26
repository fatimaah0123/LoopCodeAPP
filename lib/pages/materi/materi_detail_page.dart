import 'package:flutter/material.dart';

class MateriDetailPage extends StatefulWidget {
  const MateriDetailPage({super.key});

  @override
  State<MateriDetailPage> createState() => _MateriDetailPageState();
}

class _MateriDetailPageState extends State<MateriDetailPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // TODO: Ganti dengan data dari API
  Map<String, dynamic>? _kategoriData;
  Map<String, dynamic>? _subMateriData;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ambil data dari arguments
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _kategoriData = args['kategori'];
      _subMateriData = args['subMateri'];
    }
  }

  // TODO: Fungsi untuk mengambil konten detail dari API
  List<Map<String, dynamic>> _getMateriContent() {
    // Dummy content - nantinya akan diganti dengan data dari API
    return [
      {
        'type': 'text',
        'title': 'Pengantar',
        'content':
            'Selamat datang di materi ${_subMateriData?['judul'] ?? 'Pembelajaran'}. Dalam materi ini kamu akan mempelajari konsep-konsep dasar yang sangat penting untuk pemahaman lebih lanjut.',
      },
      {
        'type': 'code',
        'title': 'Contoh Kode',
        'content': '''<!DOCTYPE html>
<html>
<head>
    <title>Hello World</title>
</head>
<body>
    <h1>Hello, World!</h1>
    <p>Ini adalah contoh sederhana.</p>
</body>
</html>''',
      },
      {
        'type': 'text',
        'title': 'Penjelasan',
        'content':
            'Kode di atas menunjukkan struktur dasar dari sebuah dokumen. Setiap elemen memiliki fungsi khusus dalam membangun halaman web.',
      },
      {
        'type': 'tips',
        'title': 'Tips & Trik',
        'content':
            'Selalu pastikan untuk menulis kode yang bersih dan mudah dibaca. Gunakan indentasi yang konsisten dan berikan komentar pada bagian yang kompleks.',
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_kategoriData == null || _subMateriData == null) {
      return const Scaffold(body: Center(child: Text('Data tidak ditemukan')));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: CustomScrollView(
                slivers: [
                  // App Bar dengan gradient
                  SliverAppBar(
                    expandedHeight: 200,
                    floating: false,
                    pinned: true,
                    backgroundColor: _kategoriData!['warna'],
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new),
                      color: Colors.white,
                      onPressed: () => Navigator.pop(context),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _kategoriData!['warna'].withOpacity(0.9),
                              _kategoriData!['warna'].withOpacity(0.7),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Icon dan kategori
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      _kategoriData!['icon'],
                                      size: 24,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    _kategoriData!['judul'],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Judul materi
                              Text(
                                _subMateriData!['judul'],
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Info badges
                              Row(
                                children: [
                                  _buildInfoBadge(
                                    Icons.access_time,
                                    _subMateriData!['estimasi'],
                                  ),
                                  const SizedBox(width: 12),
                                  _buildInfoBadge(
                                    Icons.bar_chart,
                                    _subMateriData!['tingkat'],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Konten materi
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Deskripsi
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: _kategoriData!['border'],
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Tentang Materi Ini',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: _kategoriData!['border'],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _subMateriData!['deskripsi'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Konten materi
                          ..._getMateriContent().asMap().entries.map((entry) {
                            final index = entry.key;
                            final content = entry.value;
                            return TweenAnimationBuilder<double>(
                              duration: Duration(
                                milliseconds: 300 + (index * 100),
                              ),
                              tween: Tween(begin: 0.0, end: 1.0),
                              builder: (context, value, child) {
                                return Transform.translate(
                                  offset: Offset(0, 20 * (1 - value)),
                                  child: Opacity(
                                    opacity: value,
                                    child: _buildContentCard(content, index),
                                  ),
                                );
                              },
                            );
                          }),

                          const SizedBox(height: 24),

                          // Tombol aksi
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    // TODO: Implementasi bookmark
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Materi telah disimpan ke bookmark',
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.bookmark_outline),
                                  label: const Text('Simpan'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey[200],
                                    foregroundColor: Colors.grey[700],
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 2,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    // TODO: Implementasi quiz/latihan
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Quiz akan segera tersedia',
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.quiz_outlined),
                                  label: const Text('Mulai Quiz'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _kategoriData!['border'],
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentCard(Map<String, dynamic> content, int index) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header dengan icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getContentTypeColor(content['type']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getContentTypeIcon(content['type']),
                  size: 20,
                  color: _getContentTypeColor(content['type']),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  content['title'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _kategoriData!['border'],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Konten
          if (content['type'] == 'code')
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  content['content'],
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontFamily: 'monospace',
                    height: 1.4,
                  ),
                ),
              ),
            )
          else if (content['type'] == 'tips')
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: Text(
                content['content'],
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
            )
          else
            Text(
              content['content'],
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
        ],
      ),
    );
  }

  IconData _getContentTypeIcon(String type) {
    switch (type) {
      case 'code':
        return Icons.code;
      case 'tips':
        return Icons.lightbulb_outline;
      default:
        return Icons.article_outlined;
    }
  }

  Color _getContentTypeColor(String type) {
    switch (type) {
      case 'code':
        return Colors.purple;
      case 'tips':
        return Colors.amber;
      default:
        return Colors.blue;
    }
  }
}

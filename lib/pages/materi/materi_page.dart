import 'package:flutter/material.dart';
// import '../../widgets/materi_card.dart';
import '../../widgets/sub_materi_card.dart';

class MateriPage extends StatefulWidget {
  const MateriPage({super.key});

  @override
  State<MateriPage> createState() => _MateriPageState();
}

class _MateriPageState extends State<MateriPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // TODO: Ganti dengan data dari API
  final List<Map<String, dynamic>> _kategoriMateri = [
    {
      'id': 'html',
      'judul': 'HTML',
      'deskripsi': 'Hypertext Markup Language untuk struktur web',
      'icon': Icons.code,
      'warna': Colors.orange,
      'border': Colors.deepOrange,
      'subMateri': [
        {
          'id': 'html-pengertian',
          'judul': 'Pengertian HTML',
          'deskripsi':
              'Pelajari dasar-dasar HTML dan cara kerja markup language. HTML adalah fondasi dari semua halaman web.',
          'estimasi': '15 menit',
          'tingkat': 'Pemula',
          'icon': Icons.description,
        },
        {
          'id': 'html-tag',
          'judul': 'Tag HTML',
          'deskripsi':
              'Mengenal berbagai tag HTML seperti heading, paragraph, dan link. Belajar struktur dasar dokumen HTML.',
          'estimasi': '20 menit',
          'tingkat': 'Pemula',
          'icon': Icons.local_offer,
        },
        {
          'id': 'html-form',
          'judul': 'Form HTML',
          'deskripsi':
              'Membuat form interaktif dengan input, button, dan validation. Pelajari cara mengelola data dari user.',
          'estimasi': '25 menit',
          'tingkat': 'Menengah',
          'icon': Icons.dynamic_form,
        },
      ],
    },
    {
      'id': 'css',
      'judul': 'CSS',
      'deskripsi': 'Cascading Style Sheets untuk styling web',
      'icon': Icons.palette,
      'warna': Colors.blue,
      'border': Colors.blueAccent,
      'subMateri': [
        {
          'id': 'css-pengertian',
          'judul': 'Pengertian CSS',
          'deskripsi':
              'Memahami CSS dan perannya dalam web design. Belajar bagaimana CSS mengubah tampilan HTML.',
          'estimasi': '15 menit',
          'tingkat': 'Pemula',
          'icon': Icons.brush,
        },
        {
          'id': 'css-color',
          'judul': 'CSS Color',
          'deskripsi':
              'Menguasai penggunaan warna dalam CSS. Pelajari hex, RGB, HSL, dan berbagai cara mendefinisikan warna.',
          'estimasi': '20 menit',
          'tingkat': 'Pemula',
          'icon': Icons.color_lens,
        },
        {
          'id': 'css-grid',
          'judul': 'CSS Grid',
          'deskripsi':
              'Membuat layout kompleks dengan CSS Grid. Teknik modern untuk mengatur tata letak halaman web.',
          'estimasi': '30 menit',
          'tingkat': 'Lanjutan',
          'icon': Icons.grid_on,
        },
      ],
    },
    {
      'id': 'javascript',
      'judul': 'JavaScript',
      'deskripsi': 'Bahasa pemrograman untuk web interaktif',
      'icon': Icons.javascript,
      'warna': Colors.yellow,
      'border': Colors.amber,
      'subMateri': [
        {
          'id': 'js-pengertian',
          'judul': 'Pengertian JavaScript',
          'deskripsi':
              'Memahami JavaScript dan perannya dalam web development. Belajar dasar-dasar programming dengan JS.',
          'estimasi': '20 menit',
          'tingkat': 'Pemula',
          'icon': Icons.lightbulb,
        },
        {
          'id': 'js-variable',
          'judul': 'Variable & Data Type',
          'deskripsi':
              'Mengenal variable, const, let, dan berbagai tipe data. Dasar pemrograman JavaScript yang wajib dikuasai.',
          'estimasi': '25 menit',
          'tingkat': 'Pemula',
          'icon': Icons.storage,
        },
        {
          'id': 'js-function',
          'judul': 'Function',
          'deskripsi':
              'Membuat dan menggunakan function dalam JavaScript. Pelajari cara membuat kode yang dapat digunakan ulang.',
          'estimasi': '30 menit',
          'tingkat': 'Menengah',
          'icon': Icons.functions,
        },
      ],
    },
  ];

  String? _selectedKategori;

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Materi Pembelajaran',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF6C5CE7),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: _selectedKategori == null
                  ? _buildKategoriView()
                  : _buildSubMateriView(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildKategoriView() {
    return Column(
      children: [
        // Header dengan ilustrasi
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6C5CE7), Color(0xFF5F3DC4)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Ilustrasi/Icon
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.school,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Pilih Kategori Materi',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Mulai perjalanan coding-mu dari sini!',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
              ],
            ),
          ),
        ),

        // Daftar kategori
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: _kategoriMateri.length,
              itemBuilder: (context, index) {
                final kategori = _kategoriMateri[index];
                return _buildKategoriCard(kategori, index);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKategoriCard(Map<String, dynamic> kategori, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedKategori = kategori['id'];
        });
        _animationController.reset();
        _animationController.forward();
      },
      child: TweenAnimationBuilder<double>(
        duration: Duration(milliseconds: 300 + (index * 100)),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    kategori['warna'].withOpacity(0.8),
                    kategori['warna'].withOpacity(0.6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: kategori['border'], width: 2),
                boxShadow: [
                  BoxShadow(
                    color: kategori['border'].withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Icon
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(
                        kategori['icon'],
                        size: 32,
                        color: kategori['border'],
                      ),
                    ),
                    // Judul
                    Text(
                      kategori['judul'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: kategori['border'],
                      ),
                    ),
                    // Deskripsi
                    Text(
                      kategori['deskripsi'],
                      style: TextStyle(
                        fontSize: 12,
                        color: kategori['border'].withOpacity(0.8),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Jumlah sub-materi
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${kategori['subMateri'].length} Materi',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: kategori['border'],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSubMateriView() {
    final kategoriData = _kategoriMateri.firstWhere(
      (k) => k['id'] == _selectedKategori,
    );

    return Column(
      children: [
        // Header kategori yang dipilih
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                kategoriData['warna'].withOpacity(0.9),
                kategoriData['warna'].withOpacity(0.7),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new),
                      color: Colors.white,
                      onPressed: () {
                        setState(() {
                          _selectedKategori = null;
                        });
                        _animationController.reset();
                        _animationController.forward();
                      },
                    ),
                    const SizedBox(width: 8),
                    Icon(kategoriData['icon'], size: 32, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            kategoriData['judul'],
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            kategoriData['deskripsi'],
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Daftar sub-materi
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: ListView.builder(
              itemCount: kategoriData['subMateri'].length,
              itemBuilder: (context, index) {
                final subMateri = kategoriData['subMateri'][index];
                return SubMateriCard(
                  judul: subMateri['judul'],
                  deskripsi: subMateri['deskripsi'],
                  estimasi: subMateri['estimasi'],
                  tingkat: subMateri['tingkat'],
                  icon: subMateri['icon'],
                  warna: kategoriData['warna'],
                  border: kategoriData['border'],
                  onTap: () {
                    // TODO: Navigasi ke halaman detail materi
                    Navigator.pushNamed(
                      context,
                      '/materi-detail',
                      arguments: {
                        'kategori': kategoriData,
                        'subMateri': subMateri,
                      },
                    );
                  },
                  delay: index * 100,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

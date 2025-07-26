import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CodeEditorPage extends StatefulWidget {
  const CodeEditorPage({Key? key}) : super(key: key);

  @override
  State<CodeEditorPage> createState() => _CodeEditorPageState();
}

class _CodeEditorPageState extends State<CodeEditorPage>
    with TickerProviderStateMixin {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _fileNameController = TextEditingController();
  String _output = '';
  bool _isRunning = false;
  String _currentLanguage = 'dart';
  List<Map<String, String>> _savedFiles = [];
  late AnimationController _runButtonController;
  late Animation<double> _runButtonAnimation;

  final Map<String, String> _codeTemplates = {
    'dart': '''void main() {
  print('Hello, World!');
  
  // Coba tulis kode Dart kamu di sini
  var nama = 'Programmer Cilik';
  print('Halo, \$nama!');
}''',
    'python': '''# Program Python untuk anak-anak
print("Hello, World!")

# Coba tulis kode Python kamu di sini
nama = "Programmer Cilik"
print(f"Halo, {nama}!")

# Latihan matematika
angka1 = 5
angka2 = 3
hasil = angka1 + angka2
print(f"{angka1} + {angka2} = {hasil}")''',
    'javascript': '''// Program JavaScript untuk anak-anak
console.log("Hello, World!");

// Coba tulis kode JavaScript kamu di sini
let nama = "Programmer Cilik";
console.log(\`Halo, \${nama}!\`);

// Latihan matematika
let angka1 = 5;
let angka2 = 3;
let hasil = angka1 + angka2;
console.log(\`\${angka1} + \${angka2} = \${hasil}\`);''',
  };

  @override
  void initState() {
    super.initState();
    _runButtonController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _runButtonAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _runButtonController, curve: Curves.easeInOut),
    );

    _loadSavedFiles();
    _codeController.text = _codeTemplates[_currentLanguage]!;
  }

  @override
  void dispose() {
    _runButtonController.dispose();
    _codeController.dispose();
    _fileNameController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedFiles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? savedFilesJson = prefs.getString('loop_code_files');
      if (savedFilesJson != null) {
        final List<dynamic> decoded = json.decode(savedFilesJson);
        if (mounted) {
          setState(() {
            _savedFiles = decoded
                .map((e) => Map<String, String>.from(e))
                .toList();
          });
        }
      }
    } catch (e) {
      print('Error loading saved files: $e');
    }
  }

  Future<void> _saveFile() async {
    if (_fileNameController.text.isEmpty) {
      _showSnackBar('Nama file tidak boleh kosong!', Colors.orange);
      return;
    }

    try {
      final newFile = {
        'name': _fileNameController.text,
        'language': _currentLanguage,
        'code': _codeController.text,
        'timestamp': DateTime.now().toIso8601String(),
      };

      if (mounted) {
        setState(() {
          _savedFiles.add(newFile);
        });
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('loop_code_files', json.encode(_savedFiles));

      _showSnackBar('File berhasil disimpan! 🎉', Colors.green);
      _fileNameController.clear();
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      _showSnackBar('Error menyimpan file: $e', Colors.red);
    }
  }

  void _loadFile(Map<String, String> file) {
    if (mounted) {
      setState(() {
        _codeController.text = file['code']!;
        _currentLanguage = file['language']!;
      });
    }
    _showSnackBar('File berhasil dimuat! 📁', Colors.blue);
  }

  void _deleteFile(int index) {
    if (mounted) {
      setState(() {
        _savedFiles.removeAt(index);
      });
    }
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('loop_code_files', json.encode(_savedFiles));
    });
    _showSnackBar('File berhasil dihapus! 🗑️', Colors.red);
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _runCode() async {
    if (mounted) {
      setState(() {
        _isRunning = true;
        _output = '';
      });
    }

    _runButtonController.forward().then((_) {
      _runButtonController.reverse();
    });

    // Simulasi running code (karena tidak bisa execute real code di Flutter)
    await Future.delayed(const Duration(milliseconds: 1500));

    // Simulasi output berdasarkan bahasa
    String simulatedOutput = _simulateCodeExecution(_codeController.text);

    if (mounted) {
      setState(() {
        _output = simulatedOutput;
        _isRunning = false;
      });
    }
  }

  String _simulateCodeExecution(String code) {
    // Simulasi sederhana untuk demo
    if (code.contains('print(') ||
        code.contains('console.log') ||
        code.contains('printf')) {
      return '''🎉 Kode berhasil dijalankan!

Hello, World!
Halo, Programmer Cilik!
5 + 3 = 8

✨ Selamat! Kode kamu berjalan dengan baik!''';
    } else if (code.trim().isEmpty) {
      return '''❌ Error: Kode kosong!

Coba tulis beberapa baris kode dulu ya! 😊''';
    } else {
      return '''✅ Kode berhasil dijalankan!

Output akan muncul di sini ketika kamu menjalankan kode.
Pastikan kamu menggunakan fungsi print() atau console.log()!''';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D2D44),
        title: const Text(
          '🧑‍💻 Code Editor',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_open, color: Colors.white),
            onPressed: _showFileManager,
          ),
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: _showSaveDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Language Selector
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  'Bahasa: ',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D2D44),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: _currentLanguage,
                    dropdownColor: const Color(0xFF2D2D44),
                    style: const TextStyle(color: Colors.white),
                    underline: Container(),
                    items: [
                      DropdownMenuItem(
                        value: 'dart',
                        child: Row(
                          children: [
                            Icon(Icons.code, color: Colors.blue[300]),
                            const SizedBox(width: 8),
                            const Text('Dart'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'python',
                        child: Row(
                          children: [
                            Icon(Icons.code, color: Colors.green[300]),
                            const SizedBox(width: 8),
                            const Text('Python'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'javascript',
                        child: Row(
                          children: [
                            Icon(Icons.code, color: Colors.yellow[300]),
                            const SizedBox(width: 8),
                            const Text('JavaScript'),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      if (mounted) {
                        setState(() {
                          _currentLanguage = value!;
                          _codeController.text = _codeTemplates[value]!;
                        });
                      }
                    },
                  ),
                ),
                const Spacer(),
                // Run Button
                ScaleTransition(
                  scale: _runButtonAnimation,
                  child: ElevatedButton.icon(
                    onPressed: _isRunning ? null : _runCode,
                    icon: _isRunning
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Icon(Icons.play_arrow, color: Colors.white),
                    label: Text(
                      _isRunning ? 'Running...' : 'Jalankan',
                      style: const TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Code Editor
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF2D2D44),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[600]!),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E2E),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Colors.yellow,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'main.${_currentLanguage}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _codeController,
                      maxLines: null,
                      expands: true,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'Courier',
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Tulis kode kamu di sini...',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Output Console
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F0F0F),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[600]!),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E2E),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.terminal,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Output Console',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(
                            Icons.clear,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () {
                            if (mounted) {
                              setState(() {
                                _output = '';
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      child: SingleChildScrollView(
                        child: Text(
                          _output.isEmpty
                              ? 'Output akan muncul di sini setelah kamu menjalankan kode! 🚀'
                              : _output,
                          style: TextStyle(
                            color: _output.isEmpty
                                ? Colors.grey
                                : Colors.greenAccent,
                            fontSize: 14,
                            fontFamily: 'Courier',
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSaveDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D44),
        title: const Text(
          '💾 Simpan File',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: _fileNameController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Masukkan nama file...',
            hintStyle: const TextStyle(color: Colors.grey),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.blue),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: _saveFile,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showFileManager() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D44),
        title: const Text(
          '📁 File Manager',
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: _savedFiles.isEmpty
              ? const Center(
                  child: Text(
                    'Belum ada file tersimpan',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: _savedFiles.length,
                  itemBuilder: (context, index) {
                    final file = _savedFiles[index];
                    return Card(
                      color: const Color(0xFF1E1E2E),
                      child: ListTile(
                        leading: Icon(
                          Icons.code_outlined,
                          color: file['language'] == 'html'
                              ? Colors.blue[300]
                              : file['language'] == 'css'
                              ? Colors.green[300]
                              : Colors.yellow[300],
                        ),
                        title: Text(
                          file['name']!,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          file['language']!.toUpperCase(),
                          style: const TextStyle(color: Colors.grey),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.open_in_new,
                                color: Colors.blue,
                              ),
                              onPressed: () {
                                _loadFile(file);
                                Navigator.pop(context);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteFile(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// lib/pages/admin/admin_materi_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
// import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

class AdminMateriPage extends StatefulWidget {
  @override
  _AdminMateriPageState createState() => _AdminMateriPageState();
}

class _AdminMateriPageState extends State<AdminMateriPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('materi')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final materiDocs = snapshot.data!.docs;

          if (materiDocs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.book_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Belum ada materi',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: materiDocs.length,
            itemBuilder: (context, index) {
              final doc = materiDocs[index];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                margin: EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue[100],
                    child: Icon(Icons.book, color: Colors.blue[800]),
                  ),
                  title: Text(data['title'] ?? 'No Title'),
                  subtitle: Text(
                    data['description'] ?? 'No Description',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.orange),
                        onPressed: () => _editMateri(context, doc.id, data),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteMateri(context, doc.id, data),
                      ),
                    ],
                  ),
                  onTap: () => _viewMateri(context, data),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addMateri(context),
        child: Icon(Icons.add),
        backgroundColor: Colors.blue[800],
      ),
    );
  }

  void _addMateri(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEditMateriPage()),
    );
  }

  void _editMateri(BuildContext context, String id, Map<String, dynamic> data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditMateriPage(materiId: id, materiData: data),
      ),
    );
  }

  void _viewMateri(BuildContext context, Map<String, dynamic> data) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ViewMateriPage(data: data)),
    );
  }

  void _deleteMateri(
    BuildContext context,
    String id,
    Map<String, dynamic> data,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Hapus Materi'),
          content: Text(
            'Apakah Anda yakin ingin menghapus materi "${data['title']}"?',
          ),
          actions: [
            TextButton(
              child: Text('Batal'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Hapus', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                try {
                  // Delete associated files from storage
                  final files = data['files'] as List<dynamic>? ?? [];
                  for (var file in files) {
                    if (file['downloadUrl'] != null) {
                      try {
                        await _storage.refFromURL(file['downloadUrl']).delete();
                      } catch (e) {
                        print('Error deleting file: $e');
                      }
                    }
                  }

                  // Delete document
                  await _firestore.collection('materi').doc(id).delete();

                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Materi berhasil dihapus')),
                  );
                } catch (e) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
            ),
          ],
        );
      },
    );
  }
}

class AddEditMateriPage extends StatefulWidget {
  final String? materiId;
  final Map<String, dynamic>? materiData;

  AddEditMateriPage({this.materiId, this.materiData});

  @override
  _AddEditMateriPageState createState() => _AddEditMateriPageState();
}

class _AddEditMateriPageState extends State<AddEditMateriPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contentController = TextEditingController();

  List<Map<String, dynamic>> _files = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.materiData != null) {
      _titleController.text = widget.materiData!['title'] ?? '';
      _descriptionController.text = widget.materiData!['description'] ?? '';
      _contentController.text = widget.materiData!['content'] ?? '';
      _files = List<Map<String, dynamic>>.from(
        widget.materiData!['files'] ?? [],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.materiId == null ? 'Tambah Materi' : 'Edit Materi'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveMateri,
            child: Text('SIMPAN', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.all(16),
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Judul Materi',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Judul tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Deskripsi',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Deskripsi tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _contentController,
                    decoration: InputDecoration(
                      labelText: 'Konten Materi',
                      border: OutlineInputBorder(),
                      hintText: 'Tulis konten materi di sini...',
                    ),
                    maxLines: 10,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Konten tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Text(
                        'File & Media:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(),
                      ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: Icon(Icons.image),
                        label: Text('Gambar'),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _pickVideo,
                        icon: Icon(Icons.videocam),
                        label: Text('Video'),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _pickFile,
                        icon: Icon(Icons.attach_file),
                        label: Text('File'),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  _buildFilesList(),
                ],
              ),
            ),
    );
  }

  Widget _buildFilesList() {
    if (_files.isEmpty) {
      return Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Belum ada file yang ditambahkan',
          style: TextStyle(color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      children: _files.map((file) {
        return Card(
          child: ListTile(
            leading: _getFileIcon(file['type']),
            title: Text(file['name'] ?? 'Unknown'),
            subtitle: Text(
              '${file['type']} • ${_formatFileSize(file['size'] ?? 0)}',
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                setState(() {
                  _files.remove(file);
                });
              },
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _getFileIcon(String? type) {
    switch (type) {
      case 'image':
        return Icon(Icons.image, color: Colors.blue);
      case 'video':
        return Icon(Icons.videocam, color: Colors.red);
      default:
        return Icon(Icons.attach_file, color: Colors.grey);
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _files.add({
          'name': pickedFile.name,
          'type': 'image',
          'size': bytes.length,
          'data': bytes,
          'path': pickedFile.path,
        });
      });
    }
  }

  void _pickVideo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _files.add({
          'name': pickedFile.name,
          'type': 'video',
          'size': bytes.length,
          'data': bytes,
          'path': pickedFile.path,
        });
      });
    }
  }

  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      final file = result.files.first;
      setState(() {
        _files.add({
          'name': file.name,
          'type': 'file',
          'size': file.size,
          'data': file.bytes,
          'path': file.path,
        });
      });
    }
  }

  void _saveMateri() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Upload files
      List<Map<String, dynamic>> uploadedFiles = [];

      for (var file in _files) {
        // Skip already uploaded files
        if (file.containsKey('downloadUrl')) {
          uploadedFiles.add(file);
          continue;
        }

        String fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${file['name']}';
        String filePath = 'materi/${file['type']}s/$fileName';

        UploadTask uploadTask;
        if (kIsWeb) {
          uploadTask = FirebaseStorage.instance
              .ref(filePath)
              .putData(file['data']);
        } else {
          uploadTask = FirebaseStorage.instance
              .ref(filePath)
              .putFile(File(file['path']));
        }

        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();

        uploadedFiles.add({
          'name': file['name'],
          'type': file['type'],
          'size': file['size'],
          'downloadUrl': downloadUrl,
        });
      }

      // Save to Firestore
      Map<String, dynamic> materiData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'content': _contentController.text,
        'files': uploadedFiles,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (widget.materiId == null) {
        materiData['createdAt'] = FieldValue.serverTimestamp();
        await FirebaseFirestore.instance.collection('materi').add(materiData);
      } else {
        await FirebaseFirestore.instance
            .collection('materi')
            .doc(widget.materiId)
            .update(materiData);
      }

      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Materi berhasil disimpan')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}

class ViewMateriPage extends StatelessWidget {
  final Map<String, dynamic> data;

  ViewMateriPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(data['title'] ?? 'Materi'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Text(
            data['title'] ?? 'No Title',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            data['description'] ?? 'No Description',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          SizedBox(height: 20),
          Text(
            'Konten:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(data['content'] ?? 'No Content'),
          SizedBox(height: 20),
          if (data['files'] != null && (data['files'] as List).isNotEmpty) ...[
            Text(
              'File & Media:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            ...((data['files'] as List).map((file) {
              return Card(
                child: ListTile(
                  leading: _getFileIcon(file['type']),
                  title: Text(file['name'] ?? 'Unknown'),
                  subtitle: Text(file['type'] ?? 'Unknown type'),
                  trailing: Icon(Icons.download),
                  onTap: () {
                    // TODO: Implement file download/view
                  },
                ),
              );
            }).toList()),
          ],
        ],
      ),
    );
  }

  Widget _getFileIcon(String? type) {
    switch (type) {
      case 'image':
        return Icon(Icons.image, color: Colors.blue);
      case 'video':
        return Icon(Icons.videocam, color: Colors.red);
      default:
        return Icon(Icons.attach_file, color: Colors.grey);
    }
  }
}

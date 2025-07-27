// lib/pages/admin/admin_quiz_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminQuizPage extends StatefulWidget {
  @override
  _AdminQuizPageState createState() => _AdminQuizPageState();
}

class _AdminQuizPageState extends State<AdminQuizPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('quiz')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final quizDocs = snapshot.data!.docs;

          if (quizDocs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.quiz_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Belum ada quiz',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: quizDocs.length,
            itemBuilder: (context, index) {
              final doc = quizDocs[index];
              final data = doc.data() as Map<String, dynamic>;
              final questions = data['questions'] as List<dynamic>? ?? [];

              return Card(
                margin: EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green[100],
                    child: Icon(Icons.quiz, color: Colors.green[800]),
                  ),
                  title: Text(data['title'] ?? 'No Title'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['description'] ?? 'No Description'),
                      SizedBox(height: 4),
                      Text(
                        '${questions.length} pertanyaan • ${data['timeLimit'] ?? 0} menit',
                        style: TextStyle(color: Colors.blue[600], fontSize: 12),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.visibility, color: Colors.blue),
                        onPressed: () => _viewQuiz(context, data),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.orange),
                        onPressed: () => _editQuiz(context, doc.id, data),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteQuiz(context, doc.id, data),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addQuiz(context),
        child: Icon(Icons.add),
        backgroundColor: Colors.green[800],
      ),
    );
  }

  void _addQuiz(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEditQuizPage()),
    );
  }

  void _editQuiz(BuildContext context, String id, Map<String, dynamic> data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditQuizPage(quizId: id, quizData: data),
      ),
    );
  }

  void _viewQuiz(BuildContext context, Map<String, dynamic> data) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ViewQuizPage(data: data)),
    );
  }

  void _deleteQuiz(BuildContext context, String id, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Hapus Quiz'),
          content: Text(
            'Apakah Anda yakin ingin menghapus quiz "${data['title']}"?',
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
                  await _firestore.collection('quiz').doc(id).delete();
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Quiz berhasil dihapus')),
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

class AddEditQuizPage extends StatefulWidget {
  final String? quizId;
  final Map<String, dynamic>? quizData;

  AddEditQuizPage({this.quizId, this.quizData});

  @override
  _AddEditQuizPageState createState() => _AddEditQuizPageState();
}

class _AddEditQuizPageState extends State<AddEditQuizPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _timeLimitController = TextEditingController();

  List<Map<String, dynamic>> _questions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.quizData != null) {
      _titleController.text = widget.quizData!['title'] ?? '';
      _descriptionController.text = widget.quizData!['description'] ?? '';
      _timeLimitController.text = (widget.quizData!['timeLimit'] ?? 0)
          .toString();
      _questions = List<Map<String, dynamic>>.from(
        widget.quizData!['questions'] ?? [],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quizId == null ? 'Tambah Quiz' : 'Edit Quiz'),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveQuiz,
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
                      labelText: 'Judul Quiz',
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
                    controller: _timeLimitController,
                    decoration: InputDecoration(
                      labelText: 'Batas Waktu (menit)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Batas waktu tidak boleh kosong';
                      }
                      if (int.tryParse(value) == null ||
                          int.parse(value) <= 0) {
                        return 'Batas waktu harus berupa angka positif';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Text(
                        'Pertanyaan:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(),
                      ElevatedButton.icon(
                        onPressed: _addQuestion,
                        icon: Icon(Icons.add),
                        label: Text('Tambah Pertanyaan'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[800],
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  _buildQuestionsList(),
                ],
              ),
            ),
    );
  }

  Widget _buildQuestionsList() {
    if (_questions.isEmpty) {
      return Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Belum ada pertanyaan yang ditambahkan',
          style: TextStyle(color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      children: _questions.asMap().entries.map((entry) {
        int index = entry.key;
        Map<String, dynamic> question = entry.value;

        return Card(
          margin: EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Pertanyaan ${index + 1}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.orange),
                      onPressed: () => _editQuestion(index),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteQuestion(index),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(question['question'] ?? 'No Question'),
                SizedBox(height: 8),
                ...((question['options'] as List<dynamic>? ?? [])
                    .asMap()
                    .entries
                    .map((optionEntry) {
                      int optionIndex = optionEntry.key;
                      String option = optionEntry.value;
                      bool isCorrect = question['correctAnswer'] == optionIndex;

                      return Padding(
                        padding: EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Icon(
                              isCorrect
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: isCorrect ? Colors.green : Colors.grey,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Expanded(child: Text(option)),
                          ],
                        ),
                      );
                    })
                    .toList()),
                if (question['explanation'] != null &&
                    question['explanation'].isNotEmpty) ...[
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue, size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Penjelasan: ${question['explanation']}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _addQuestion() {
    _showQuestionDialog();
  }

  void _editQuestion(int index) {
    _showQuestionDialog(questionIndex: index);
  }

  void _deleteQuestion(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Hapus Pertanyaan'),
          content: Text('Apakah Anda yakin ingin menghapus pertanyaan ini?'),
          actions: [
            TextButton(
              child: Text('Batal'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Hapus', style: TextStyle(color: Colors.red)),
              onPressed: () {
                setState(() {
                  _questions.removeAt(index);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showQuestionDialog({int? questionIndex}) {
    final questionController = TextEditingController();
    final explanationController = TextEditingController();
    List<TextEditingController> optionControllers = [
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
    ];
    int correctAnswer = 0;

    // If editing, populate with existing data
    if (questionIndex != null) {
      final question = _questions[questionIndex];
      questionController.text = question['question'] ?? '';
      explanationController.text = question['explanation'] ?? '';
      correctAnswer = question['correctAnswer'] ?? 0;

      final options = question['options'] as List<dynamic>? ?? [];
      for (int i = 0; i < options.length && i < 4; i++) {
        optionControllers[i].text = options[i];
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                questionIndex == null ? 'Tambah Pertanyaan' : 'Edit Pertanyaan',
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: questionController,
                      decoration: InputDecoration(
                        labelText: 'Pertanyaan',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    SizedBox(height: 16),
                    ...optionControllers.asMap().entries.map((entry) {
                      int index = entry.key;
                      TextEditingController controller = entry.value;

                      return Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Radio<int>(
                              value: index,
                              groupValue: correctAnswer,
                              onChanged: (value) {
                                setDialogState(() {
                                  correctAnswer = value!;
                                });
                              },
                            ),
                            Expanded(
                              child: TextField(
                                controller: controller,
                                decoration: InputDecoration(
                                  labelText:
                                      'Pilihan ${String.fromCharCode(65 + index)}',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    SizedBox(height: 16),
                    TextField(
                      controller: explanationController,
                      decoration: InputDecoration(
                        labelText: 'Penjelasan (opsional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text('Batal'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: Text('Simpan'),
                  onPressed: () {
                    if (questionController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Pertanyaan tidak boleh kosong'),
                        ),
                      );
                      return;
                    }

                    // Check if all options are filled
                    bool allOptionsFilled = optionControllers.every(
                      (controller) => controller.text.isNotEmpty,
                    );
                    if (!allOptionsFilled) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Semua pilihan harus diisi')),
                      );
                      return;
                    }

                    Map<String, dynamic> questionData = {
                      'question': questionController.text,
                      'options': optionControllers
                          .map((controller) => controller.text)
                          .toList(),
                      'correctAnswer': correctAnswer,
                      'explanation': explanationController.text,
                    };

                    setState(() {
                      if (questionIndex == null) {
                        _questions.add(questionData);
                      } else {
                        _questions[questionIndex] = questionData;
                      }
                    });

                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _saveQuiz() async {
    if (!_formKey.currentState!.validate()) return;

    if (_questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Quiz harus memiliki minimal 1 pertanyaan')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, dynamic> quizData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'timeLimit': int.parse(_timeLimitController.text),
        'questions': _questions,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (widget.quizId == null) {
        quizData['createdAt'] = FieldValue.serverTimestamp();
        await FirebaseFirestore.instance.collection('quiz').add(quizData);
      } else {
        await FirebaseFirestore.instance
            .collection('quiz')
            .doc(widget.quizId)
            .update(quizData);
      }

      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Quiz berhasil disimpan')));
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
    _timeLimitController.dispose();
    super.dispose();
  }
}

class ViewQuizPage extends StatelessWidget {
  final Map<String, dynamic> data;

  ViewQuizPage({required this.data});

  @override
  Widget build(BuildContext context) {
    final questions = data['questions'] as List<dynamic>? ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(data['title'] ?? 'Quiz'),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.timer, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Batas Waktu: ${data['timeLimit'] ?? 0} menit'),
                      SizedBox(width: 20),
                      Icon(Icons.quiz, color: Colors.green),
                      SizedBox(width: 8),
                      Text('${questions.length} Pertanyaan'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Pertanyaan:',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          ...questions.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, dynamic> question = entry.value;

            return Card(
              margin: EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pertanyaan ${index + 1}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      question['question'] ?? 'No Question',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 12),
                    ...((question['options'] as List<dynamic>? ?? [])
                        .asMap()
                        .entries
                        .map((optionEntry) {
                          int optionIndex = optionEntry.key;
                          String option = optionEntry.value;
                          bool isCorrect =
                              question['correctAnswer'] == optionIndex;

                          return Container(
                            margin: EdgeInsets.only(bottom: 8),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isCorrect
                                  ? Colors.green[50]
                                  : Colors.grey[50],
                              border: Border.all(
                                color: isCorrect
                                    ? Colors.green
                                    : Colors.grey[300]!,
                                width: isCorrect ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  '${String.fromCharCode(65 + optionIndex)}.',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(width: 8),
                                Expanded(child: Text(option)),
                                if (isCorrect)
                                  Icon(Icons.check_circle, color: Colors.green),
                              ],
                            ),
                          );
                        })
                        .toList()),
                    if (question['explanation'] != null &&
                        question['explanation'].isNotEmpty) ...[
                      SizedBox(height: 12),
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Penjelasan:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[800],
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    question['explanation'],
                                    style: TextStyle(color: Colors.blue[800]),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

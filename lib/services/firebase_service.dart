// lib/services/firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // ============== AUTHENTICATION METHODS ==============

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Create user with email and password
  Future<UserCredential> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Gagal logout: ${e.toString()}');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Get user data from Firestore
  Future<DocumentSnapshot> getUserData(String uid) async {
    try {
      return await _firestore.collection('users').doc(uid).get();
    } catch (e) {
      throw Exception('Gagal mengambil data user: ${e.toString()}');
    }
  }

  // ============== USER MANAGEMENT METHODS ==============

  // Update user data in Firestore
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      throw Exception('Gagal mengupdate data user: ${e.toString()}');
    }
  }

  // Create user document in Firestore
  Future<void> createUserDocument(
    String uid,
    Map<String, dynamic> userData,
  ) async {
    try {
      await _firestore.collection('users').doc(uid).set(userData);
    } catch (e) {
      throw Exception('Gagal membuat dokumen user: ${e.toString()}');
    }
  }

  // Check if user is admin
  Future<bool> isAdmin(String uid) async {
    try {
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      if (userDoc.exists) {
        return userDoc.get('role') == 'admin';
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Get all users (admin only)
  Stream<QuerySnapshot> getAllUsers() {
    return _firestore.collection('users').snapshots();
  }

  // Delete user (admin only)
  Future<void> deleteUser(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).delete();
    } catch (e) {
      throw Exception('Gagal menghapus user: ${e.toString()}');
    }
  }

  // Update user role (admin only)
  Future<void> updateUserRole(String uid, String role) async {
    try {
      await _firestore.collection('users').doc(uid).update({'role': role});
    } catch (e) {
      throw Exception('Gagal mengupdate role user: ${e.toString()}');
    }
  }

  // ============== EMAIL VERIFICATION & PROFILE METHODS ==============

  // Check email verification status
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  // Send email verification
  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } catch (e) {
      throw Exception('Gagal mengirim email verifikasi: ${e.toString()}');
    }
  }

  // Reload current user
  Future<void> reloadUser() async {
    try {
      await _auth.currentUser?.reload();
    } catch (e) {
      throw Exception('Gagal memuat ulang user: ${e.toString()}');
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      await _auth.currentUser?.updateDisplayName(displayName);
      if (photoURL != null) {
        await _auth.currentUser?.updatePhotoURL(photoURL);
      }
    } catch (e) {
      throw Exception('Gagal mengupdate profil: ${e.toString()}');
    }
  }

  // Change password
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Re-authenticate user
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(credential);

        // Update password
        await user.updatePassword(newPassword);
      }
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Delete current user account
  Future<void> deleteCurrentUser(String password) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Re-authenticate user
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);

        // Delete user document from Firestore
        await _firestore.collection('users').doc(user.uid).delete();

        // Delete user account
        await user.delete();
      }
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // ============== ERROR HANDLING ==============

  // Handle authentication exceptions
  String _handleAuthException(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return 'User tidak ditemukan';
        case 'wrong-password':
          return 'Password salah';
        case 'email-already-in-use':
          return 'Email sudah digunakan';
        case 'weak-password':
          return 'Password terlalu lemah';
        case 'invalid-email':
          return 'Format email tidak valid';
        case 'user-disabled':
          return 'Akun telah dinonaktifkan';
        case 'too-many-requests':
          return 'Terlalu banyak percobaan. Coba lagi nanti';
        case 'operation-not-allowed':
          return 'Operasi tidak diizinkan';
        default:
          return 'Terjadi kesalahan: ${e.message}';
      }
    }
    return 'Terjadi kesalahan yang tidak diketahui';
  }

  // ============== MATERI MANAGEMENT ==============

  static Future<List<Map<String, dynamic>>> getAllMateri() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('materi')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw e;
    }
  }

  static Future<Map<String, dynamic>?> getMateriById(String id) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('materi')
          .doc(id)
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }
      return null;
    } catch (e) {
      throw e;
    }
  }

  static Future<String> createMateri(Map<String, dynamic> materiData) async {
    try {
      materiData['createdAt'] = FieldValue.serverTimestamp();
      materiData['updatedAt'] = FieldValue.serverTimestamp();

      DocumentReference docRef = await _firestore
          .collection('materi')
          .add(materiData);
      return docRef.id;
    } catch (e) {
      throw e;
    }
  }

  static Future<void> updateMateri(
    String id,
    Map<String, dynamic> materiData,
  ) async {
    try {
      materiData['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore.collection('materi').doc(id).update(materiData);
    } catch (e) {
      throw e;
    }
  }

  static Future<void> deleteMateri(String id) async {
    try {
      await _firestore.collection('materi').doc(id).delete();
    } catch (e) {
      throw e;
    }
  }

  // ============== QUIZ MANAGEMENT ==============

  static Future<List<Map<String, dynamic>>> getAllQuiz() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('quiz')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw e;
    }
  }

  static Future<Map<String, dynamic>?> getQuizById(String id) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('quiz').doc(id).get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }
      return null;
    } catch (e) {
      throw e;
    }
  }

  static Future<String> createQuiz(Map<String, dynamic> quizData) async {
    try {
      quizData['createdAt'] = FieldValue.serverTimestamp();
      quizData['updatedAt'] = FieldValue.serverTimestamp();

      DocumentReference docRef = await _firestore
          .collection('quiz')
          .add(quizData);
      return docRef.id;
    } catch (e) {
      throw e;
    }
  }

  static Future<void> updateQuiz(
    String id,
    Map<String, dynamic> quizData,
  ) async {
    try {
      quizData['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore.collection('quiz').doc(id).update(quizData);
    } catch (e) {
      throw e;
    }
  }

  static Future<void> deleteQuiz(String id) async {
    try {
      await _firestore.collection('quiz').doc(id).delete();
    } catch (e) {
      throw e;
    }
  }

  // ============== QUIZ RESULTS MANAGEMENT ==============

  static Future<void> saveQuizResult({
    required String userId,
    required String quizId,
    required String quizTitle,
    required int score,
    required int totalQuestions,
    required List<Map<String, dynamic>> answers,
    required int timeSpent,
  }) async {
    try {
      await _firestore.collection('quiz_results').add({
        'userId': userId,
        'quizId': quizId,
        'quizTitle': quizTitle,
        'score': score,
        'totalQuestions': totalQuestions,
        'percentage': (score / totalQuestions * 100).round(),
        'answers': answers,
        'timeSpent': timeSpent,
        'completedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw e;
    }
  }

  static Future<List<Map<String, dynamic>>> getQuizResults({
    String? userId,
    String? quizId,
  }) async {
    try {
      Query query = _firestore.collection('quiz_results');

      if (userId != null) {
        query = query.where('userId', isEqualTo: userId);
      }

      if (quizId != null) {
        query = query.where('quizId', isEqualTo: quizId);
      }

      query = query.orderBy('completedAt', descending: true);

      QuerySnapshot snapshot = await query.get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw e;
    }
  }

  // ============== STATISTICS ==============

  static Future<Map<String, dynamic>> getStatistics() async {
    try {
      // Get total counts
      int totalMateri =
          (await _firestore.collection('materi').get()).docs.length;
      int totalQuiz = (await _firestore.collection('quiz').get()).docs.length;
      int totalQuizResults =
          (await _firestore.collection('quiz_results').get()).docs.length;

      // Get recent quiz results for average score
      QuerySnapshot recentResults = await _firestore
          .collection('quiz_results')
          .orderBy('completedAt', descending: true)
          .limit(100)
          .get();

      double averageScore = 0;
      if (recentResults.docs.isNotEmpty) {
        double totalScore = 0;
        for (var doc in recentResults.docs) {
          totalScore += (doc.data() as Map<String, dynamic>)['percentage'] ?? 0;
        }
        averageScore = totalScore / recentResults.docs.length;
      }

      return {
        'totalMateri': totalMateri,
        'totalQuiz': totalQuiz,
        'totalQuizResults': totalQuizResults,
        'averageScore': averageScore.round(),
      };
    } catch (e) {
      throw e;
    }
  }

  // ============== FILE MANAGEMENT HELPER ==============

  static String getFileTypeFromExtension(String fileName) {
    String extension = fileName.toLowerCase().split('.').last;

    // Image extensions
    if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension)) {
      return 'image';
    }

    // Video extensions
    if ([
      'mp4',
      'avi',
      'mov',
      'wmv',
      'flv',
      'webm',
      'mkv',
    ].contains(extension)) {
      return 'video';
    }

    // Document extensions
    if (['pdf', 'doc', 'docx', 'txt', 'rtf'].contains(extension)) {
      return 'document';
    }

    // Presentation extensions
    if (['ppt', 'pptx'].contains(extension)) {
      return 'presentation';
    }

    // Spreadsheet extensions
    if (['xls', 'xlsx', 'csv'].contains(extension)) {
      return 'spreadsheet';
    }

    // Archive extensions
    if (['zip', 'rar', '7z', 'tar', 'gz'].contains(extension)) {
      return 'archive';
    }

    return 'file';
  }

  // ============== USER PROGRESS TRACKING ==============

  static Future<void> updateUserProgress({
    required String userId,
    required String materiId,
    required String materiTitle,
    required double progress,
  }) async {
    try {
      await _firestore
          .collection('user_progress')
          .doc('${userId}_$materiId')
          .set({
            'userId': userId,
            'materiId': materiId,
            'materiTitle': materiTitle,
            'progress': progress,
            'lastAccessed': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
    } catch (e) {
      throw e;
    }
  }

  static Future<List<Map<String, dynamic>>> getUserProgress(
    String userId,
  ) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('user_progress')
          .where('userId', isEqualTo: userId)
          .orderBy('lastAccessed', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw e;
    }
  }
}

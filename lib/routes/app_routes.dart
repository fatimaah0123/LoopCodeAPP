import 'package:flutter/material.dart';
import '../pages/dashboard/dashboard_page.dart';
import '../pages/materi/materi_page.dart';
import '../pages/materi/materi_detail_page.dart';
import '../pages/quiz/solo_quiz_page.dart';
import '../pages/quiz/battle_quiz_page.dart';
import '../pages/editor/code_editor_page.dart';

// TODO: Tambahkan import untuk halaman lainnya sesuai kebutuhan

class AppRoutes {
  static final routes = {
    // '/': (context) => const DashboardPage(),
    '/materi': (context) => const MateriPage(),
    '/materi-detail': (context) => const MateriDetailPage(),
    '/solo-quiz': (context) => const SoloQuizPage(),
    '/battle-quiz': (context) => const BattleQuizPage(),
    '/code-editor': (context) => const CodeEditorPage(),
  };

  // Method untuk navigasi dengan parameter
  static void navigateToMateriDetail(
    BuildContext context, {
    required Map<String, dynamic> kategori,
    required Map<String, dynamic> subMateri,
  }) {
    Navigator.pushNamed(
      context,
      '/materi-detail',
      arguments: {'kategori': kategori, 'subMateri': subMateri},
    );
  }

  // Method untuk navigasi sederhana
  static void navigateToMateri(BuildContext context) {
    Navigator.pushNamed(context, '/materi');
  }

  // Method untuk kembali ke dashboard
  static void navigateToDashboard(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  // Method untuk navigasi ke Solo Quiz
  static void navigateToSoloQuiz(BuildContext context) {
    Navigator.pushNamed(context, '/solo-quiz');
  }

  // Method untuk navigasi ke Battle Quiz
  static void navigateToBattleQuiz(BuildContext context) {
    Navigator.pushNamed(context, '/battle-quiz');
  }

  // Method untuk navigasi ke Code Editor
  static void navigateToCodeEditor(BuildContext context) {
    Navigator.pushNamed(context, '/code-editor');
  }
}

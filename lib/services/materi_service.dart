import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/materi_model.dart';

class MateriService {
  final _ref = FirebaseFirestore.instance.collection('materi');

  Future<void> tambah(MateriModel materi) => _ref.add(materi.toMap());
  Future<void> update(String id, MateriModel materi) =>
      _ref.doc(id).update(materi.toMap());
  Future<void> hapus(String id) => _ref.doc(id).delete();
  Stream<List<MateriModel>> ambilSemua() => _ref.snapshots().map(
    (snapshot) => snapshot.docs
        .map((doc) => MateriModel.fromMap(doc.data(), doc.id))
        .toList(),
  );
}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/atendimento.dart';

class RecepcaoRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Função para guardar o atendimento na base de dados
  Future<void> adicionarAtendimento(Atendimento atendimento) async {
    await _firestore
        .collection('atendimentos')
        .doc(atendimento.id)
        .set(atendimento.toMap());
  }
}

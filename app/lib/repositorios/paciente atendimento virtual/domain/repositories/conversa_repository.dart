import '../entities/mensagem_paciente.dart';
import '../entities/resposta_chatbot.dart';

abstract interface class ConversaRepository {
  List<MensagemPaciente> listar();
  void adicionar(MensagemPaciente mensagem);

  Future<RespostaChatbot> responder(String texto);
}

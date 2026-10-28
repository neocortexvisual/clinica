import '../entities/mensagem_paciente.dart';

abstract interface class ConversaRepository {
  List<MensagemPaciente> listar();
  void adicionar(MensagemPaciente mensagem);
}

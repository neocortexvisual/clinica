import '../../domain/entities/mensagem_paciente.dart';
import '../../domain/repositories/conversa_repository.dart';

/// Armazena somente a demonstração local; não envia dados a um servidor.
class ConversaLocalRepository implements ConversaRepository {
  final List<MensagemPaciente> _mensagens = [];

  @override
  List<MensagemPaciente> listar() => List.unmodifiable(_mensagens);

  @override
  void adicionar(MensagemPaciente mensagem) => _mensagens.add(mensagem);
}

import 'resposta_chatbot.dart';

enum AutorMensagem { paciente, assistente }

class MensagemPaciente {
  const MensagemPaciente({
    required this.texto,
    this.nomeAnexo,
    this.autor = AutorMensagem.paciente,
    this.opcoes = const [],
  });

  final String texto;
  final String? nomeAnexo;
  final AutorMensagem autor;
  final List<OpcaoAtendimento> opcoes;
}

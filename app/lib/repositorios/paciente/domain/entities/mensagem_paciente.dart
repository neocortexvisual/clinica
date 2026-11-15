class MensagemPaciente {
  const MensagemPaciente({
    required this.texto,
    this.nomeAnexo,
    this.doPaciente = true,
    this.opcoes = const [],
  });

  final String texto;
  final String? nomeAnexo;
  final bool doPaciente;
  final List<String> opcoes;
}

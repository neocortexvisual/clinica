class OpcaoAtendimento {
  const OpcaoAtendimento({required this.id, required this.descricao});

  final String id;
  final String descricao;
}

class RespostaChatbot {
  const RespostaChatbot({
    required this.etapa,
    required this.mensagem,
    this.opcoes = const [],
    this.atendimentoSelecionado,
  });

  final String etapa;
  final String mensagem;
  final List<OpcaoAtendimento> opcoes;
  final OpcaoAtendimento? atendimentoSelecionado;
}

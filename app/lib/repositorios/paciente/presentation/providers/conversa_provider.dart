import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/conversa_local_repository.dart';
import '../../data/services/chatbot_api.dart';
import '../../domain/entities/mensagem_paciente.dart';
import '../../domain/repositories/conversa_repository.dart';

final chatbotApiProvider = Provider<ChatbotApi>((ref) {
  final api = ChatbotApi();
  ref.onDispose(api.close);
  return api;
});

final conversaRepositoryProvider = Provider<ConversaRepository>(
  (ref) => ConversaLocalRepository(),
);

final conversaProvider = NotifierProvider<ConversaController, ConversaState>(
  ConversaController.new,
);

class ConversaState {
  const ConversaState({
    this.mensagens = const [],
    this.nomeAnexo,
    this.conversaId,
    this.carregando = false,
    this.erro,
  });

  final List<MensagemPaciente> mensagens;
  final String? nomeAnexo;
  final String? conversaId;
  final bool carregando;
  final String? erro;
}

class ConversaController extends Notifier<ConversaState> {
  @override
  ConversaState build() =>
      ConversaState(mensagens: ref.watch(conversaRepositoryProvider).listar());

  Future<void> iniciar() async {
    if (state.carregando || state.conversaId != null) return;
    state = ConversaState(mensagens: state.mensagens, carregando: true);
    try {
      final resposta = await ref.read(chatbotApiProvider).criarConversa();
      _adicionarResposta(resposta);
    } on Exception {
      state = ConversaState(
        mensagens: state.mensagens,
        carregando: false,
        erro: _mensagemDeErro,
      );
    }
  }

  void anexar(String? nome) {
    state = ConversaState(
      mensagens: state.mensagens,
      nomeAnexo: nome,
      conversaId: state.conversaId,
      carregando: state.carregando,
      erro: null,
    );
  }

  Future<bool> enviar(String texto) async {
    final conteudo = texto.trim();
    final conversaId = state.conversaId;
    if (conteudo.isEmpty && state.nomeAnexo == null) return false;
    if (state.carregando || conversaId == null) return false;
    if (state.nomeAnexo != null) {
      state = ConversaState(
        mensagens: state.mensagens,
        nomeAnexo: state.nomeAnexo,
        conversaId: conversaId,
        erro: 'O atendimento ainda não recebe arquivos. Remova o anexo para enviar.',
      );
      return false;
    }

    state = ConversaState(
      mensagens: state.mensagens,
      conversaId: conversaId,
      carregando: true,
    );
    try {
      final resposta = await ref
          .read(chatbotApiProvider)
          .enviarMensagem(conversaId, conteudo);
      final repository = ref.read(conversaRepositoryProvider);
      repository.adicionar(MensagemPaciente(texto: conteudo));
      _adicionarResposta(resposta);
      return true;
    } on Exception {
      state = ConversaState(
        mensagens: state.mensagens,
        conversaId: conversaId,
        carregando: false,
        erro: _mensagemDeErro,
      );
      return false;
    }
  }

  void _adicionarResposta(ChatbotResposta resposta) {
    final repository = ref.read(conversaRepositoryProvider);
    repository.adicionar(
      MensagemPaciente(
        texto: resposta.mensagem,
        doPaciente: false,
        opcoes: resposta.opcoes,
      ),
    );
    state = ConversaState(
      mensagens: repository.listar(),
      conversaId: resposta.conversaId,
    );
  }

  static const _mensagemDeErro =
      'Não foi possível acessar o atendimento. Confira se a API está em execução e tente novamente.';
}

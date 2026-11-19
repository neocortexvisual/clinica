import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../data/repositories/conversa_api_repository.dart';
import '../../domain/entities/mensagem_paciente.dart';
import '../../domain/entities/resposta_chatbot.dart';
import '../../domain/repositories/conversa_repository.dart';

final conversaRepositoryProvider = Provider<ConversaRepository>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return ConversaApiRepository(
    client: client,
    baseUrl: const String.fromEnvironment(
      'CHATBOT_API_URL',
      defaultValue: 'http://127.0.0.1:8000',
    ),
  );
});

final conversaProvider = NotifierProvider<ConversaController, ConversaState>(
  ConversaController.new,
);

class ConversaState {
  const ConversaState({
    this.mensagens = const [],
    this.nomeAnexo,
    this.enviando = false,
    this.erro,
    this.podeReenviar = false,
    this.ultimaResposta,
  });

  final List<MensagemPaciente> mensagens;
  final String? nomeAnexo;
  final bool enviando;
  final String? erro;
  final bool podeReenviar;
  final RespostaChatbot? ultimaResposta;
}

class ConversaController extends Notifier<ConversaState> {
  String? _textoPendente;

  @override
  ConversaState build() =>
      ConversaState(mensagens: ref.watch(conversaRepositoryProvider).listar());

  void anexar(String? nome) {
    if (state.enviando) return;
    state = ConversaState(
      mensagens: state.mensagens,
      nomeAnexo: nome,
      erro: state.erro,
      podeReenviar: state.podeReenviar,
      ultimaResposta: state.ultimaResposta,
    );
  }

  Future<bool> enviar(String texto, {String? textoExibido}) async {
    if (state.enviando) return false;
    final conteudo = texto.trim();
    if (conteudo.isEmpty || conteudo.length > 2000) {
      if (state.nomeAnexo != null || conteudo.length > 2000) {
        state = ConversaState(
          mensagens: state.mensagens,
          nomeAnexo: state.nomeAnexo,
          ultimaResposta: state.ultimaResposta,
          erro: conteudo.isEmpty
              ? 'Escreva uma mensagem. O atendimento ainda não recebe arquivos.'
              : 'Sua mensagem deve ter até 2.000 caracteres.',
        );
      }
      return false;
    }

    final repository = ref.read(conversaRepositoryProvider);
    repository.adicionar(
      MensagemPaciente(
        texto: textoExibido ?? conteudo,
        nomeAnexo: state.nomeAnexo,
      ),
    );
    _textoPendente = conteudo;
    state = ConversaState(
      mensagens: repository.listar(),
      enviando: true,
      ultimaResposta: state.ultimaResposta,
    );
    await _buscarResposta(repository, conteudo);
    // true indica que o envio foi aceito pela interface. Falhas ficam em erro.
    return true;
  }

  Future<void> tentarNovamente() async {
    if (state.enviando || !state.podeReenviar || _textoPendente == null) return;
    state = ConversaState(
      mensagens: state.mensagens,
      nomeAnexo: state.nomeAnexo,
      enviando: true,
      ultimaResposta: state.ultimaResposta,
    );
    await _buscarResposta(
      ref.read(conversaRepositoryProvider),
      _textoPendente!,
    );
  }

  Future<void> _buscarResposta(
    ConversaRepository repository,
    String texto,
  ) async {
    try {
      final resposta = await repository.responder(texto);
      if (!ref.mounted) return;
      repository.adicionar(
        MensagemPaciente(
          texto: resposta.mensagem,
          autor: AutorMensagem.assistente,
          opcoes: resposta.opcoes,
        ),
      );
      _textoPendente = null;
      state = ConversaState(
        mensagens: repository.listar(),
        nomeAnexo: state.nomeAnexo,
        ultimaResposta: resposta,
      );
    } on Exception {
      if (!ref.mounted) return;
      state = ConversaState(
        mensagens: repository.listar(),
        nomeAnexo: state.nomeAnexo,
        ultimaResposta: state.ultimaResposta,
        erro: 'Não foi possível falar com o atendimento. Tente novamente.',
        podeReenviar: true,
      );
    }
  }
}

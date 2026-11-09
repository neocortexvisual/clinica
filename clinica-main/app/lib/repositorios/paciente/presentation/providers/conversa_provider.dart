import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/conversa_local_repository.dart';
import '../../domain/entities/mensagem_paciente.dart';
import '../../domain/repositories/conversa_repository.dart';

final conversaRepositoryProvider = Provider<ConversaRepository>(
  (ref) => ConversaLocalRepository(),
);

final conversaProvider = NotifierProvider<ConversaController, ConversaState>(
  ConversaController.new,
);

class ConversaState {
  const ConversaState({this.mensagens = const [], this.nomeAnexo});

  final List<MensagemPaciente> mensagens;
  final String? nomeAnexo;
}

class ConversaController extends Notifier<ConversaState> {
  @override
  ConversaState build() =>
      ConversaState(mensagens: ref.watch(conversaRepositoryProvider).listar());

  void anexar(String? nome) {
    state = ConversaState(mensagens: state.mensagens, nomeAnexo: nome);
  }

  bool enviar(String texto) {
    final conteudo = texto.trim();
    if (conteudo.isEmpty && state.nomeAnexo == null) return false;

    final repository = ref.read(conversaRepositoryProvider);
    repository.adicionar(
      MensagemPaciente(texto: conteudo, nomeAnexo: state.nomeAnexo),
    );
    state = ConversaState(mensagens: repository.listar());
    return true;
  }
}

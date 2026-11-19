import 'package:app/repositorios/paciente%20atendimento%20virtual/domain/entities/mensagem_paciente.dart';
import 'package:app/repositorios/paciente%20atendimento%20virtual/presentation/providers/conversa_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'Riverpod conversa com o backend real e seleciona Psicólogo',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final controller = container.read(conversaProvider.notifier);
      await controller.enviar('Oi, boa tarde!');
      final inicio = container.read(conversaProvider);
      expect(inicio.erro, isNull);
      expect(inicio.mensagens.last.autor, AutorMensagem.assistente);
      expect(inicio.mensagens.last.texto, startsWith('Olá, boa tarde!'));
      expect(inicio.ultimaResposta!.opcoes, hasLength(4));
      await controller.enviar('psicologo');
      final escolhido = container.read(conversaProvider);
      expect(escolhido.erro, isNull);
      expect(escolhido.ultimaResposta!.etapa, 'atendimento_selecionado');
      expect(escolhido.ultimaResposta!.atendimentoSelecionado!.id, 'psicologo');
    },
    skip: !const bool.fromEnvironment('CHATBOT_INTEGRATION'),
  );
}

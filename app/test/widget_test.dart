import 'dart:convert';

import 'package:app/main.dart';
import 'package:app/repositorios/paciente/data/services/chatbot_api.dart';
import 'package:app/repositorios/paciente/presentation/providers/conversa_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

ChatbotApi _apiDeTeste() {
  return ChatbotApi(
    baseUri: Uri.parse('http://localhost:8000'),
    client: MockClient((request) async {
      if (request.url.path == '/conversas') {
        return http.Response(
          jsonEncode({
            'conversa_id': 'conversa-teste',
            'etapa': 'especialidade',
            'mensagem': 'Olá! Escolha uma especialidade:',
            'opcoes': [
              {'id': 'pediatria', 'descricao': 'Pediatria'},
              {'id': 'ginecologia', 'descricao': 'Ginecologia'},
            ],
          }),
          201,
        );
      }
      return http.Response(
        jsonEncode({
          'conversa_id': 'conversa-teste',
          'etapa': 'profissional',
          'mensagem': 'Escolha um profissional:',
          'opcoes': [
            {'id': 'luiza-rocha', 'descricao': 'Dra. Luiza Rocha'},
          ],
        }),
        200,
      );
    }),
  );
}

void main() {
  for (final size in [
    const Size(1920, 1080),
    const Size(390, 844),
    const Size(844, 390),
  ]) {
    testWidgets('Tela do paciente sem overflow em $size', (tester) async {
      final api = _apiDeTeste();
      addTearDown(api.close);
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [chatbotApiProvider.overrideWithValue(api)],
          child: const MyApp(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Clínica Vida & Saúde'), findsOneWidget);
      expect(find.text('Digite o número da opção...'), findsOneWidget);
      expect(find.text('1. Pediatria'), findsOneWidget);
      expect(tester.takeException(), isNull);
      final enviar = find.widgetWithIcon(IconButton, Icons.near_me_rounded);
      expect(tester.widget<IconButton>(enviar).onPressed, isNull);
      await tester.enterText(find.byType(TextField), '1');
      await tester.pump();
      await tester.testTextInput.receiveAction(TextInputAction.send);
      await tester.pumpAndSettle();
      expect(find.text('1', skipOffstage: false), findsOneWidget);
      expect(find.text('Escolha um profissional:'), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );
      expect(tester.takeException(), isNull);
    });
  }

  test('Controller exige texto e conversa com a API', () async {
    final api = _apiDeTeste();
    addTearDown(api.close);
    final container = ProviderContainer(
      overrides: [chatbotApiProvider.overrideWithValue(api)],
    );
    addTearDown(container.dispose);
    final controller = container.read(conversaProvider.notifier);

    await controller.iniciar();
    expect(await controller.enviar('   '), isFalse);
    controller.anexar('exame.pdf');
    expect(await controller.enviar('   '), isFalse);
    expect(
      container.read(conversaProvider).erro,
      contains('ainda não recebe arquivos'),
    );
    controller.anexar(null);
    expect(await controller.enviar('1'), isTrue);
    final state = container.read(conversaProvider);
    expect(
      state.mensagens.where((mensagem) => mensagem.doPaciente),
      hasLength(1),
    );
    expect(state.mensagens.last.texto, 'Escolha um profissional:');
    expect(state.mensagens.last.opcoes, ['Dra. Luiza Rocha']);
  });
}

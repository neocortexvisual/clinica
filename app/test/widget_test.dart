import 'dart:async';
import 'dart:convert';

import 'package:app/main.dart';
import 'package:app/repositorios/paciente%20atendimento%20virtual/data/repositories/conversa_api_repository.dart';
import 'package:app/repositorios/paciente%20atendimento%20virtual/domain/entities/mensagem_paciente.dart';
import 'package:app/repositorios/paciente%20atendimento%20virtual/presentation/providers/conversa_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

Map<String, Object?> respostaPara(String texto) {
  if (texto == 'psicologo' || texto == '2') {
    return {
      'etapa': 'atendimento_selecionado',
      'mensagem': 'Você escolheu atendimento com Psicólogo.',
      'opcoes': [],
      'atendimento_selecionado': {'id': 'psicologo', 'descricao': 'Psicólogo'},
    };
  }
  return {
    'etapa': 'especialidade',
    'mensagem': 'Olá, boa tarde! Qual atendimento você procura?',
    'opcoes': [
      {'id': 'oftalmologista', 'descricao': 'Oftalmologista'},
      {'id': 'psicologo', 'descricao': 'Psicólogo'},
      {'id': 'dermatologista', 'descricao': 'Dermatologista'},
      {'id': 'ortopedista', 'descricao': 'Ortopedista'},
    ],
    'atendimento_selecionado': null,
  };
}

http.Response respostaHttp(String texto) => http.Response.bytes(
  utf8.encode(jsonEncode(respostaPara(texto))),
  200,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

ConversaApiRepository repositorio(http.Client client) =>
    ConversaApiRepository(client: client, baseUrl: 'http://127.0.0.1:8000/');

void main() {
  for (final size in [
    const Size(1920, 1080),
    const Size(390, 844),
    const Size(844, 390),
  ]) {
    testWidgets('Conversa pela API e escolha por botão em $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final enviados = <String>[];
      final client = MockClient((request) async {
        final texto = (jsonDecode(request.body) as Map)['texto'] as String;
        enviados.add(texto);
        return respostaHttp(texto);
      });
      addTearDown(client.close);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            conversaRepositoryProvider.overrideWithValue(repositorio(client)),
          ],
          child: const MyApp(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Clínica Vida & Saúde'), findsOneWidget);
      final enviar = find.widgetWithIcon(IconButton, Icons.near_me_rounded);
      expect(tester.widget<IconButton>(enviar).onPressed, isNull);
      await tester.enterText(find.byType(TextField), 'Oi, boa tarde!');
      await tester.pump();
      await tester.tap(enviar);
      await tester.pumpAndSettle();
      expect(find.text('Oi, boa tarde!'), findsOneWidget);
      expect(
        find.text('Olá, boa tarde! Qual atendimento você procura?'),
        findsOneWidget,
      );
      expect(find.byType(ActionChip), findsNWidgets(4));
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );
      final psicologo = find.widgetWithText(ActionChip, 'Psicólogo');
      await tester.ensureVisible(psicologo);
      await tester.tap(psicologo);
      await tester.pumpAndSettle();
      expect(enviados, ['Oi, boa tarde!', 'psicologo']);
      expect(
        find.text('Você escolheu atendimento com Psicólogo.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  }

  test(
    'Repository envia JSON, decodifica UTF-8 e mapeia a resposta Python',
    () async {
      final client = MockClient((request) async {
        expect(request.method, 'POST');
        expect(
          request.url.toString(),
          'http://127.0.0.1:8000/chatbot/mensagens',
        );
        expect(request.headers['content-type'], contains('application/json'));
        expect(jsonDecode(request.body), {'texto': 'olá'});
        return respostaHttp('olá');
      });
      addTearDown(client.close);
      final resposta = await repositorio(client).responder('olá');
      expect(resposta.opcoes[1].descricao, 'Psicólogo');
      expect(resposta.etapa, 'especialidade');
    },
  );

  test(
    'Falha permite tentar novamente sem duplicar a mensagem do paciente',
    () async {
      var chamadas = 0;
      final client = MockClient((_) async {
        chamadas++;
        if (chamadas == 1) return http.Response('indisponível', 503);
        return respostaHttp('oi');
      });
      addTearDown(client.close);
      final container = ProviderContainer(
        overrides: [
          conversaRepositoryProvider.overrideWithValue(repositorio(client)),
        ],
      );
      addTearDown(container.dispose);
      final controller = container.read(conversaProvider.notifier);
      await controller.enviar('oi');
      expect(container.read(conversaProvider).mensagens, hasLength(1));
      expect(container.read(conversaProvider).podeReenviar, isTrue);
      await controller.tentarNovamente();
      final state = container.read(conversaProvider);
      expect(state.mensagens, hasLength(2));
      expect(state.mensagens.last.autor, AutorMensagem.assistente);
      expect(state.erro, isNull);
      expect(state.enviando, isFalse);
      expect(chamadas, 2);
    },
  );

  test(
    'Rejeita mensagem vazia e não envia um anexo isolado ao backend',
    () async {
      final client = MockClient(
        (_) async => throw StateError('Não deve chamar a API'),
      );
      addTearDown(client.close);
      final container = ProviderContainer(
        overrides: [
          conversaRepositoryProvider.overrideWithValue(repositorio(client)),
        ],
      );
      addTearDown(container.dispose);
      final controller = container.read(conversaProvider.notifier);
      expect(await controller.enviar('   '), isFalse);
      controller.anexar('exame.pdf');
      expect(await controller.enviar(''), isFalse);
      expect(container.read(conversaProvider).mensagens, isEmpty);
      expect(container.read(conversaProvider).nomeAnexo, 'exame.pdf');
      expect(
        container.read(conversaProvider).erro,
        contains('não recebe arquivos'),
      );
    },
  );

  test('Resposta inválida é tratada como erro de atendimento', () async {
    final client = MockClient(
      (_) async => http.Response('{"mensagem": 123}', 200),
    );
    addTearDown(client.close);
    final container = ProviderContainer(
      overrides: [
        conversaRepositoryProvider.overrideWithValue(repositorio(client)),
      ],
    );
    addTearDown(container.dispose);
    await container.read(conversaProvider.notifier).enviar('oi');
    final state = container.read(conversaProvider);
    expect(state.erro, isNotNull);
    expect(state.enviando, isFalse);
    expect(state.mensagens, hasLength(1));
  });

  testWidgets('Exibe espera e bloqueia envios até o backend responder', (
    tester,
  ) async {
    final resposta = Completer<http.Response>();
    var chamadas = 0;
    final client = MockClient((_) {
      chamadas++;
      return resposta.future;
    });
    addTearDown(client.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          conversaRepositoryProvider.overrideWithValue(repositorio(client)),
        ],
        child: const MyApp(),
      ),
    );
    await tester.enterText(find.byType(TextField), 'Oi');
    await tester.pump();
    final enviar = find.widgetWithIcon(IconButton, Icons.near_me_rounded);
    await tester.tap(enviar);
    await tester.pump();
    expect(find.text('Atendimento digitando...'), findsOneWidget);
    expect(tester.widget<IconButton>(enviar).onPressed, isNull);
    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
    expect(chamadas, 1);
    resposta.complete(respostaHttp('Oi'));
    await tester.pumpAndSettle();
    expect(find.text('Atendimento digitando...'), findsNothing);
    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isTrue);
  });

  test('Timeout encerra a espera e permite uma nova tentativa', () async {
    final client = MockClient((_) => Completer<http.Response>().future);
    addTearDown(client.close);
    final repository = ConversaApiRepository(
      client: client,
      baseUrl: 'http://127.0.0.1:8000',
      timeout: Duration.zero,
    );
    final container = ProviderContainer(
      overrides: [conversaRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    await container.read(conversaProvider.notifier).enviar('oi');
    final state = container.read(conversaProvider);
    expect(state.enviando, isFalse);
    expect(state.podeReenviar, isTrue);
    expect(state.erro, isNotNull);
  });
}

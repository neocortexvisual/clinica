import 'package:app/main.dart';
import 'package:app/repositorios/paciente/presentation/providers/conversa_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final size in [
    const Size(1920, 1080),
    const Size(390, 844),
    const Size(844, 390),
  ]) {
    testWidgets('Tela do paciente sem overflow em $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const ProviderScope(child: MyApp()));
      await tester.pumpAndSettle();
      expect(find.text('Clínica Vida & Saúde'), findsOneWidget);
      expect(find.text('Digite sua mensagem...'), findsOneWidget);
      expect(tester.takeException(), isNull);
      final enviar = find.widgetWithIcon(IconButton, Icons.near_me_rounded);
      expect(tester.widget<IconButton>(enviar).onPressed, isNull);
      await tester.enterText(
        find.byType(TextField),
        'Olá, gostaria de agendar uma consulta.',
      );
      await tester.pump();
      await tester.tap(enviar);
      await tester.pumpAndSettle();
      expect(
        find.text('Olá, gostaria de agendar uma consulta.'),
        findsOneWidget,
      );
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );
      expect(tester.takeException(), isNull);
    });
  }

  test('Conversa rejeita texto vazio e limpa anexo após envio local', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(conversaProvider.notifier);
    expect(controller.enviar('   '), isFalse);
    controller.anexar('exame.pdf');
    expect(controller.enviar('   '), isTrue);
    final state = container.read(conversaProvider);
    expect(state.nomeAnexo, isNull);
    expect(state.mensagens.single.nomeAnexo, 'exame.pdf');
    expect(state.mensagens.single.texto, isEmpty);
    controller.anexar('outro.pdf');
    controller.anexar(null);
    expect(container.read(conversaProvider).nomeAnexo, isNull);
    expect(container.read(conversaProvider).mensagens, hasLength(1));
  });
}

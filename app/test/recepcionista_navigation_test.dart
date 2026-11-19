import 'package:app/repositorios/recepcionista/features/agenda/presentation/agenda_page.dart';
import 'package:app/repositorios/recepcionista/features/consultas/presentation/consultas_page.dart';
import 'package:app/repositorios/recepcionista/features/pacientes/presentation/pacientes_page.dart';
import 'package:app/repositorios/recepcionista/features/profissionais/presentation/profissionais_page.dart';
import 'package:app/repositorios/recepcionista/global/presentation/recepcionista_sidebar.dart';
import 'package:app/repositorios/recepcionista/global/recepcionista_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget appRecepcionista(String rota) => MaterialApp(
  home: const SizedBox.shrink(),
  initialRoute: rota,
  routes: recepcionistaRoutes,
);

void main() {
  testWidgets('Sidebar navega pelas quatro rotas e destaca o item atual', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(appRecepcionista('/recepcionista/agenda'));
    await tester.pumpAndSettle();
    expect(find.byType(AgendaPage), findsOneWidget);
    expect(find.byType(ListTile), findsNWidgets(4));

    for (final (titulo, pagina) in [
      ('Pacientes', PacientesPage),
      ('Profissionais', ProfissionaisPage),
      ('Consultas', ConsultasPage),
      ('Agenda', AgendaPage),
    ]) {
      final item = find.widgetWithText(ListTile, titulo);
      await tester.tap(item);
      await tester.pumpAndSettle();
      expect(find.byType(pagina), findsOneWidget);
      expect(
        tester.widget<ListTile>(find.widgetWithText(ListTile, titulo)).selected,
        isTrue,
      );
      expect(tester.takeException(), isNull);
    }
    for (final texto in ['Início', 'Relatórios', 'Configurações', 'Sair']) {
      expect(find.text(texto), findsNothing);
    }
  });

  testWidgets('Menu compacto fecha após navegar e preserva a seleção', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(appRecepcionista('/recepcionista/consultas'));
    await tester.pumpAndSettle();
    expect(find.byType(ConsultasPage), findsOneWidget);
    await tester.tap(find.byType(DrawerButton));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'Pacientes'));
    await tester.pumpAndSettle();
    expect(find.byType(PacientesPage), findsOneWidget);
    expect(find.byType(RecepcionistaSidebar), findsNothing);
    await tester.tap(find.byType(DrawerButton));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<ListTile>(find.widgetWithText(ListTile, 'Pacientes'))
          .selected,
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'repositorios/paciente%20atendimento%20virtual/presentation/pages/paciente_page.dart';
import 'repositorios/recepcionista/global/recepcionista_routes.dart';

void main() => runApp(const ProviderScope(child: MyApp()));

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clínica Vida & Saúde',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF609E8D),
          brightness: Brightness.dark,
        ),
      ),
      home: const PacientePage(),
      // flutter run --dart-define=APP_AREA=recepcionista
      initialRoute: const String.fromEnvironment('APP_AREA') == 'recepcionista'
          ? '/recepcionista/agenda'
          : null,
      routes: recepcionistaRoutes,
    );
  }
}

import 'package:flutter/material.dart';

import '../features/agenda/presentation/agenda_page.dart';
import '../features/consultas/presentation/consultas_page.dart';
import '../features/pacientes/presentation/pacientes_page.dart';
import '../features/profissionais/presentation/profissionais_page.dart';
import 'presentation/recepcionista_layout.dart';
import 'presentation/recepcionista_sidebar.dart';

final Map<String, WidgetBuilder> recepcionistaRoutes = {
  MenuRecepcionista.agenda.rota: (_) => const RecepcionistaLayout(
    itemAtual: MenuRecepcionista.agenda,
    child: AgendaPage(),
  ),
  MenuRecepcionista.pacientes.rota: (_) => const RecepcionistaLayout(
    itemAtual: MenuRecepcionista.pacientes,
    child: PacientesPage(),
  ),
  MenuRecepcionista.profissionais.rota: (_) => const RecepcionistaLayout(
    itemAtual: MenuRecepcionista.profissionais,
    child: ProfissionaisPage(),
  ),
  MenuRecepcionista.consultas.rota: (_) => const RecepcionistaLayout(
    itemAtual: MenuRecepcionista.consultas,
    child: ConsultasPage(),
  ),
};

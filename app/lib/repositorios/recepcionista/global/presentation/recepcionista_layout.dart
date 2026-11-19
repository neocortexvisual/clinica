import 'package:flutter/material.dart';

import 'recepcionista_sidebar.dart';

class RecepcionistaLayout extends StatelessWidget {
  const RecepcionistaLayout({
    super.key,
    required this.itemAtual,
    required this.child,
  });

  final MenuRecepcionista itemAtual;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF008C88)),
        scaffoldBackgroundColor: Colors.white,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compacto = constraints.maxWidth < 700;

          void selecionar(MenuRecepcionista item) {
            final navigator = Navigator.of(context);
            if (compacto) navigator.pop();
            if (item != itemAtual) navigator.pushReplacementNamed(item.rota);
          }

          final sidebar = RecepcionistaSidebar(
            itemAtual: itemAtual,
            onSelecionar: selecionar,
          );

          return Scaffold(
            appBar: compacto
                ? AppBar(backgroundColor: const Color(0xFFEFF7FC))
                : null,
            drawer: compacto ? Drawer(width: 248, child: sidebar) : null,
            body: compacto
                ? child
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      sidebar,
                      Expanded(child: child),
                    ],
                  ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';

enum MenuRecepcionista {
  agenda('Agenda', '/recepcionista/agenda', Icons.calendar_month_outlined),
  pacientes('Pacientes', '/recepcionista/pacientes', Icons.people_outline),
  profissionais(
    'Profissionais',
    '/recepcionista/profissionais',
    Icons.medical_services_outlined,
  ),
  consultas('Consultas', '/recepcionista/consultas', Icons.assignment_outlined);

  const MenuRecepcionista(this.titulo, this.rota, this.icone);

  final String titulo;
  final String rota;
  final IconData icone;
}

class RecepcionistaSidebar extends StatelessWidget {
  const RecepcionistaSidebar({
    super.key,
    required this.itemAtual,
    required this.onSelecionar,
  });

  final MenuRecepcionista itemAtual;
  final ValueChanged<MenuRecepcionista> onSelecionar;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 248,
      decoration: const BoxDecoration(
        color: Color(0xFFEFF7FC),
        border: Border(right: BorderSide(color: Color(0xFFD7E6EE))),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.local_hospital_outlined,
                        size: 42,
                        color: Color(0xFF008C88),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Clínica\nVida & Saúde',
                          style: TextStyle(
                            color: Color(0xFF233F50),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            height: 1.15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),
                for (final item in MenuRecepcionista.values)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Material(
                      color: item == itemAtual
                          ? const Color(0xFF008C88)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      child: ListTile(
                        selected: item == itemAtual,
                        selectedTileColor: const Color(0xFF008C88),
                        selectedColor: Colors.white,
                        textColor: const Color(0xFF284B60),
                        iconColor: const Color(0xFF28647A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                        leading: Icon(item.icone, size: 24),
                        title: Text(
                          item.titulo,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onTap: () => onSelecionar(item),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

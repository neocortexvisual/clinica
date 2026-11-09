import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/conversa_provider.dart';
import '../widgets/clinica_brand.dart';
import '../widgets/mensagem_composer.dart';

class PacientePage extends ConsumerStatefulWidget {
  const PacientePage({super.key});

  @override
  ConsumerState<PacientePage> createState() => _PacientePageState();
}

class _PacientePageState extends ConsumerState<PacientePage> {
  final _textoController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _textoController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _enviar() {
    if (ref.read(conversaProvider.notifier).enviar(_textoController.text)) {
      _textoController.clear();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  Future<void> _anexar() async {
    try {
      final arquivo = await FilePicker.pickFile();
      if (!mounted || arquivo == null) return;
      // Nesta etapa de front-end, somente o nome é exibido; não há upload.
      ref.read(conversaProvider.notifier).anexar(arquivo.name);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível selecionar o arquivo. Tente novamente.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final conversa = ref.watch(conversaProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF123B32),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/paciente_cachoeira.png',
            fit: BoxFit.cover,
            alignment: Alignment.center,
            excludeFromSemantics: true,
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x550B2219),
                  Color(0x080E2D24),
                  Color(0x330E302B),
                ],
                stops: [0, 0.5, 1],
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 700;
                final short = constraints.maxHeight < 540;
                final top = short
                    ? 14.0
                    : (constraints.maxHeight * 0.075).clamp(32.0, 90.0);
                final bottom = short
                    ? 16.0
                    : (constraints.maxHeight * 0.065).clamp(28.0, 70.0);

                return Padding(
                  padding: EdgeInsets.fromLTRB(
                    compact ? 20 : 48,
                    top,
                    compact ? 20 : 48,
                    bottom,
                  ),
                  child: Column(
                    children: [
                      if (!short) ClinicaBrand(compact: compact),
                      if (short)
                        const Text(
                          'Clínica Vida & Saúde',
                          style: TextStyle(
                            fontFamily: 'ClinicaSerif',
                            fontSize: 23,
                          ),
                        ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 760),
                            child: ListView.separated(
                              controller: _scrollController,
                              reverse: true,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              itemCount: conversa.mensagens.length,
                              separatorBuilder: (_, index) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final mensagem =
                                    conversa.mensagens[conversa
                                            .mensagens
                                            .length -
                                        1 -
                                        index];
                                return Align(
                                  alignment: Alignment.centerRight,
                                  child: Container(
                                    constraints: BoxConstraints(
                                      maxWidth: compact
                                          ? constraints.maxWidth * 0.76
                                          : 480,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 13,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xE02D5D50),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: const Color(0x337FAE9B),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (mensagem.nomeAnexo != null)
                                          Text(
                                            '📎 ${mensagem.nomeAnexo}',
                                            style: const TextStyle(
                                              color: Color(0xFFD6E7DB),
                                            ),
                                          ),
                                        if (mensagem.nomeAnexo != null &&
                                            mensagem.texto.isNotEmpty)
                                          const SizedBox(height: 6),
                                        if (mensagem.texto.isNotEmpty)
                                          Text(
                                            mensagem.texto,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              height: 1.5,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 760),
                        child: MensagemComposer(
                          controller: _textoController,
                          nomeAnexo: conversa.nomeAnexo,
                          onEnviar: _enviar,
                          onAnexar: _anexar,
                          onRemoverAnexo: () =>
                              ref.read(conversaProvider.notifier).anexar(null),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

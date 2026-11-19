import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/resposta_chatbot.dart';
import '../providers/conversa_provider.dart';
import '../widgets/clinica_brand.dart';
import '../widgets/mensagem_composer.dart';
import '../widgets/mensagem_balao.dart';

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

  Future<void> _enviar({OpcaoAtendimento? opcao}) async {
    final envio = ref
        .read(conversaProvider.notifier)
        .enviar(
          opcao?.id ?? _textoController.text,
          textoExibido: opcao?.descricao,
        );
    if (ref.read(conversaProvider).enviando && opcao == null) {
      _textoController.clear();
    }
    await envio;
  }

  void _rolarParaFinal() {
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

  Future<void> _anexar() async {
    try {
      final arquivo = await FilePicker.pickFile();
      if (!mounted || arquivo == null) return;
      // Nesta etapa de front-end, somente o nome é exibido; não há upload.
      ref.read(conversaProvider.notifier).anexar(arquivo.name);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'O atendimento recebe apenas texto. O arquivo não será enviado.',
          ),
        ),
      );
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
    ref.listen(conversaProvider, (anterior, atual) {
      if (anterior?.mensagens.length != atual.mensagens.length ||
          anterior?.enviando != atual.enviando) {
        _rolarParaFinal();
      }
    });

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
                                return MensagemBalao(
                                  mensagem: mensagem,
                                  maxWidth: compact
                                      ? constraints.maxWidth * 0.82
                                      : 560,
                                  onEscolher: index == 0 && !conversa.enviando
                                      ? (opcao) => _enviar(opcao: opcao)
                                      : null,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      if (conversa.enviando)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 10),
                              Text('Atendimento digitando...'),
                            ],
                          ),
                        ),
                      if (conversa.erro != null)
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 760),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xED173D34),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    conversa.erro!,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                                if (conversa.podeReenviar)
                                  TextButton(
                                    onPressed: ref
                                        .read(conversaProvider.notifier)
                                        .tentarNovamente,
                                    child: const Text('Tentar novamente'),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 760),
                        child: MensagemComposer(
                          controller: _textoController,
                          nomeAnexo: conversa.nomeAnexo,
                          enviando: conversa.enviando,
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

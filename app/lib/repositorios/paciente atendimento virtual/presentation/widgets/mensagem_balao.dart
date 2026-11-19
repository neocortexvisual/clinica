import 'package:flutter/material.dart';

import '../../domain/entities/mensagem_paciente.dart';
import '../../domain/entities/resposta_chatbot.dart';

class MensagemBalao extends StatelessWidget {
  const MensagemBalao({
    super.key,
    required this.mensagem,
    required this.maxWidth,
    this.onEscolher,
  });

  final MensagemPaciente mensagem;
  final double maxWidth;
  final ValueChanged<OpcaoAtendimento>? onEscolher;

  @override
  Widget build(BuildContext context) {
    final doPaciente = mensagem.autor == AutorMensagem.paciente;
    return Align(
      alignment: doPaciente ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
        decoration: BoxDecoration(
          color: doPaciente ? const Color(0xE02D5D50) : const Color(0xED173D34),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0x337FAE9B)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!doPaciente) ...[
              const Text(
                'Atendimento virtual',
                style: TextStyle(fontSize: 12, color: Color(0xFFB7D8C9)),
              ),
              const SizedBox(height: 6),
            ],
            if (mensagem.nomeAnexo != null)
              Text(
                '📎 ${mensagem.nomeAnexo}',
                style: const TextStyle(color: Color(0xFFD6E7DB)),
              ),
            if (mensagem.nomeAnexo != null && mensagem.texto.isNotEmpty)
              const SizedBox(height: 6),
            if (mensagem.texto.isNotEmpty)
              Text(
                mensagem.texto,
                style: const TextStyle(fontSize: 15, height: 1.5),
              ),
            if (mensagem.opcoes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final opcao in mensagem.opcoes)
                    ActionChip(
                      label: Text(opcao.descricao),
                      onPressed: onEscolher == null
                          ? null
                          : () => onEscolher!(opcao),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

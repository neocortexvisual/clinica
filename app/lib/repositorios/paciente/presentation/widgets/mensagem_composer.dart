import 'dart:ui';

import 'package:flutter/material.dart';

class MensagemComposer extends StatelessWidget {
  const MensagemComposer({
    super.key,
    required this.controller,
    required this.onEnviar,
    required this.onAnexar,
    required this.onRemoverAnexo,
    this.nomeAnexo,
  });

  final TextEditingController controller;
  final VoidCallback onEnviar;
  final VoidCallback onAnexar;
  final VoidCallback onRemoverAnexo;
  final String? nomeAnexo;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (nomeAnexo != null)
          Padding(
            padding: const EdgeInsets.only(left: 12, bottom: 10),
            child: InputChip(
              avatar: const Icon(Icons.description_outlined, size: 18),
              label: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 210),
                child: Text(nomeAnexo!, overflow: TextOverflow.ellipsis),
              ),
              onDeleted: onRemoverAnexo,
              deleteButtonTooltipMessage: 'Remover anexo',
              backgroundColor: const Color(0xDD234E47),
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(36),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0x99507168),
                borderRadius: BorderRadius.circular(36),
                border: Border.all(color: const Color(0x669CC4B7), width: 1.4),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      tooltip: 'Anexar arquivo',
                      onPressed: onAnexar,
                      icon: const Icon(Icons.attach_file_rounded, size: 23),
                      color: const Color(0xFFD0E1D9),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        minLines: 1,
                        maxLines: 4,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => onEnviar(),
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                        ),
                        cursorColor: const Color(0xFFD6E8DB),
                        decoration: const InputDecoration(
                          hintText: 'Digite sua mensagem...',
                          hintStyle: TextStyle(
                            color: Color(0xFFC0D1C8),
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: controller,
                      builder: (context, value, child) {
                        final podeEnviar =
                            value.text.trim().isNotEmpty || nomeAnexo != null;
                        return IconButton.filled(
                          tooltip: 'Enviar mensagem',
                          onPressed: podeEnviar ? onEnviar : null,
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFF558F7E),
                            disabledBackgroundColor: const Color(0xAA558F7E),
                            foregroundColor: const Color(0xFFF0F5EE),
                            disabledForegroundColor: const Color(0xFFB7CEC3),
                            fixedSize: const Size(44, 44),
                          ),
                          icon: const Icon(Icons.near_me_rounded, size: 22),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

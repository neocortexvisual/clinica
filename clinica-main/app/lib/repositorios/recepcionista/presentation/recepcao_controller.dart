import 'package:flutter/material.dart';
import '../domain/atendimento.dart';
import '../data/recepcao_repository.dart';

class RecepcaoController {
  final RecepcaoRepository _repository = RecepcaoRepository();

  // Função que será chamada quando o rececionista clicar no botão de guardar/registar
  Future<void> registarNovoAtendimento({
    required String id,
    required String nomePaciente,
    required String motivo,
  }) async {
    try {
      // Cria o objeto com os dados atuais e a hora exata da entrada
      final novoAtendimento = Atendimento(
        id: id,
        nomePaciente: nomePaciente,
        motivo: motivo,
        dataHoraEntrada: DateTime.now(),
      );

      // Envia para a base de dados através do repositório
      await _repository.adicionarAtendimento(novoAtendimento);
      
      debugPrint('Atendimento registado com sucesso!');
    } catch (e) {
      debugPrint('Erro ao registar atendimento: $e');
    }
  }
}

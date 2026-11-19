import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/entities/mensagem_paciente.dart';
import '../../domain/entities/resposta_chatbot.dart';
import '../../domain/repositories/conversa_repository.dart';

/// Mantém o histórico da tela em memória e consulta as regras no backend Python.
class ConversaApiRepository implements ConversaRepository {
  ConversaApiRepository({
    required this.client,
    required String baseUrl,
    this.timeout = const Duration(seconds: 15),
  }) : _endpoint = Uri.parse(
         '${baseUrl.replaceFirst(RegExp(r'/+$'), '')}/chatbot/mensagens',
       );

  final http.Client client;
  final Uri _endpoint;
  final Duration timeout;
  final List<MensagemPaciente> _mensagens = [];

  @override
  List<MensagemPaciente> listar() => List.unmodifiable(_mensagens);

  @override
  void adicionar(MensagemPaciente mensagem) => _mensagens.add(mensagem);

  @override
  Future<RespostaChatbot> responder(String texto) async {
    final response = await client
        .post(
          _endpoint,
          headers: {'Content-Type': 'application/json; charset=utf-8'},
          body: jsonEncode({'texto': texto}),
        )
        .timeout(timeout);

    if (response.statusCode != 200) {
      throw http.ClientException(
        'Falha no atendimento: ${response.statusCode}',
        _endpoint,
      );
    }
    final json = jsonDecode(utf8.decode(response.bodyBytes));
    if (json is! Map<String, dynamic> ||
        json['mensagem'] is! String ||
        json['etapa'] is! String ||
        json['opcoes'] is! List) {
      throw const FormatException('Resposta do atendimento inválida.');
    }
    final opcoes = (json['opcoes'] as List).map(_opcao).toList(growable: false);
    return RespostaChatbot(
      etapa: json['etapa'] as String,
      mensagem: json['mensagem'] as String,
      opcoes: List.unmodifiable(opcoes),
      atendimentoSelecionado: json['atendimento_selecionado'] == null
          ? null
          : _opcao(json['atendimento_selecionado']),
    );
  }

  OpcaoAtendimento _opcao(dynamic json) {
    if (json is! Map<String, dynamic> ||
        json['id'] is! String ||
        json['descricao'] is! String) {
      throw const FormatException('Opção do atendimento inválida.');
    }
    return OpcaoAtendimento(
      id: json['id'] as String,
      descricao: json['descricao'] as String,
    );
  }
}

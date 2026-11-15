import 'dart:convert';

import 'package:http/http.dart' as http;

class ChatbotResposta {
  const ChatbotResposta({
    required this.conversaId,
    required this.mensagem,
    required this.opcoes,
  });

  final String conversaId;
  final String mensagem;
  final List<String> opcoes;
}

class ChatbotApiException implements Exception {
  const ChatbotApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ChatbotApi {
  ChatbotApi({http.Client? client, Uri? baseUri})
    : _client = client ?? http.Client(),
      _baseUri = _comBarraFinal(
        baseUri ??
            Uri.parse(
              const String.fromEnvironment(
                'CHATBOT_API_URL',
                defaultValue: 'http://127.0.0.1:8000',
              ),
            ),
      );

  final http.Client _client;
  final Uri _baseUri;

  Future<ChatbotResposta> criarConversa() =>
      _post(_baseUri.resolve('conversas'));

  Future<ChatbotResposta> enviarMensagem(
    String conversaId,
    String texto,
  ) => _post(
    _baseUri.resolve('conversas/$conversaId/mensagens'),
    body: {'texto': texto},
  );

  Future<ChatbotResposta> _post(Uri uri, {Map<String, Object>? body}) async {
    final response = await _client
        .post(
          uri,
          headers: const {'content-type': 'application/json'},
          body: body == null ? null : jsonEncode(body),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ChatbotApiException(
        'O atendimento retornou um erro (${response.statusCode}).',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const ChatbotApiException('Resposta inválida do atendimento.');
    }
    final conversaId = decoded['conversa_id'];
    final mensagem = decoded['mensagem'];
    final rawOpcoes = decoded['opcoes'];
    if (conversaId is! String || mensagem is! String || rawOpcoes is! List) {
      throw const ChatbotApiException('Resposta inválida do atendimento.');
    }

    final opcoes = <String>[];
    for (final item in rawOpcoes) {
      if (item is! Map<String, dynamic> || item['descricao'] is! String) {
        throw const ChatbotApiException('Resposta inválida do atendimento.');
      }
      opcoes.add(item['descricao'] as String);
    }
    return ChatbotResposta(
      conversaId: conversaId,
      mensagem: mensagem,
      opcoes: List.unmodifiable(opcoes),
    );
  }

  void close() => _client.close();

  static Uri _comBarraFinal(Uri uri) =>
      uri.path.endsWith('/') ? uri : uri.replace(path: '${uri.path}/');
}

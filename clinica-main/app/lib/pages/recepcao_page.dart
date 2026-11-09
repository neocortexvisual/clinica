import 'package:flutter/material.dart';
import '../repositorios/recepcionista/presentation/recepcao_controller.dart';

class RecepcaoPage extends StatefulWidget {
  const RecepcaoPage({Key? key}) : super(key: key);

  @override
  State<RecepcaoPage> createState() => _RecepcaoPageState();
}

class _RecepcaoPageState extends State<RecepcaoPage> {
  // Instância do controller que está na pasta presentation
  final RecepcaoController _controller = RecepcaoController();

  // Controladores para os campos de texto do ecrã
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _motivoController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    _motivoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receção - Registo de Atendimento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Campo para o Nome do Paciente
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome do Paciente',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            // Campo para o Motivo
            TextField(
              controller: _motivoController,
              decoration: const InputDecoration(
                labelText: 'Motivo do Atendimento',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            
            // Botão para submeter e enviar para o Firestore via Controller
            ElevatedButton(
              onPressed: () async {
                if (_nomeController.text.isEmpty || _motivoController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor, preencha todos os campos!')),
                  );
                  return;
                }

                // Chama a lógica do controller
                await _controller.salvarAtendimento(
                  nomePaciente: _nomeController.text,
                  motivo: _motivoController.text,
                );

                // Feedback visual de sucesso
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Atendimento registado com sucesso!')),
                );

                // Limpa os campos após o envio
                _nomeController.clear();
                _motivoController.clear();
              },
              child: const Text('Registar Entrada'),
            ),
          ],
        ),
      ),
    );
  }
}

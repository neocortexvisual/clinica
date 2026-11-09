import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pages/recepcao_page.dart'; // Certifique-se de que o caminho do import está correto

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Garante a ligação ao Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clínica App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const RecepcaoPage(), // Define a página de receção como inicial
    );
  }
}

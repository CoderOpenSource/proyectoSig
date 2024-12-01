import 'package:flutter/material.dart';
import 'package:mapas_api/widgets/app_drawer.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        backgroundColor: const Color.fromARGB(255, 10, 0, 40),
      ),
      drawer: const AppDrawer(),
      body: const Center(
        child: Text('Configuración de la cuenta'),
      ),
    );
  }
}

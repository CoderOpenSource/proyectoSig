import 'package:flutter/material.dart';
import 'package:mapas_api/screens/home_pasajero.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      drawer: const AppDrawer(),
      body: const Center(
        child: Text('Configuración de la cuenta'),
      ),
    );
  }
}

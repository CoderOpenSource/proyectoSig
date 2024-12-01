import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mapas_api/screens/loading_screen.dart';
import 'package:mapas_api/screens/cortes/menu_cortes_screen.dart';
import 'package:mapas_api/screens/generated_cuts_screen.dart';
import 'package:mapas_api/screens/configuration.dart';
import 'package:mapas_api/screens/user/login_user.dart';

class AppDrawer extends StatefulWidget {
  final List<Map<String, String>>? medidores;
  final List<Map<String, dynamic>>? medidorCortado;

  const AppDrawer({Key? key, this.medidores, this.medidorCortado})
      : super(key: key);

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String userName = '';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('userName');
    setState(() {
      userName = name ?? 'Nombre del Usuario';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 10, 0, 40), // Fondo azul oscuro
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40, // Tamaño ajustado del círculo
                  backgroundImage: const NetworkImage(
                    'https://res.cloudinary.com/dkpuiyovk/image/upload/v1730601471/gkcznnpe7bxuenjj1qtl.png',
                  ),
                  backgroundColor: Colors.grey[200],
                ),
                const SizedBox(
                    height: 10), // Espaciado entre la imagen y el texto
                Text(
                  '$userName', // Cambié el texto de ejemplo
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18.0, // Tamaño reducido para evitar overflow
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            margin: EdgeInsets.zero, // Elimina márgenes extras
            padding: const EdgeInsets.all(8.0), // Asegura espacio interno
            // Altura suficiente para evitar overflow
          ),
          _buildDrawerItem(
            context,
            icon: Icons.home,
            title: 'Inicio',
            onTap: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const LoadingScreen()),
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.cut,
            title: 'Cortes',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const MenuCortesScreen()),
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.check,
            title: 'Ver Cortes Generados',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const GeneratedCutsScreen(),
              ),
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.settings,
            title: 'Configuración',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 10, 0, 40),
                padding:
                    const EdgeInsets.symmetric(horizontal: 70, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => _showLogoutConfirmation(context),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.power_settings_new, color: Colors.white),
                  SizedBox(width: 5),
                  Text("Cerrar sesión", style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context,
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: const Color.fromARGB(255, 10, 0, 40)),
      title: Text(
        title,
        style: const TextStyle(color: Color.fromARGB(255, 10, 0, 40)),
      ),
      onTap: onTap,
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(32.0)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "😲 ¿Estás seguro?",
                style: TextStyle(
                  color: Color.fromARGB(255, 10, 0, 40),
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Cancelar",
                      style: TextStyle(color: Color.fromARGB(255, 10, 0, 40)),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _logout(context),
                    child: const Text(
                      "Sí",
                      style: TextStyle(color: Color.fromARGB(255, 10, 0, 40)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('accessToken');
    prefs.remove('userName');
    prefs.remove('registro');
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginView()),
      (Route<dynamic> route) => false,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:mapas_api/screens/generate_cuts_screen.dart';
import 'package:mapas_api/screens/loading_screen.dart';
import 'package:mapas_api/widgets/app_drawer.dart';

class MenuCortesScreen extends StatelessWidget {
  final List<Map<String, String>>? medidores;
  final List<Map<String, dynamic>>? medidorCortado;

  const MenuCortesScreen({Key? key, this.medidores, this.medidorCortado})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menú Cortes'),
        backgroundColor: const Color.fromARGB(255, 10, 0, 40),
      ),
      drawer: const AppDrawer(),
      body: Container(
        color: Colors.white, // Fondo blanco
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40), // Mueve la imagen hacia arriba
              Image.network(
                'https://res.cloudinary.com/dkpuiyovk/image/upload/v1732761492/logo_n2hfvf.webp',
                width: 220,
                errorBuilder: (context, error, stackTrace) {
                  return const Text(
                    'Error al cargar la imagen',
                    style: TextStyle(color: Colors.red),
                  );
                },
              ),
              const SizedBox(height: 30),
              _buildBigCard(
                context,
                title: "Importar cortes",
                subtitle: "Desde el servidor",
                icon: Icons.download,
                color: const Color.fromARGB(255, 10, 0, 40),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const GenerateCutsScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildBigCard(
                context,
                title: "Exportar cortes",
                subtitle: "Al servidor",
                icon: Icons.upload,
                color: Colors.green,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const LoadingScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              const Text(
                "Coosiv R.L.",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBigCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          color: color,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            height: 150,
            width: double.infinity,
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 60, // Ícono grande
                ),
                const SizedBox(width: 20),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

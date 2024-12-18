import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mapas_api/helpers/cortes/database_helper.dart';
import 'package:mapas_api/widgets/app_drawer.dart';
import 'dart:io'; // Para trabajar con imágenes almacenadas localmente
import 'package:photo_view/photo_view.dart'; // Para manejar imágenes con zoom

class GeneratedCutsScreen extends StatelessWidget {
  const GeneratedCutsScreen({Key? key}) : super(key: key);

  Future<List<Map<String, dynamic>>> getCortesCortados() async {
    final dbHelper = DatabaseHelper.instance;
    return await dbHelper.getCortesCortados();
  }

  String formatFechaCorte(String? fechaCorte) {
    if (fechaCorte == null) return 'Fecha no disponible';
    try {
      final DateTime parsedDate = DateTime.parse(fechaCorte);
      return DateFormat('dd/MM/yyyy HH:mm')
          .format(parsedDate); // Ejemplo: 28/11/2024 14:30
    } catch (e) {
      return 'Formato de fecha inválido';
    }
  }

  void _showImageModal(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: const EdgeInsets.all(16),
          child: Stack(
            children: [
              FractionallySizedBox(
                heightFactor: 0.7, // Limita la altura al 70%
                child: PhotoView(
                  imageProvider: FileImage(File(imagePath)),
                  backgroundDecoration:
                      const BoxDecoration(color: Colors.black),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 24),
                  onPressed: () {
                    Navigator.of(context).pop(); // Cierra el modal
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cortes Generados'),
        backgroundColor: const Color.fromARGB(255, 10, 0, 40),
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getCortesCortados(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final cortadosMedidores = snapshot.data;

          if (cortadosMedidores == null || cortadosMedidores.isEmpty) {
            return const Center(
              child: Text('Aún no se han registrados medidores cortados'),
            );
          }

          return ListView.builder(
            itemCount: cortadosMedidores.length,
            itemBuilder: (context, index) {
              final medidor = cortadosMedidores[index];
              final String? imagenRuta = medidor['imagenRuta'];

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  // Mostrar imagen o texto en el lado izquierdo
                  leading: imagenRuta != null && imagenRuta.isNotEmpty
                      ? GestureDetector(
                          onTap: () => _showImageModal(context, imagenRuta),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.file(
                              File(imagenRuta),
                              fit: BoxFit.cover,
                              width: 50,
                              height: 50,
                            ),
                          ),
                        )
                      : const SizedBox(
                          width: 50,
                          height: 50,
                          child: Center(
                            child: Text(
                              'Sin imagen',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                  // Información del medidor
                  title: Text(
                    medidor['dNomb'] ?? 'Nombre no disponible',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medidor['dLotes'] == '. . .'
                            ? 'No disponible'
                            : medidor['dLotes'] ?? 'Dirección no disponible',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      Text(
                        'C.F: ${medidor['bscocNcnt'] ?? '0'}',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      Text(
                        'C.U.: ${medidor['bscntCodf'] ?? '0'}',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      Text(
                        'Fecha de Corte: ${formatFechaCorte(medidor['fechaCorte'])}',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  // Mostrar texto e icono a la derecha
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.warning, color: Colors.red),
                      const SizedBox(height: 4),
                      const Text(
                        'Cortado',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

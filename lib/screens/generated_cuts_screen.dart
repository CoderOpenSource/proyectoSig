import 'package:flutter/material.dart';

class GeneratedCutsScreen extends StatelessWidget {
  final List<Map<String, dynamic>>? medidorCortado;
  final List<Map<String, String>>? medidores;

  const GeneratedCutsScreen({
    Key? key,
    this.medidorCortado,
    this.medidores,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (medidorCortado == null ||
        medidores == null ||
        medidorCortado!.isEmpty ||
        medidores!.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cortes Generados')),
        body: const Center(
          child: Text('Aún no se han registrados medidores cortados'),
        ),
      );
    }

    List<Map<String, String>> cortadosMedidores = [];
    for (int i = 0; i < medidorCortado!.length; i++) {
      if (medidorCortado![i]['isCut']) {
        cortadosMedidores.add(medidores![i]);
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Cortes Generados')),
      body: ListView.builder(
        itemCount: cortadosMedidores.length,
        itemBuilder: (context, index) {
          final medidor = cortadosMedidores[index];
          final cutDate =
              medidorCortado![index]['cutDate'] ?? 'Fecha no disponible';
          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              leading: const Icon(Icons.warning, color: Colors.red),
              title: Text(
                medidor['dNomb'] ?? 'Nombre no disponible',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                    'Fecha de Corte: $cutDate',
                    style: TextStyle(color: Colors.grey[700]),
                  )
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.warning, color: Colors.red),
                  const SizedBox(height: 4),
                  Text(
                    'Cortado',
                    style: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

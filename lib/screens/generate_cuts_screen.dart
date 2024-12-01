import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mapas_api/helpers/cortes/database_helper.dart';
import 'package:mapas_api/models/cortes/corte.dart';
import 'package:mapas_api/screens/map_screen.dart';
import 'package:mapas_api/widgets/app_drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml/xml.dart' as xml;

class GenerateCutsScreen extends StatefulWidget {
  const GenerateCutsScreen({super.key});

  @override
  _GenerateCutsScreenState createState() => _GenerateCutsScreenState();
}

class _GenerateCutsScreenState extends State<GenerateCutsScreen> {
  String responseText = "";
  List<Map<String, String>> medidores = [];
  List<Map<String, String>> filteredMedidores = [];
  List<Map<String, String>> rutas = [];
  int currentPage = 0;
  final int pageSize = 10;
  bool isLoading = false;
  final TextEditingController searchController = TextEditingController();
  Map<String, String>? selectedRuta;

  final String url = 'http://190.171.244.211:8080/wsVarios/wsBS.asmx';

  Future<void> fetchRutas() async {
    const String soapRequest = '''<?xml version="1.0" encoding="utf-8"?>
      <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
                     xmlns:xsd="http://www.w3.org/2001/XMLSchema" 
                     xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
        <soap:Body>
          <W0Corte_ObtenerRutas xmlns="http://activebs.net/">
            <liCper>1</liCper> <!-- Valor de ejemplo, ajustarlo según sea necesario -->
          </W0Corte_ObtenerRutas>
        </soap:Body>
      </soap:Envelope>''';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'text/xml; charset=utf-8',
          'SOAPAction': 'http://activebs.net/W0Corte_ObtenerRutas'
        },
        body: soapRequest,
      );

      if (response.statusCode == 200) {
        parseRutas(response.body);
      } else {
        throw Exception('Error en la solicitud SOAP: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  void parseRutas(String xmlString) {
    final document = xml.XmlDocument.parse(xmlString);
    final tables = document.findAllElements('Table');
    rutas = tables.map((table) {
      final Map<String, String> ruta = {};
      table.children.whereType<xml.XmlElement>().forEach((element) {
        ruta[element.name.toString()] = element.text;
      });
      return ruta;
    }).toList();
    print('Rutas parsed:');
    for (var ruta in rutas) {
      print('RUTA $ruta');
    }
  }

  Future<void> fetchCutsList() async {
    const String soapRequest = '''<?xml version="1.0" encoding="utf-8"?>
      <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
                     xmlns:xsd="http://www.w3.org/2001/XMLSchema" 
                     xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
        <soap:Body>
          <W2Corte_ReporteParaCortesSIG xmlns="http://activebs.net/">
            <param1>1</param1>
            <param2>0</param2>
            <param3>0</param3>
          </W2Corte_ReporteParaCortesSIG>
        </soap:Body>
      </soap:Envelope>''';

    try {
      setState(() {
        isLoading = true;
      });
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'text/xml; charset=utf-8',
          'SOAPAction': 'http://activebs.net/W2Corte_ReporteParaCortesSIG'
        },
        body: soapRequest,
      );

      if (response.statusCode == 200) {
        parseMedidores(response.body);
      } else {
        setState(() {
          responseText = 'Error: ${response.statusCode}';
        });
      }
    } catch (e) {
      print('Exception: $e');
      setState(() {
        responseText = 'Exception: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void parseMedidores(String xmlString) async {
    setState(() {
      isLoading = true;
    });
    final dbHelper = DatabaseHelper.instance;
    final prefs = await SharedPreferences.getInstance();

    // Verifica si la base de datos ya fue inicializada
    final isDatabaseCreated = prefs.getBool('database_created') ?? false;

    // Recuperar los cortes no cortados desde la base de datos
    Future<void> cargarMedidoresNoCortados() async {
      final cortesNoCortados = await dbHelper.getCortesPorEstado(false);
      medidores = cortesNoCortados.map((corte) {
        return corte.map((key, value) => MapEntry(key, value.toString()));
      }).toList();

      print('Medidores recuperados de la base de datos:');
      for (var medidor in medidores) {
        print(medidor);
      }
    }

    if (isDatabaseCreated) {
      print(
          'La base de datos ya fue creada. Recuperando cortes no cortados...');
      await cargarMedidoresNoCortados();
      filterMedidores();
      setState(() {
        isLoading = false;
      });
      return;
    }

    // Procesar el XML para obtener medidores
    final document = xml.XmlDocument.parse(xmlString);
    final tables = document.findAllElements('Table');

    medidores = tables.map((table) {
      final Map<String, String> medidor = {};
      table.children.whereType<xml.XmlElement>().forEach((element) {
        medidor[element.name.toString()] = element.text;
      });
      return medidor;
    }).where((medidor) {
      final lat = double.tryParse(medidor['bscntlati'] ?? '0.0') ?? 0.0;
      final lng = double.tryParse(medidor['bscntlogi'] ?? '0.0') ?? 0.0;
      return lat != 0.0 &&
          lng != 0.0; // Filtrar medidores con coordenadas válidas
    }).toList();

    print('Medidores parsed desde XML:');
    for (var medidor in medidores) {
      print(medidor);

      // Convertir el medidor a un objeto Corte
      final corte = Corte(
        id: 0, // Será autoincrementado en la base de datos
        bscocNcoc: medidor['bscocNcoc'] ?? '',
        bscntCodf: medidor['bscntCodf'] ?? '',
        bscocNcnt: medidor['bscocNcnt'] ?? '',
        dNomb: medidor['dNomb'] ?? '',
        bscocNmor: int.tryParse(medidor['bscocNmor'] ?? '0') ?? 0,
        bscocImor: double.tryParse(medidor['bscocImor'] ?? '0.0') ?? 0.0,
        bsmednser: medidor['bsmednser'] ?? '',
        bsmedNume: medidor['bsmedNume'] ?? '',
        bscntlati: double.tryParse(medidor['bscntlati'] ?? '0.0') ?? 0.0,
        bscntlogi: double.tryParse(medidor['bscntlogi'] ?? '0.0') ?? 0.0,
        dNcat: medidor['dNcat'] ?? '',
        dCobc: medidor['dCobc'] ?? '',
        dLotes: medidor['dLotes'] ?? '',
        cortado: false, // Inicializar como no cortado
        fechaCorte: null, // Inicializar la fecha de corte como null
      );

      // Guardar en la base de datos
      await dbHelper.insertCorte(corte.toMap());
    }

    // Marcar la base de datos como creada
    await prefs.setBool('database_created', true);

    print(
        'Medidores guardados en la base de datos. Recuperando no cortados...');
    await cargarMedidoresNoCortados();
    filterMedidores(); // Filtrar los medidores si es necesario
    setState(() {
      isLoading = false;
    });
  }

  void filterMedidores() {
    String searchQuery = searchController.text.toLowerCase();
    setState(() {
      filteredMedidores = medidores.where((medidor) {
        bool matchesSearchQuery =
            medidor['bscocNcnt']!.toLowerCase().contains(searchQuery);
        bool matchesZona = selectedRuta == null ||
            selectedRuta!['bsrutnzon'] == null ||
            medidor['bscntCodf']!.endsWith(selectedRuta!['bsrutnzon']!);
        return matchesSearchQuery && matchesZona;
      }).toList();
    });
  }

  void loadMore() {
    setState(() {
      currentPage++;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchRutas();
    fetchCutsList();
    searchController.addListener(filterMedidores);
  }

  @override
  void dispose() {
    searchController.removeListener(filterMedidores);
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int currentItemCount = (currentPage + 1) * pageSize;
    List<Map<String, String>> currentMedidores =
        filteredMedidores.length > currentItemCount
            ? filteredMedidores.sublist(0, currentItemCount)
            : filteredMedidores;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Generar Lista para Cortes'),
        backgroundColor: const Color.fromARGB(255, 10, 0, 40),
      ),
      drawer: const AppDrawer(),
      body: isLoading
          ? const Center(
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 10),
                Text('Obteniendo datos, espere por favor...')
              ],
            ))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      labelText: 'Buscar por Código Fijo',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                const Text(
                  'Seleccione una Zona:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButton<Map<String, String>>(
                    hint: const Text('Seleccionar Zona'),
                    value: selectedRuta,
                    items: [
                      const DropdownMenuItem<Map<String, String>>(
                        value: null,
                        child: Text('Todas'),
                      ),
                      const DropdownMenuItem<Map<String, String>>(
                        value: {
                          'bsrutdesc': 'Seleccionar por Zonas',
                          'bsrutnzon': '0'
                        },
                        child: Text('Seleccionar por Zonas'),
                      ),
                      ...rutas.map((ruta) {
                        return DropdownMenuItem<Map<String, String>>(
                          value: ruta,
                          child: Text(ruta['bsrutdesc'] ?? 'Zona sin nombre'),
                        );
                      }).toList()
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedRuta = value;
                        filterMedidores();
                      });
                    },
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: currentMedidores.length + 1,
                    itemBuilder: (context, index) {
                      if (index == currentMedidores.length) {
                        return currentMedidores.length ==
                                filteredMedidores.length
                            ? const SizedBox.shrink()
                            : TextButton(
                                onPressed: loadMore,
                                child: const Text(
                                  'Ver más',
                                  style: TextStyle(fontSize: 16),
                                ),
                              );
                      }
                      final medidor = currentMedidores[index];
                      return Card(
                        margin: const EdgeInsets.all(10),
                        child: ListTile(
                          leading: const Icon(Icons.warning, color: Colors.red),
                          title: Text(
                            medidor['dNomb'] ?? 'Nombre no disponible',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                medidor['dLotes'] == '. . .'
                                    ? 'No disponible'
                                    : medidor['dLotes'] ??
                                        'Dirección no disponible',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                              Text(
                                'C.F: ${medidor['bscocNcnt'] ?? '0'}',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                              Text(
                                'C.U.: ${medidor['bscntCodf'] ?? '0'}',
                                style: TextStyle(color: Colors.grey[700]),
                              )
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.cut, color: Colors.red),
                              const SizedBox(height: 4),
                              Text(
                                'Importe: ${medidor['bscocImor'] ?? '0.00'} Bs',
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          onTap: () {
                            print('Medidor: $medidor');
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MapScreen2(medidores: filteredMedidores),
            ),
          );
        },
        label: const Text(
          'Mostrar plano de recorrido',
          style: TextStyle(
            color: Colors.white, // Color de las letras
            fontSize: 16,
          ),
        ),
        icon: const Icon(
          Icons.flag,
          color: Colors.white, // Color del ícono
        ),
        backgroundColor: Color.fromARGB(255, 10, 0, 40), // Color del botón
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Bordes redondeados
        ),
      ),
    );
  }
}

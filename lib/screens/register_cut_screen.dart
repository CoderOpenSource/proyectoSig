import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mapas_api/models/medidor.dart';

class RegisterCutScreen extends StatefulWidget {
  final Medidor medidor;
  final int index;

  const RegisterCutScreen(
      {Key? key, required this.medidor, required this.index})
      : super(key: key);

  @override
  _RegisterCutScreenState createState() => _RegisterCutScreenState();
}

class _RegisterCutScreenState extends State<RegisterCutScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _ncocController;
  late TextEditingController _cemcController;
  late TextEditingController _presController;
  late TextEditingController _cobcController;
  late TextEditingController _lcorController;
  late TextEditingController _nofnController;
  late TextEditingController _appNameController;

  @override
  void initState() {
    super.initState();
    _ncocController =
        TextEditingController(text: widget.medidor.ncoc.toString());
    _cemcController =
        TextEditingController(text: widget.medidor.codf.toString());
    _presController = TextEditingController(
        text: widget.medidor.nmor.toString()); // Usando nmor como liPres
    _cobcController = TextEditingController(text: widget.medidor.nume);
    _lcorController = TextEditingController(
        text: widget.medidor.nmor.toString()); // Usando mor como liLcor
    _nofnController = TextEditingController(
        text: widget.medidor.ncnt.toString()); // Usando cnt como liNofn
    _appNameController = TextEditingController(
        text: 'CortesSanIgnacio'); // Ajustar según sea necesario
  }

  @override
  void dispose() {
    _ncocController.dispose();
    _cemcController.dispose();
    _presController.dispose();
    _cobcController.dispose();
    _lcorController.dispose();
    _nofnController.dispose();
    _appNameController.dispose();
    super.dispose();
  }

  String buildSoapRequest({
    required int liNcoc,
    required int liCemc,
    required DateTime ldFcor,
    required int liPres,
    required int liCobc,
    required int liLcor,
    required int liNofn,
    required String lsAppName,
  }) {
    return '''<?xml version="1.0" encoding="utf-8"?>
      <soap12:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap12="http://www.w3.org/2003/05/soap-envelope">
        <soap12:Body>
          <W3Corte_UpdateCorte xmlns="http://activebs.net/">
            <liNcoc>$liNcoc</liNcoc>
            <liCemc>$liCemc</liCemc>
            <ldFcor>${ldFcor.toIso8601String()}</ldFcor>
            <liPres>$liPres</liPres>
            <liCobc>$liCobc</liCobc>
            <liLcor>$liLcor</liLcor>
            <liNofn>$liNofn</liNofn>
            <lsAppName>$lsAppName</lsAppName>
          </W3Corte_UpdateCorte>
        </soap12:Body>
      </soap12:Envelope>''';
  }

  Future<void> registerCut({
    required int liNcoc,
    required int liCemc,
    required DateTime ldFcor,
    required int liPres,
    required int liCobc,
    required int liLcor,
    required int liNofn,
    required String lsAppName,
  }) async {
    final soapRequest = buildSoapRequest(
      liNcoc: liNcoc,
      liCemc: liCemc,
      ldFcor: ldFcor,
      liPres: liPres,
      liCobc: liCobc,
      liLcor: liLcor,
      liNofn: liNofn,
      lsAppName: lsAppName,
    );

    final response = await http.post(
      Uri.parse('http://190.171.244.211:8080/wsVarios/wsBS.asmx'),
      headers: {
        'Content-Type': 'application/soap+xml; charset=utf-8',
        'SOAPAction': 'http://activebs.net/W3Corte_UpdateCorte',
      },
      body: soapRequest.trim(), // Asegúrate de que no haya espacios en blanco
    );

    if (mounted) {
      if (response.statusCode == 200) {
        print('Corte registrado correctamente');
        await showDialog(
          context: context,
          barrierDismissible: false, // Evitar que se cierre al tocar fuera
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: const Color.fromARGB(255, 10, 0, 40), // Fondo
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20), // Bordes redondeados
              ),
              title: Row(
                children: const [
                  Icon(Icons.check_circle, color: Colors.green, size: 30),
                  SizedBox(width: 10),
                  Text(
                    '¡Éxito!',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
              content: const Text(
                'Corte registrado exitosamente.\n\nEsta acción no se puede deshacer.',
                style: TextStyle(color: Colors.white),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                        context, true); // Volver a la pantalla anterior
                  },
                  child: const Text(
                    'Volver',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              ],
            );
          },
        );
      } else {
        print('Error al registrar el corte: ${response.body}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al registrar el corte'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Color.fromARGB(255, 10, 0, 40);
    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: Colors.white,
      labelStyle: TextStyle(color: primaryColor),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: primaryColor),
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Corte'),
        backgroundColor: const Color.fromARGB(255, 10, 0, 40),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _ncocController,
                decoration: inputDecoration.copyWith(labelText: 'NCoc'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el NCoc';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _cemcController,
                decoration: inputDecoration.copyWith(labelText: 'Cemc'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el Cemc';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _presController,
                decoration: inputDecoration.copyWith(labelText: 'Pres'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el Pres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _cobcController,
                decoration: inputDecoration.copyWith(labelText: 'Cobc'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el Cobc';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _lcorController,
                decoration: inputDecoration.copyWith(labelText: 'Lcor'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el Lcor';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _nofnController,
                decoration: inputDecoration.copyWith(labelText: 'Nofn'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el Nofn';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _appNameController,
                decoration: inputDecoration.copyWith(labelText: 'App Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el nombre de la aplicación';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    registerCut(
                      liNcoc: int.parse(_ncocController.text),
                      liCemc: int.parse(_cemcController.text),
                      ldFcor: DateTime.now(),
                      liPres: int.parse(_presController.text), // nmor
                      liCobc: int.parse(_cobcController.text),
                      liLcor: int.parse(_lcorController.text), // mor
                      liNofn: int.parse(_nofnController.text), // cnt
                      lsAppName: _appNameController.text,
                    );
                    Navigator.pop(
                        context, true); // Indicar que se ha registrado el corte
                  }
                },
                icon: const Icon(Icons.check, color: Colors.white),
                label: const Text(
                  'Registrar Corte',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close, color: primaryColor),
                label: Text(
                  'Cerrar',
                  style: TextStyle(color: primaryColor),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: primaryColor,
                  backgroundColor: Colors.white,
                  side: BorderSide(color: primaryColor),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

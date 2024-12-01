import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mapas_api/screens/loading_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false;
  String? _error;

  final LocalAuthentication auth = LocalAuthentication();

  Future<Map<String, String>?> validarLogin(
      String username, String password) async {
    const url = 'http://190.171.244.211:8080/wsVarios/wsad.asmx';
    const soapAction = 'http://tempuri.org/ValidarLoginPassword';

    final envelope = '''<?xml version="1.0" encoding="utf-8"?>
  <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
    <soap:Body>
      <ValidarLoginPassword xmlns="http://tempuri.org/">
        <lsLogin>$username</lsLogin>
        <lsPassword>$password</lsPassword>
      </ValidarLoginPassword>
    </soap:Body>
  </soap:Envelope>''';

    print('Sending request to $url');
    print('Request envelope: $envelope');

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'text/xml; charset=utf-8',
        'SOAPAction': soapAction,
      },
      body: envelope,
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      return _parseSoapResponse(response.body);
    } else {
      print('Error: ${response.statusCode}');
      return null;
    }
  }

  Map<String, String>? _parseSoapResponse(String responseBody) {
    final start = responseBody.indexOf('<ValidarLoginPasswordResult>') + 28;
    final end = responseBody.indexOf('</ValidarLoginPasswordResult>');
    if (start < 0 || end < 0) {
      print('Error parsing response: $responseBody');
      return null;
    }

    final result = responseBody.substring(start, end);
    print('Parsed result: $result');
    final parts = result.split('|');

    if (parts.length == 4) {
      return {
        'status': parts[0],
        'name': parts[1],
        'code1': parts[2],
        'code2': parts[3],
      };
    }
    print('Invalid response format: $result');
    return null;
  }

  Future<int?> obtenerRegistroPorCUsuario(String cUsuario) async {
    const url = 'http://190.171.244.211:8080/wsVarios/wsGB.asmx';
    const soapAction = 'http://tempuri.org/GBOFN_ObtenerRegistroPorCUsuario';

    final envelope = '''<?xml version="1.0" encoding="utf-8"?>
  <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
    <soap:Body>
      <GBOFN_ObtenerRegistroPorCUsuario xmlns="http://tempuri.org/">
        <lsCusr>$cUsuario</lsCusr>
      </GBOFN_ObtenerRegistroPorCUsuario>
    </soap:Body>
  </soap:Envelope>''';

    print('Sending request to $url');
    print('Request envelope: $envelope');

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'text/xml; charset=utf-8',
        'SOAPAction': soapAction,
      },
      body: envelope,
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      return _parseSoapResponseInt(response.body);
    } else {
      print('Error: ${response.statusCode}');
      return null;
    }
  }

  int? _parseSoapResponseInt(String responseBody) {
    final start =
        responseBody.indexOf('<GBOFN_ObtenerRegistroPorCUsuarioResult>') + 40;
    final end =
        responseBody.indexOf('</GBOFN_ObtenerRegistroPorCUsuarioResult>');

    // Validar que la respuesta contenga el texto esperado
    if (start < 39 || end < 0) {
      print('Error parsing response: $responseBody');
      return null;
    }

    final result = responseBody.substring(start, end);
    print('Parsed result: $result');

    // Devolver el valor parseado si es un entero válido, de lo contrario null
    return int.tryParse(result);
  }

  Future<void> _handleSignIn() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final String username = usernameController.text;
    final String password = passwordController.text;

    final loginResult = await validarLogin(username, password);
    print('Login Result: $loginResult');

    if (loginResult != null && loginResult['status'] == 'OK') {
      final name = loginResult['name'];
      print('Name obtained: $name');
      final registro = await obtenerRegistroPorCUsuario(name!);
      print('Registro obtained: $registro');
      if (registro != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', 'dummy_token_123456');
        await prefs.setString('userName', name);
        await prefs.setInt('registro', registro);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuario verificado con éxito'),
            backgroundColor: Colors.lightBlue,
            duration: Duration(seconds: 2),
          ),
        );

        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoadingScreen()),
          );
        });
      } else {
        setState(() {
          _error = 'No se pudo obtener el registro del usuario';
        });
      }
    } else {
      setState(() {
        _error = 'Usuario o contraseña inválidos';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Widget _loadingOverlay() {
    return _isLoading
        ? Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text("Espere por favor...",
                      style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          )
        : const SizedBox.shrink();
  }

  Future<void> _handleBiometricSignIn() async {
    final prefs = await SharedPreferences.getInstance();
    final userName = prefs.getString('userName');
    final accessToken = prefs.getString('accessToken');

    if (userName != null && accessToken != null) {
      // Autenticar biométricamente
      final bool isAuthenticated = await auth.authenticate(
        localizedReason: 'Por favor autentíquese para acceder',
        options: const AuthenticationOptions(
          biometricOnly: true, // Asegura que solo se usen datos biométricos
          stickyAuth:
              true, // Mantiene la autenticación activa mientras la app está en segundo plano
        ),
      );

      if (isAuthenticated) {
        // Si se autentica correctamente
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoadingScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Autenticación fallida. Inténtelo de nuevo.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      // Mostrar modal si no hay datos almacenados
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Datos no guardados'),
          content: const Text(
              'No hay datos guardados para autenticación biométrica. Por favor, inicie sesión manualmente.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 12, 4, 124),
              Color.fromARGB(0, 146, 214, 218)
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    height: 220,
                    width: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      image: const DecorationImage(
                        image: NetworkImage(
                            'https://res.cloudinary.com/dkpuiyovk/image/upload/v1732761492/logo_n2hfvf.webp'),
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: Text(
                      'Corte de Medidores',
                      style: TextStyle(
                        fontSize: 32, // Tamaño del texto
                        fontWeight: FontWeight.bold, // Grosor de la letra
                        color: const Color.fromARGB(
                            255, 2, 40, 69), // Color del texto
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.black.withOpacity(0.5),
                            offset: const Offset(2.0, 2.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Card(
                    color: Colors.black.withOpacity(0.7),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Iniciar sesión:",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: usernameController,
                            style: const TextStyle(color: Color(0xFF1E272E)),
                            decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.person,
                                    color: Color(0xFF1E272E)),
                                labelText: 'Ingrese su username',
                                labelStyle:
                                    const TextStyle(color: Color(0xFF1E272E)),
                                hintText: 'Username',
                                hintStyle:
                                    const TextStyle(color: Color(0xFF1E272E)),
                                border: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Color(0xFF1E272E)),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Color(0xFF1E272E)),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                focusColor: Colors.transparent),
                          ),
                          const SizedBox(height: 15),
                          TextField(
                            controller: passwordController,
                            obscureText: _obscureText,
                            style: const TextStyle(color: Color(0xFF1E272E)),
                            decoration: InputDecoration(
                                labelText: 'Contraseña',
                                labelStyle:
                                    const TextStyle(color: Color(0xFF1E272E)),
                                hintText: 'Contraseña',
                                hintStyle:
                                    const TextStyle(color: Color(0xFF1E272E)),
                                border: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Color(0xFF1E272E)),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Color(0xFF1E272E)),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureText
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: const Color(0xFF1E272E),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureText = !_obscureText;
                                    });
                                  },
                                ),
                                prefixIcon: const Icon(
                                  Icons.password,
                                  color: Color(0xFF1E272E),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                focusColor: Colors.transparent),
                          ),
                          const SizedBox(height: 15),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleSignIn,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E272E),
                                padding: const EdgeInsets.all(12),
                              ),
                              child: const Text(
                                "Iniciar sesión",
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _handleBiometricSignIn,
                              icon: const Icon(Icons.fingerprint,
                                  color: Colors.white),
                              label: const Text(
                                "Iniciar con biométricos",
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueGrey,
                                padding: const EdgeInsets.all(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          if (_error != null)
                            Text(
                              _error!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          _loadingOverlay(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

Future<List<Map<String, dynamic>>> getDistances(
    String apiKey, LatLng origin, List<LatLng> destinations) async {
  // Limitar el número de destinos para no exceder el límite de la API
  const int maxDestinations = 25;
  if (destinations.length > maxDestinations) {
    destinations = destinations.sublist(0, maxDestinations);
  }

  // Crear la cadena de destinos
  final destinationsString =
      destinations.map((d) => '${d.latitude},${d.longitude}').join('|');
  final url =
      'https://maps.googleapis.com/maps/api/distancematrix/json?origins=${origin.latitude},${origin.longitude}&destinations=$destinationsString&key=$apiKey';

  print('Request URL: $url');

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<Map<String, dynamic>> distances = [];
      for (int i = 0; i < data['rows'][0]['elements'].length; i++) {
        distances.add({
          'destination': destinations[i],
          'distance': data['rows'][0]['elements'][i]['distance']['value'],
          'duration': data['rows'][0]['elements'][i]['duration']['value'],
        });
      }
      return distances;
    } else {
      print('Error response: ${response.body}');
      throw Exception('Error fetching distance matrix');
    }
  } catch (e) {
    print('Error: $e');
    throw Exception('Error fetching distance matrix');
  }
}

Future<List<Map<String, String>>> orderMedidoresByProximity(
    String apiKey, LatLng origin, List<Map<String, String>> medidores) async {
  List<LatLng> destinationLatLngs = medidores
      .map((m) =>
          LatLng(double.parse(m['bscntlati']!), double.parse(m['bscntlogi']!)))
      .toList();
  List<Map<String, dynamic>> distances =
      await getDistances(apiKey, origin, destinationLatLngs);

  // Ordenar medidores por distancia
  distances.sort((a, b) => a['distance'].compareTo(b['distance']));

  // Obtener los medidores ordenados
  List<Map<String, String>> orderedMedidores = [];
  for (var distance in distances) {
    int index = destinationLatLngs.indexOf(distance['destination']);
    orderedMedidores.add(medidores[index]);
  }

  return orderedMedidores;
}

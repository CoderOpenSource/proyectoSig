import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mapas_api/blocs/blocs.dart';
import 'package:mapas_api/helpers/cortes/database_helper.dart';
import 'package:mapas_api/helpers/widgets_to_marker.dart';
import 'package:mapas_api/markers/cortado_marker.dart';
import 'package:mapas_api/models/medidor.dart';
import 'package:mapas_api/models/route_destination.dart';
import 'package:mapas_api/screens/register_cut_screen.dart';
import 'package:mapas_api/services/apiGoogle.dart';
import 'package:mapas_api/views/map_view.dart';
import 'package:mapas_api/widgets/app_drawer.dart';
import 'package:mapas_api/widgets/widgets.dart';

class MapScreen2 extends StatefulWidget {
  final List<Map<String, String>> medidores;

  const MapScreen2({Key? key, required this.medidores}) : super(key: key);

  @override
  State<MapScreen2> createState() => _MapScreen2State();
}

class _MapScreen2State extends State<MapScreen2> {
  late LocationBloc locationBloc;
  late MapBloc mapBloc;

  Set<Polyline> polylines = {};
  Set<Marker> markers = {};
  double totalDistance = 0.0; // Distancia acumulada en metros
  int totalDuration = 0; // Duración acumulada en minutos
  int totalMedidores = 0;
  int cortados = 0;

  List<Map<String, dynamic>> medidorCortado =
      List<Map<String, dynamic>>.generate(
    25,
    (index) => {'isCut': false, 'cutDate': DateTime.now().toString()},
  ); // Inicializar la lista con 25 elementos con isCut: false y cutDate: null

  @override
  void initState() {
    super.initState();
    locationBloc = BlocProvider.of<LocationBloc>(context);
    mapBloc = BlocProvider.of<MapBloc>(context);
  }

  @override
  void dispose() {
    locationBloc.stopFollowingUser();
    super.dispose();
  }

  void _updateMarkerToCut(Medidor medidor, int index) async {
    final markerId = MarkerId('end_$index');

    // Remueve el marcador antiguo
    markers.removeWhere((marker) => marker.markerId == markerId);

    // Crear un marcador con un ícono personalizado
    final customIcon = await CustomMarkerHelper.createCustomMarkerIcon(
      index + 1,
      'Cortado',
      medidor.ncnt.toString(),
      medidor.nomb,
    );

    final updatedMarker = Marker(
      markerId: markerId,
      position: LatLng(medidor.lat, medidor.lng),
      infoWindow: InfoWindow(
        title: 'Cortado',
        snippet: 'Cuenta: ${medidor.ncnt}\nNombre: ${medidor.nomb}',
      ),
      icon: customIcon, // Ícono personalizado
      onTap: () {
        _showRegisterCutModal(context, medidor, index);
      },
    );

    // Añade el marcador actualizado
    setState(() {
      markers.add(updatedMarker);
      cortados++;
    });

    print(
        'Marcador personalizado actualizado para medidor ${medidor.nomb} (Index $index)');
  }

  void _showRegisterCutModal(BuildContext context, Medidor medidor, int index) {
    // Imprime los datos del medidor al abrir el modal
    print('Datos del medidor (Index $index):');
    print('Id: ${medidor.id}');
    print('Nombre: ${medidor.nomb}');
    print('Cuenta: ${medidor.ncnt}');
    print('Latitud: ${medidor.lat}');
    print('Longitud: ${medidor.lng}');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Color.fromARGB(255, 10, 0, 40),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                medidorCortado[index]['isCut']
                    ? 'Este medidor ya ha sido cortado'
                    : 'Registrar Corte para ${medidor.nomb}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Cuenta: ${medidor.ncnt}',
                style: const TextStyle(
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: medidorCortado[index]['isCut']
                    ? null
                    : () async {
                        Navigator.pop(context);

                        // Registrar el corte y verificar el éxito
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegisterCutScreen(
                                medidor: medidor, index: index),
                          ),
                        );

                        if (result == true) {
                          setState(() {
                            print('Medidor marcado como cortado');
                            medidorCortado[index] = {
                              'isCut': true,
                              'cutDate': DateTime.now().toString()
                            };
                          });

                          // Actualizar el estado en la base de datos
                          final dbHelper = DatabaseHelper.instance;
                          await dbHelper.updateCortado(
                            medidor.id,
                            true,
                            fechaCorte: DateTime.now()
                                .toIso8601String(), // Registrar la fecha actual en formato ISO 8601
                          );
                          print(
                              'Base de datos actualizada para medidor con ID: ${medidor.id}');

                          // Actualizar el marcador en el mapa
                          _updateMarkerToCut(medidor, index);
                        }
                      },
                icon: Icon(Icons.check, color: Color.fromARGB(255, 10, 0, 40)),
                label: Text(
                  medidorCortado[index]['isCut']
                      ? 'Medidor ya cortado'
                      : 'Registrar Corte',
                  style: TextStyle(color: Color.fromARGB(255, 10, 0, 40)),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Theme.of(context).primaryColor,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close, color: Color.fromARGB(255, 10, 0, 40)),
                label: Text(
                  'Cerrar',
                  style: TextStyle(color: Color.fromARGB(255, 10, 0, 40)),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Color.fromARGB(255, 10, 0, 40),
                  backgroundColor: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _drawRoutes() async {
    final searchBloc = BlocProvider.of<SearchBloc>(context);

    LatLng? currentPosition = const LatLng(-17.776373, -63.195093);

    List<Map<String, String>> limitedMedidores = widget.medidores.length > 25
        ? widget.medidores.sublist(0, 25)
        : widget.medidores;

    totalMedidores = limitedMedidores.length;

    List<Map<String, String>> orderedMedidores =
        await orderMedidoresByProximity(
            'AIzaSyC5s1oHt0a6THXOSO_iHWrbBM6YYU1I88g',
            currentPosition,
            limitedMedidores);

    print('Número de medidores ordenados: ${orderedMedidores.length}');

    totalDistance = 0.0; // Reiniciar distancia total
    totalDuration = 0; // Reiniciar duración total

    const double speedKmPerHour = 15.0; // Velocidad constante en km/h

    for (var i = 0; i < orderedMedidores.length; i++) {
      print('Medidor $i ${orderedMedidores[i]}');
      var start = i == 0
          ? currentPosition
          : LatLng(double.parse(orderedMedidores[i - 1]['bscntlati']!),
              double.parse(orderedMedidores[i - 1]['bscntlogi']!));
      var endMedidor = Medidor.fromMap(orderedMedidores[i]);

      final end = LatLng(endMedidor.lat, endMedidor.lng);

      print('Calculando ruta de $start a $end');

      try {
        final destination = await searchBloc.getCoorsStartToEnd(start, end);
        print('Ruta calculada para el marcador $i');

        // Acumular distancia y duración solo desde el marcador 1
        if (i > 0) {
          // Acumular distancia
          totalDistance += destination.distance;

          // Calcular tiempo de viaje a velocidad constante (en horas)
          double distanceInKm = destination.distance / 1000.0; // Convertir a km
          double travelTimeInHours = distanceInKm / speedKmPerHour;
          int travelTimeInSeconds = (travelTimeInHours * 3600).toInt();

          // Sumar duración al total
          totalDuration += travelTimeInSeconds; // Tiempo de viaje
          totalDuration +=
              600; // 10 minutos adicionales (600 segundos) por marcador
        }

        await _drawRoutePolyline(destination, i,
            'C.F.: ${endMedidor.ncnt} ${endMedidor.nomb}', endMedidor);
      } catch (e) {
        print('Error al calcular la ruta: $e');
      }
    }

    // Mostrar distancia y duración totales desde el marcador 1
    print(
        'Distancia total desde marcador 1: ${totalDistance.toStringAsFixed(2)} metros');
    print('Duración total desde marcador 1: ${totalDuration / 60} minutos');

    setState(() {
      totalDistance = totalDistance; // Actualizar la variable de clase
      totalDuration = totalDuration ~/ 60; // Guardar duración en minutos
    });
  }

  Future<void> _drawRoutePolyline(RouteDestination destination, int index,
      String startTitle, Medidor medidor) async {
    print('Puntos generados para el marcador $index: ${destination.points}');
    final polylineId = PolylineId('route_$index');
    final myRoute = Polyline(
      polylineId: polylineId,
      color: Colors.black,
      width: 4,
      points: destination.points,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
    );

    double kms = destination.distance / 1000;
    kms = (kms * 100).floorToDouble();
    kms /= 100;

    int tripDuration = (destination.duration / 60).floorToDouble().toInt();

    if (index == 0) {
      final startMarker = Marker(
        markerId: MarkerId('start_$index'),
        position: destination.points.first,
        infoWindow: InfoWindow(title: 'Inicio', snippet: startTitle),
        icon: await getStartCustomMarker(tripDuration, startTitle),
        onTap: () {
          _showRegisterCutModal(context, medidor, index);
        },
      );
      markers.add(startMarker);
      print('Añadido marcador de inicio en $index');
    }

    final endMarker = Marker(
      markerId: MarkerId('end_$index'),
      position: destination.points.last,
      infoWindow: InfoWindow(title: 'Fin', snippet: startTitle),
      icon: await getEndCustomMarker(index + 1, startTitle),
      onTap: () {
        _showRegisterCutModal(context, medidor, index);
      },
    );

    setState(() {
      polylines.add(myRoute);
      markers.add(endMarker);
      print('Añadido marcador de fin en $index');
    });

    LatLngBounds bounds;
    if (destination.points.length > 1) {
      bounds = LatLngBounds(
        southwest: LatLng(
          destination.points
              .map((point) => point.latitude)
              .reduce((a, b) => a < b ? a : b),
          destination.points
              .map((point) => point.longitude)
              .reduce((a, b) => a < b ? a : b),
        ),
        northeast: LatLng(
          destination.points
              .map((point) => point.latitude)
              .reduce((a, b) => a > b ? a : b),
          destination.points
              .map((point) => point.longitude)
              .reduce((a, b) => a > b ? a : b),
        ),
      );
    } else {
      bounds = LatLngBounds(
        southwest: destination.points.first,
        northeast: destination.points.first,
      );
    }
    mapBloc.moveCamera2(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  @override
  Widget build(BuildContext context) {
    double hours = totalDuration / 60;
    print('Total Duration $totalDuration');
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.water_drop, color: Colors.white), // Ícono de agua
            SizedBox(width: 8), // Espacio entre el ícono y el texto
            Text('MAPA DE CORTES'),
          ],
        ),
        backgroundColor:
            const Color.fromARGB(255, 10, 0, 40), // Fondo azul oscuro
      ),
      drawer: AppDrawer(
        medidores: widget.medidores,
        medidorCortado: medidorCortado,
      ),
      body: BlocBuilder<LocationBloc, LocationState>(
        builder: (context, locationState) {
          return Stack(
            children: [
              MapView(
                initialLocation: const LatLng(-17.776373, -63.195093),
                polylines: polylines.toSet(),
                markers: markers.toSet(),
              ),
              Positioned(
                bottom: 20,
                left: MediaQuery.of(context).size.width *
                    0.05, // Centrar el widget
                right: MediaQuery.of(context).size.width * 0.2,
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  color: const Color.fromARGB(255, 10, 0, 40),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Tiempo:',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            // Convierte minutos a horas decimales
                            Text(
                              '${hours.toStringAsFixed(2)} hrs',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Distancia:',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${totalDistance.toStringAsFixed(0)} mts',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total:',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '$totalMedidores', // totalMedidores es de tipo int
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Cortados:',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '$cortados', // cortados es de tipo int
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: CircleAvatar(
              backgroundColor: Color.fromARGB(255, 10, 0, 40),
              maxRadius: 25,
              child: IconButton(
                icon: const Icon(
                  Icons.create,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: _drawRoutes,
              ),
            ),
          ),
          const BtnFollowUser(),
          const BtnCurrentLocation(),
        ],
      ),
    );
  }
}

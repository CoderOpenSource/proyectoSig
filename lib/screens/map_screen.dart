import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mapas_api/blocs/blocs.dart';
import 'package:mapas_api/helpers/widgets_to_marker.dart';
import 'package:mapas_api/models/medidor.dart';
import 'package:mapas_api/models/route_destination.dart';
import 'package:mapas_api/screens/home_pasajero.dart';
import 'package:mapas_api/screens/register_cut_screen.dart';
import 'package:mapas_api/services/apiGoogle.dart';
import 'package:mapas_api/views/map_view.dart';
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
  List<bool> medidorCortado =
      List<bool>.filled(25, false); // Inicializar la lista con 25 falsos

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

  void _showRegisterCutModal(BuildContext context, Medidor medidor, int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).primaryColor,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                medidorCortado[index]
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
                onPressed: medidorCortado[index]
                    ? null
                    : () async {
                        Navigator.pop(context);
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegisterCutScreen(
                                medidor: medidor, index: index),
                          ),
                        );
                        if (result == true) {
                          setState(() {
                            medidorCortado[index] = true;
                          });
                        }
                      },
                icon: Icon(Icons.check, color: Theme.of(context).primaryColor),
                label: Text(
                  medidorCortado[index]
                      ? 'Medidor ya cortado'
                      : 'Registrar Corte',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Theme.of(context).primaryColor,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close, color: Theme.of(context).primaryColor),
                label: Text(
                  'Cerrar',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Theme.of(context).primaryColor,
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

    LatLng? currentPosition;
    if (locationBloc.state.lastKnownLocation != null) {
      currentPosition = LatLng(
        locationBloc.state.lastKnownLocation!.latitude,
        locationBloc.state.lastKnownLocation!.longitude,
      );
    } else {
      print('No se pudo obtener la posición actual del usuario');
      return;
    }

    List<Map<String, String>> limitedMedidores = widget.medidores.length > 25
        ? widget.medidores.sublist(0, 25)
        : widget.medidores;

    List<Map<String, String>> orderedMedidores =
        await orderMedidoresByProximity(
            'AIzaSyCd_nuPnvC-us0y3niaIt7vsbrkcyxqUik',
            currentPosition,
            limitedMedidores);

    print('Número de medidores ordenados: ${orderedMedidores.length}');
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
        await _drawRoutePolyline(destination, i,
            'C.F.: ${endMedidor.ncnt} ${endMedidor.nomb}', endMedidor);
      } catch (e) {
        print('Error al calcular la ruta: $e');
      }
    }
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Recorrido de Cortes'),
      ),
      drawer: const AppDrawer(),
      body: BlocBuilder<LocationBloc, LocationState>(
        builder: (context, locationState) {
          if (locationState.lastKnownLocation == null) {
            return const Center(child: Text('Espere por favor...'));
          }

          return Stack(
            children: [
              MapView(
                initialLocation: locationBloc.state.lastKnownLocation!,
                polylines: polylines.toSet(),
                markers: markers.toSet(),
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
              backgroundColor: Theme.of(context).primaryColor,
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

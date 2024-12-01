import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:mapas_api/blocs/blocs.dart';

import 'package:mapas_api/views/map_view.dart';
import 'package:mapas_api/widgets/app_drawer.dart';
import 'package:mapas_api/widgets/btn_follow_user.dart';
import 'package:mapas_api/widgets/btn_location.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with SingleTickerProviderStateMixin {
  late LocationBloc locationBloc;
  bool isDescriptionVisible =
      true; // Controla la visibilidad del texto flotante

  @override
  void initState() {
    super.initState();
    locationBloc = BlocProvider.of<LocationBloc>(context);
  }

  @override
  void dispose() {
    locationBloc.stopFollowingUser();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.water_drop, color: Colors.white), // Ícono de agua
            SizedBox(width: 8), // Espacio entre el ícono y el texto
            Text('COOSIV R.L.'),
          ],
        ),
        backgroundColor:
            const Color.fromARGB(255, 10, 0, 40), // Fondo azul oscuro
      ),

      body: BlocBuilder<LocationBloc, LocationState>(
        builder: (context, locationState) {
          return BlocBuilder<MapBloc, MapState>(
            builder: (context, mapState) {
              Map<String, Polyline> polylines = Map.from(mapState.polylines);

              if (!mapState.showMyRoute) {
                polylines.removeWhere((key, value) => key == 'myRoute');
              }

              return Stack(
                children: [
                  MapView(
                    initialLocation: const LatLng(-17.776373, -63.195093),
                    polylines: polylines.values.toSet(),
                    markers: mapState.markers.values.toSet(),
                  ),
                  if (isDescriptionVisible) // Controla la visibilidad del texto
                    Positioned(
                      top: 16, // Margen superior
                      left: 16,
                      right: 16,
                      child: Card(
                        color: const Color.fromARGB(
                            255, 10, 0, 40), // Fondo azul oscuro
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.info,
                                      color: Colors.white,
                                      size: 24), // Ícono de información
                                  SizedBox(
                                      width:
                                          8), // Espacio entre el icono y el texto
                                  Text(
                                    'Descripción de la Aplicación',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                  height:
                                      16), // Espacio entre título y contenido
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.map,
                                      color: Colors.white,
                                      size: 20), // Ícono de mapa
                                  SizedBox(
                                      width: 8), // Espacio entre ícono y texto
                                  Expanded(
                                    child: Text(
                                      'Esta aplicación te permite visualizar el mapa de los cortes de agua en tu área.',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12), // Espacio entre filas
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.location_on,
                                      color: Colors.white,
                                      size: 20), // Ícono de ubicación
                                  SizedBox(
                                      width: 8), // Espacio entre ícono y texto
                                  Expanded(
                                    child: Text(
                                      'Puedes seguir tu ubicación y explorar las rutas de cortes planificados.',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12), // Espacio entre filas
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.menu,
                                      color: Colors.white,
                                      size: 20), // Ícono de menú
                                  SizedBox(
                                      width: 8), // Espacio entre ícono y texto
                                  Expanded(
                                    child: Text(
                                      'Usa el menú lateral para acceder a diferentes funcionalidades como configuración y ayuda.',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'toggleDescription',
            backgroundColor:
                const Color.fromARGB(255, 10, 0, 40), // Fondo azul oscuro
            onPressed: () {
              setState(() {
                isDescriptionVisible = !isDescriptionVisible;
              });
            },
            child: Icon(
              isDescriptionVisible ? Icons.visibility_off : Icons.visibility,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const BtnFollowUser(),
          const BtnCurrentLocation(),
        ],
      ),
      drawer: const AppDrawer(), // Usa tu Drawer existente
    );
  }
}

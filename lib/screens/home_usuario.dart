import 'package:flutter/material.dart';


import 'package:flutter_bloc/flutter_bloc.dart';


import 'package:google_maps_flutter/google_maps_flutter.dart';


import 'package:mapas_api/blocs/blocs.dart';


import 'package:mapas_api/screens/configuration.dart';


import 'package:mapas_api/screens/generate_cuts_screen.dart';


import 'package:mapas_api/screens/loading_screen.dart';


import 'package:mapas_api/screens/user/login_user.dart';


import 'package:mapas_api/themes/light_theme.dart';


import 'package:mapas_api/views/map_view.dart';


import 'package:mapas_api/widgets/btn_toggle_user_route.dart';


import 'package:mapas_api/widgets/widgets.dart';


import 'package:photo_view/photo_view.dart';


import 'package:shared_preferences/shared_preferences.dart';


class MapScreen extends StatefulWidget {

  const MapScreen({Key? key}) : super(key: key);


  @override

  State<MapScreen> createState() => _MapScreenState();

}


class _MapScreenState extends State<MapScreen>

    with SingleTickerProviderStateMixin {

  late LocationBloc locationBloc;


  @override

  void initState() {

    super.initState();


    locationBloc = BlocProvider.of<LocationBloc>(context);


    locationBloc.startFollowingUser();

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

        title: const Text('Mapa de Recorrido de Cortes'),

      ),

      body: BlocBuilder<LocationBloc, LocationState>(

        builder: (context, locationState) {

          if (locationState.lastKnownLocation == null) {

            return const Center(child: Text('Espere por favor...'));

          }


          return BlocBuilder<MapBloc, MapState>(

            builder: (context, mapState) {

              Map<String, Polyline> polylines = Map.from(mapState.polylines);


              if (!mapState.showMyRoute) {

                polylines.removeWhere((key, value) => key == 'myRoute');

              }


              return Stack(

                children: [

                  MapView(

                    initialLocation: locationState.lastKnownLocation!,

                    polylines: polylines.values.toSet(),

                    markers: mapState.markers.values.toSet(),

                  ),

                ],

              );

            },

          );

        },

      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      floatingActionButton: const Column(

        mainAxisAlignment: MainAxisAlignment.end,

        children: [

          BtnToggleUserRoute(),

          BtnFollowUser(),

          BtnCurrentLocation(),

        ],

      ),

      drawer: const AppDrawer(),

    );

  }

}


void _showImagePreview(BuildContext context, String imageUrl) {

  showDialog(

    context: context,

    builder: (ctx) {

      return GestureDetector(

        onTap: () {

          Navigator.pop(ctx);

        },

        child: Container(

          child: PhotoView(

            imageProvider: NetworkImage(imageUrl),

            backgroundDecoration: const BoxDecoration(

              color: Colors.black,

            ),

          ),

        ),

      );

    },

  );

}


class AppDrawer extends StatefulWidget {

  const AppDrawer({super.key});


  @override

  _AppDrawerState createState() => _AppDrawerState();

}


class _AppDrawerState extends State<AppDrawer> {

  String userName = '';


  @override

  void initState() {

    super.initState();


    _loadUserName();

  }


  Future<void> _loadUserName() async {

    final prefs = await SharedPreferences.getInstance();


    final name = prefs.getString('userName');


    setState(() {

      userName = name ?? 'Nombre del Usuario';

    });

  }


  @override

  Widget build(BuildContext context) {

    return Drawer(

      child: ListView(

        children: <Widget>[

          DrawerHeader(

            decoration: BoxDecoration(

              color: Theme.of(context).primaryColor,

            ),

            child: Column(

              mainAxisAlignment: MainAxisAlignment.center,

              children: [

                CircleAvatar(

                  backgroundColor: Colors.grey[200],

                  child: Icon(Icons.person, size: 50, color: Colors.grey[800]),

                ),

                const SizedBox(height: 10),

                Text(

                  userName,

                  style: const TextStyle(color: Colors.white, fontSize: 24.0),

                ),

              ],

            ),

          ),

          ListTile(

            leading: Icon(Icons.home, color: Theme.of(context).primaryColor),

            title: Text(

              'Inicio',

              style: TextStyle(color: Theme.of(context).primaryColor),

            ),

            onTap: () {

              Navigator.of(context).pushReplacement(

                MaterialPageRoute(builder: (context) => const LoadingScreen()),

              );

            },

          ),

          ListTile(

            leading: Icon(Icons.list, color: Theme.of(context).primaryColor),

            title: Text(

              'Generar Lista para Cortes',

              style: TextStyle(color: Theme.of(context).primaryColor),

            ),

            onTap: () {

              Navigator.of(context).push(

                MaterialPageRoute(

                    builder: (context) => const GenerateCutsScreen()),

              );

            },

          ),

          ListTile(

            leading:

                Icon(Icons.settings, color: Theme.of(context).primaryColor),

            title: Text(

              'Configuración',

              style: TextStyle(color: Theme.of(context).primaryColor),

            ),

            onTap: () {

              Navigator.of(context).push(

                MaterialPageRoute(builder: (context) => const SettingsScreen()),

              );

            },

          ),

          Padding(

            padding:

                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),

            child: ElevatedButton(

              style: ElevatedButton.styleFrom(

                backgroundColor: lightUberTheme.primaryColor,

                padding:

                    const EdgeInsets.symmetric(horizontal: 70, vertical: 15),

                shape: RoundedRectangleBorder(

                  borderRadius: BorderRadius.circular(10),

                ),

              ),

              onPressed: () {

                _showLogoutConfirmation(context);

              },

              child: const Row(

                mainAxisSize: MainAxisSize.min,

                children: [

                  Icon(Icons.power_settings_new, color: Colors.white),

                  SizedBox(width: 5),

                  Text("Cerrar sesión", style: TextStyle(color: Colors.white)),

                ],

              ),

            ),

          ),

        ],

      ),

    );

  }


  void _showLogoutConfirmation(BuildContext context) {

    showDialog(

      context: context,

      builder: (BuildContext context) {

        return AlertDialog(

          shape: const RoundedRectangleBorder(

            borderRadius: BorderRadius.all(Radius.circular(32.0)),

          ),

          content: Column(

            mainAxisSize: MainAxisSize.min,

            children: [

              const Text(

                "😲 ¿Estás seguro?",

                style: TextStyle(

                  color: Color.fromARGB(255, 8, 45, 101),

                  fontSize: 18,

                ),

              ),

              const SizedBox(height: 20),

              Row(

                mainAxisAlignment: MainAxisAlignment.spaceAround,

                children: [

                  TextButton(

                    onPressed: () => Navigator.pop(context),

                    child: const Text(

                      "Cancelar",

                      style: TextStyle(color: Color.fromARGB(255, 8, 45, 101)),

                    ),

                  ),

                  TextButton(

                    onPressed: () {

                      _logout(context);

                    },

                    child: const Text(

                      "Sí",

                      style: TextStyle(color: Color.fromARGB(255, 8, 45, 101)),

                    ),

                  ),

                ],

              ),

            ],

          ),

        );

      },

    );

  }


  void _logout(BuildContext context) async {

    final prefs = await SharedPreferences.getInstance();


    // Remove the stored preferences


    prefs.remove('accessToken');


    prefs.remove('userName');


    prefs.remove('registro');


    // Navigate to the login page and remove all other screens from the navigation stack


    Navigator.of(context).pushAndRemoveUntil(

      MaterialPageRoute(

        builder: (BuildContext context) => const LoginView(),

      ),

      (Route<dynamic> route) => false,

    );

  }

}


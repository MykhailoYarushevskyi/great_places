import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import './screens/add_place_screen.dart';
import './screens/place_detail_screen.dart';
import './screens/places_list_screen.dart';
import './providers/user_places.dart';
import './screens/map_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserPlaces(),
      child: MaterialApp(
        title: 'Great Places',
        theme: ThemeData(
          // This is the theme of your application.
          primarySwatch: Colors.indigo,
          accentColor: Colors.amber,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          pageTransitionsTheme: PageTransitionsTheme(builders: {
            // TargetPlatform.android : OpenUpwardsPageTransitionsBuilder(),
            // TargetPlatform.android : ZoomPageTransitionsBuilder(),
            // TargetPlatform.android : FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.android : CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS : CupertinoPageTransitionsBuilder(),
          },),
        ),
        // home: PlacesListScreen(),
        initialRoute: '/',
        routes: {
          '/': (context) => PlacesListScreen(),
          AddPlaceScreen.routeName: (context) => AddPlaceScreen(),
          PlaceDetailScreen.routeName: (context) => PlaceDetailScreen(),
          MapScreen.routeName: (context) => MapScreen()
        },
      ),
    );
  }
}

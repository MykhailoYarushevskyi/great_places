import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/place.dart';

class MapScreen extends StatefulWidget {
  static const String routeName = '/map-screen';
  final PlaceLocation initialLocation;
  final bool isSelecting;
  final bool isMyLocationEnabled;

  MapScreen({
    initLocation,
    this.isSelecting = false,
    this.isMyLocationEnabled = false,
  }) : initialLocation = initLocation != null
            ? initLocation
            : const PlaceLocation(
                //default location (Google)
                latitude: 37.422,
                longitude: -122.084,
              );

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng _pickedLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Map'),
        centerTitle: true,
        actions: [
          if (widget.isSelecting)
            IconButton(
              icon: Icon(Icons.check),
              onPressed: _pickedLocation == null
                  ? null
                  : () => Navigator.of(context).pop(_pickedLocation),
            ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
            target: LatLng(
              widget.initialLocation.latitude,
              widget.initialLocation.longitude,
            ),
            zoom: 16.0),
        onTap: widget.isSelecting ? _selectLocation : null,
        markers: (_pickedLocation == null && widget.isSelecting)
            ? null
            : {
                Marker(
                  markerId: MarkerId('my1'),
                  position: _pickedLocation ??
                      LatLng(
                        widget.initialLocation.latitude,
                        widget.initialLocation.longitude,
                      ),
                ),
              },
        myLocationEnabled: widget.isMyLocationEnabled,
      ),
    );
  }

  /// save selected location
  void _selectLocation(LatLng location) {
    setState(() {
      _pickedLocation = location;
    });
  }
}

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../helpers/location_helper.dart';
import '../screens/map_screen.dart';
import '../models/place.dart';

/// Provides obtaining the user location and the static map image URL
/// according to the user location
class LocationInput extends StatefulWidget {
  final Function onSelectLocation;
  LocationInput(this.onSelectLocation);

  @override
  _StateLocationInput createState() => _StateLocationInput();
}

class _StateLocationInput extends State<LocationInput> {
  static const String MAIN_TAG = '## LocationInput';

  Image _staticPreviewMapImage;
  String _previewMapImageUrl;
  double _latitude;
  double _longitude;
  // it shows whether select or not user location on the Map Screen
  bool _isSelectingLocationOnMap = true;
  bool _isLoading = false;

  Widget build(BuildContext context) {
    double _heightPreviewImage = 170.0;
    return Column(
      children: <Widget>[
        Stack(
          alignment: AlignmentDirectional.center,
          children: <Widget>[
            Container(
              height: _heightPreviewImage,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1,
                  color: Colors.grey,
                ),
              ),
              child: _previewMapImageUrl == null
                  ? Text(
                      'Location do not choosed yet!',
                      textAlign: TextAlign.center,
                    )
                  : !_isCorrectPreviewImageUrl() &&
                          _staticPreviewMapImage != null
                      ? _staticPreviewMapImage
                      // show the dummy image
                      : Image.asset(
                          'assets/images/chris-lawton-duQ1ulzTJbM-unsplash.jpg'),
            ),
            if (_isLoading)
              Positioned(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(children: [
              Text(
                  'Latitude: ${!_isLatLngNull ? _latitude.toStringAsFixed(8) : ''}'),
              Text(
                  'Longitude: ${!_isLatLngNull ? _longitude.toStringAsFixed(8) : ''}'),
            ]),
            TextButton.icon(
              onPressed: !_isLatLngNull
                  ? () => Clipboard.setData(
                        ClipboardData(text: '$_latitude,$_longitude'),
                      )
                  : null,
              icon: Icon(Icons.copy),
              label: Text('Copy to Clipboard'),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            TextButton.icon(
              icon: Icon(Icons.location_on),
              label: Text(
                'Current Location',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
              onPressed: () => _setUpStaticPreviewMapImage(label: 'A'),
            ),
            TextButton.icon(
              icon: Icon(Icons.map),
              label: Text(
                'Select on Map',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
              onPressed: _selectOnMap,
            ),
          ],
        )
      ],
    );
  }

  void _setIsLoading(bool isLoading) {
    setState(() {
      _isLoading = isLoading;
    });
  }

  bool _isCorrectPreviewImageUrl() => _previewMapImageUrl.startsWith('https');

  bool get _isLatLngNull {
    return _latitude == null || _longitude == null;
  }

  Future<void> _getstaticPreviewMapImage() async {
    _setIsLoading(true);
    try {
      Image _staticPreviewMapImage = Image.network(_previewMapImageUrl);
      log('$MAIN_TAG.getPreviewImage _staticPreviewMapImage: $_staticPreviewMapImage');
    } catch (error) {
      await _showError(
        title: 'An error occurred while loading the static map image:',
        error: error,
      );
    } finally {
      _setIsLoading(false);
    }
  }

  Future<void> _setUpStaticPreviewMapImage({String label}) async {
    _setIsLoading(true);
    try {
      await _getCurrentUserLocation();
      await _getLocationPreviewMapImageUrl(
        latitudeLocation: _latitude,
        longitudeLocation: _longitude,
        label: label,
      );
      await _getstaticPreviewMapImage();
    } finally {
      _setIsLoading(false);
    }
  }

  /// getting the current location([_latitude] and [_longitude])
  /// of the user so defining as a location of their device,
  /// then getting [_previewMapImageUrl] for showing preview map image
  /// with current user location
  Future<void> _getCurrentUserLocation() async {
    Location location = new Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    print('$MAIN_TAG._getCurrentUserLocation() Entrance');
    try {
      _serviceEnabled = await location.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await location.requestService();
        if (!_serviceEnabled) {
          return;
        }
      }
      _permissionGranted = await location.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await location.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          return;
        }
      }
      if (location == null) {
        throw 'Location instance is null';
      }
      _locationData = await location.getLocation();
      if (_locationData == null) {
        throw 'LocationData instance is null';
      }
    } catch (error) {
      await _showError(error: error);
      return;
    }
    setState(() {
      _latitude = _locationData.latitude;
      _longitude = _locationData.longitude;
      widget.onSelectLocation(
        latitude: _latitude,
        longitude: _longitude,
      );
    });
  }

  /// getting the URL [staticMapImageUrl] where contains at the Google Map server
  /// with center at the [latitudeLocation] and
  /// the [longitudeLocation] what marked with label [label]
  Future<void> _getLocationPreviewMapImageUrl({
    @required double latitudeLocation,
    @required double longitudeLocation,
    String label,
  }) async {
    try {
      log('$MAIN_TAG.getLocationPreviewImage() Entrance');
      final staticMapImageUrl =
          await LocationHelper.generateLocationPreviewMapImageUrl(
        latitude: latitudeLocation,
        longitude: longitudeLocation,
        label: label,
      );
      setState(() {
        _previewMapImageUrl = staticMapImageUrl;
      });
    } catch (error) {
      await _showError(error: error);
    }
  }

  /// going to MapScreen() widget and waiting for the result
  /// [selectedLocation] from this widget. If [selectedLocation]
  /// is not null, defining the user's selected location([_latitude]
  /// and [_longitude])
  /// if user did not select location yet, setiing ud default init location
  Future<void> _selectOnMap() async {
    _setIsLoading(true);
    try {
      if (_isLatLngNull) {
        await _getCurrentUserLocation();
      }
      final selectedLocation = await Navigator.of(context).push<LatLng>(
        MaterialPageRoute(
          // fullscreenDialog: true,
          builder: (context) => MapScreen(
            initLocation: _isLatLngNull
                ? PlaceLocation(
                    //default location
                    latitude: 37.422,
                    longitude: -122.084,
                  )
                : PlaceLocation(
                    //current location
                    latitude: _latitude,
                    longitude: _longitude,
                  ),
            isSelecting: _isSelectingLocationOnMap,
            isMyLocationEnabled: true,
          ),
        ),
      );
      if (selectedLocation == null) {
        return;
      }
      // getting snapshot for location that user selected on GoogleMap
      await _getLocationPreviewMapImageUrl(
          latitudeLocation: selectedLocation.latitude,
          longitudeLocation: selectedLocation.longitude,
          label: 'C');
      setState(() {
        _latitude = selectedLocation.latitude;
        _longitude = selectedLocation.longitude;
        widget.onSelectLocation(
          latitude: _latitude,
          longitude: _longitude,
        );
      });
    } catch (error) {
      await _showError(
          title: 'An error occurred while loading the map:', error: error);
    } finally {
      _setIsLoading(false);
    }
  }

  Future<void> _showError({
    String title = 'Something go Wrong!',
    String error,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Ok'),
          )
        ],
        title: Text(title),
        content: Text(error),
      ),
    );
  }
}

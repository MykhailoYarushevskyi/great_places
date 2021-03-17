import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../helpers/location_helper.dart';
import '../screens/map_screen.dart';
import '../models/place.dart';

class LocationInput extends StatefulWidget {
  final Function onSelectLocation;
  LocationInput(this.onSelectLocation);

  @override
  _StateLocationInput createState() => _StateLocationInput();
}

class _StateLocationInput extends State<LocationInput> {
  static const String MAIN_TAG = '## LocationInput';

  String _previewImageUrl;
  double _latitude;
  double _longitude;
  bool _isSelecting = true; // whether select user location on the Map Screen
  bool _isLoading = false;

  Widget build(BuildContext context) {
    // double _widthDevice = MediaQuery.of(context).size.width;
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
              // child: Stack(
              //   alignment: AlignmentDirectional.center,
              //   fit: StackFit.passthrough,
              //   children: <Widget>[
              child: _previewImageUrl == null
                  ? Text(
                      'Location do not choosed yet!',
                      textAlign: TextAlign.center,
                    )
                  : _previewImageUrl.startsWith('http')
                      ? Image.network(_previewImageUrl)
                      // ? PreviewImage(_previewImageUrl)
                      // show the dummy image
                      : Image.asset(
                          'assets/images/chris-lawton-duQ1ulzTJbM-unsplash.jpg'),
              // if (_isLoading)
              //   Positioned(
              //     child: CircularProgressIndicator(),
              //     // height: 80.00
              //     height: _heightPreviewImage * 0.2,
              //     width: _heightPreviewImage * 0.2,
              //   ),
            ),
            if (_isLoading)
              Positioned(
                child: CircularProgressIndicator(),
                // height: _heightPreviewImage * 0.2,
                // width: _heightPreviewImage * 0.2,
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
            FlatButton.icon(
              onPressed: () => !_isLatLngNull
                  ? Clipboard.setData(
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
            FlatButton.icon(
              icon: Icon(Icons.location_on),
              label: Text(
                'Current Location',
                style: TextStyle(),
              ),
              textColor: Theme.of(context).primaryColor,
              onPressed: () => _setUpPreviewImage(label: 'A'),
            ),
            FlatButton.icon(
              icon: Icon(Icons.map),
              label: Text(
                'Select on Map',
                style: TextStyle(),
              ),
              textColor: Theme.of(context).primaryColor,
              onPressed: _selectOnMap,
            ),
          ],
        )
      ],
    );
  }

  bool get _isLatLngNull {
    return _latitude == null || _longitude == null;
  }

  Widget getPreviewImage(imageUrl) {
    setState(() {
      _isLoading = true;
    });
    Image image = Image.network(_previewImageUrl);
    log('$MAIN_TAG.getPreviewImage image: $image');
    return image;
  }

  Future<void> _setUpPreviewImage({String label}) async {
    setState(() {
      _isLoading = true;
    });
    await _getCurrentUserLocation();
    await _getLocationPreviewImage(
      latitudeLocation: _latitude,
      longitudeLocation: _longitude,
      label: label,
    );
    setState(() {
      _isLoading = false;
    });
  }

  /// getting the current location([_latitude] and [_longitude])
  /// of the user so defining as a location of their device,
  /// then getting [_previewImageUrl] for showing preview map image
  /// with current user location
  Future<void> _getCurrentUserLocation() async {
    Location location = new Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    print('$MAIN_TAG._getCurrentUserLocation() Entrance');
    try {
      _serviceEnabled = await location.serviceEnabled();
      // print('$MAIN_TAG._getCurrentUserLocation() _serviceEnabled: $_serviceEnabled');
      if (!_serviceEnabled) {
        _serviceEnabled = await location.requestService();
        if (!_serviceEnabled) {
          return;
        }
      }
      _permissionGranted = await location.hasPermission();
      // print('$MAIN_TAG._getCurrentUserLocation() _permissionGranted: $_permissionGranted');
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await location.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          return;
        }
      }
      // print('$MAIN_TAG._getCurrentUserLocation() location: $location');
      if (location == null) {
        throw 'Location instance is null';
      }
      _locationData = await location.getLocation();
      // print('$MAIN_TAG._getCurrentUserLocation() _locationData: $_locationData');
      if (_locationData == null) {
        throw 'LocationData instance is null';
      }
    } catch (error) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          actions: [
            FlatButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Ok'),
            )
          ],
          title: Text('Something go Wrong!'),
          content: Text(error),
        ),
      );
      return;
    }
    setState(() {
      // print('$MAIN_TAG._getCurrentUserLocation() setState()');
      _latitude = _locationData.latitude;
      _longitude = _locationData.longitude;
      widget.onSelectLocation(
        latitude: _latitude,
        longitude: _longitude,
      );
    });
  }

  /// getting from Google Map server the URL [staticMapImageUrl]
  /// with center at the [latitudeLocation] and
  /// the [longitudeLocation] what marked with label [label]
  Future<void> _getLocationPreviewImage({
    @required double latitudeLocation,
    @required double longitudeLocation,
    String label,
  }) async {
    try {
      log('$MAIN_TAG.getLocationPreviewImage() Entrance');
      final staticMapImageUrl =
          await LocationHelper.generateLocationPreviewImage(
        latitude: latitudeLocation,
        longitude: longitudeLocation,
        label: label,
      );
      setState(() {
        _previewImageUrl = staticMapImageUrl;
      });
    } catch (error) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          actions: [
            FlatButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Ok'),
            )
          ],
          title: Text('Something go Wrong!'),
          content: Text(error),
        ),
      );
    }
  }

  /// going to MapScreen() widget and waiting for the result
  /// [selectedLocation] from this widget. If [selectedLocation]
  /// is not null, defining the user's selected location([_latitude]
  /// and [_longitude])
  /// if user did not select location yet, setiing ud default init location
  Future<void> _selectOnMap() async {
    setState(() {
      _isLoading = true;
    });
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
            isSelecting: _isSelecting,
            isMyLocationEnabled: true,
          ),
        ),
      );
      if (selectedLocation == null) {
        return;
      }
      // getting snapshot for location that user selected on GoogleMap
      await _getLocationPreviewImage(
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
      print(
          '$MAIN_TAG._selectOnMap() _latitude: $_latitude; _longitude:$_longitude');
    } catch (error) {
      throw error;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

// class PreviewImage extends StatefulWidget {
//   final String previewImageUrl;

//   PreviewImage(this.previewImageUrl);

//   @override
//   _PreviewImageState createState() => _PreviewImageState();
// }

// class _PreviewImageState extends State<PreviewImage> {
//   bool _init = false;
//   Image _image;
//   @override
//   Widget build(BuildContext context) {
//     print('## PreviewImage.build() ENTRANCE _init:$_init ; _image: $_image');
//     if (!_init) {
//       _image = Image.network(widget.previewImageUrl);
//       setState(() {
//         _init = true;
//       });
//     print('## PreviewImage.build() if(!_init). _init:$_init ; _image: $_image');
//     }
//     if (_image == null) {
//     print('## PreviewImage.build() if(_image == null). _init:$_init ; _image: $_image');
//       return CircularProgressIndicator();
//     }
//     return _image;
//   }
// }

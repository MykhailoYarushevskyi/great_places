import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/location_helper.dart';
import '../models/place.dart';
import '../providers/user_places.dart';
import '../widgets/image_input.dart';
import '../widgets/location_input.dart';

/// Collecting information about the new place and save it in the database
class AddPlaceScreen extends StatefulWidget {
  static const String routeName = '/add-place-screen';
  @override
  _AddPlaceScreenState createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends State<AddPlaceScreen> {
  static const String MAIN_TAG = '## AddPlaceScreen';

  File _pickedImage;
  var _titleController = TextEditingController();
  double _latitude;
  double _longitude;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Add a new Place'),
      ),
      extendBody: false,
      extendBodyBehindAppBar: false,
      body: Stack(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: <Widget>[
                        TextField(
                          decoration: InputDecoration(labelText: 'Title'),
                          controller: _titleController,
                        ),
                        SizedBox(height: 10),
                        ImageInput(_onSelectImage),
                        SizedBox(height: 10),
                        LocationInput(_onSelectLocation),
                      ],
                    ),
                  ),
                ),
              ),
              ElevatedButton.icon(
                icon: Icon(Icons.add),
                label: Text('Add Place'),
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all<Color>(
                      Theme.of(context).primaryColor),
                  backgroundColor:
                      MaterialStateProperty.resolveWith<Color>((states) {
                    if (states.contains(MaterialState.pressed)) {
                      return Theme.of(context).splashColor;
                    } else {
                      return Theme.of(context).accentColor;
                    }
                  }),
                  elevation: MaterialStateProperty.all<double>(0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: _savePlace,
              ),
            ],
          ),
          if (_isLoading)
            Positioned(
              top: deviceSize.height * 0.5,
              left: deviceSize.width * 0.5,
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

// callback that sending to the ImageInput widget's constructor
  void _onSelectImage(File pickedImage) {
    _pickedImage = pickedImage;
  }

  // callback that sending to the LocationInput widget's constructor
  void _onSelectLocation({
    @required double latitude,
    @required double longitude,
  }) {
    _latitude = latitude;
    _longitude = longitude;
  }

  Future<void> _savePlace() async {
    if (!_isAllowedSavePlace()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    String _address = await _getPlaceAddress();
    try {
      _addPlace(_address);
      Navigator.of(context).pop();
    } catch (error) {
      await _showError(
        title: '''While was adding the place, something went wrong!
        Your place was not saved!''',
        error: error,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _isAllowedSavePlace() {
    if (_titleController.text.isEmpty ||
        _pickedImage == null ||
        _latitude == null ||
        _longitude == null) {
      return false;
    }
    return true;
  }

  Future<String> _getPlaceAddress() async {
    String placeAddress = '';
    try {
      placeAddress = await LocationHelper.getPlaceAddress(
        latitude: _latitude,
        longitude: _longitude,
      );
      return placeAddress;
    } catch (error) {
      await _showError(
        title: '''While was getting the place address, occurred an error!
        Your place will save without the address!''',
        error: error,
      );
      return placeAddress;
    }
  }

  void _addPlace(String _address) {
    context.read<UserPlaces>().addPlace(
          pickedTitle: _titleController.text,
          pickedImage: _pickedImage,
          pickedLocation: PlaceLocation(
            latitude: _latitude,
            longitude: _longitude,
            address: _address,
          ),
        );
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

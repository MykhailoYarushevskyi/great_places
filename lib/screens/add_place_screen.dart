import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/location_helper.dart';
import '../models/place.dart';
import '../providers/user_places.dart';
import '../widgets/image_input.dart';
import '../widgets/location_input.dart';

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

// callback that sending to the ImageInput widget's constructor
  void _selectImage(File pickedImage) {
    _pickedImage = pickedImage;
  }

  // callback that sending to the LocationInput widget's constructor
  void _selectLocation({
    @required double latitude,
    @required double longitude,
  }) {
    _latitude = latitude;
    _longitude = longitude;
  }

  Future<void> _savePlace() async {
    if (_titleController.text.isEmpty ||
        _pickedImage == null ||
        _latitude == null ||
        _longitude == null) {
      return;
    }
    try {
      setState(() {
        _isLoading = true;
      });
      String _address = await LocationHelper.getPlaceAddress(
        latitude: _latitude,
        longitude: _longitude,
      );
      print('$MAIN_TAG._savePlace().address: $_address');
      context.read<UserPlaces>().addPlace(
            pickedTitle: _titleController.text,
            pickedImage: _pickedImage,
            pickedLocation: PlaceLocation(
              latitude: _latitude,
              longitude: _longitude,
              address: _address,
            ),
          );
      Navigator.of(context).pop();
    } catch (error) {
      //TODO Add showDialog
      // 
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

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
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        ImageInput(_selectImage),
                        SizedBox(height: 10),
                        LocationInput(_selectLocation),
                      ],
                    ),
                  ),
                ),
              ),
              RaisedButton.icon(
                icon: Icon(Icons.add),
                label: Text('Add Place'),
                onPressed: _savePlace,
                color: Theme.of(context).accentColor,
                //make the button sit at the bottom of the screen
                elevation: 0,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
}

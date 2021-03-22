import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../screens/map_screen.dart';
import '../models/place.dart';
import '../providers/user_places.dart';

class PlaceDetailScreen extends StatelessWidget {
  static const String routeName = '/place-detail-screen';
  static const String MAIN_TAG = '## PlaceDetailScreen';

  @override
  Widget build(BuildContext context) {
    String _placeId = ModalRoute.of(context).settings.arguments;
    Place _place = Provider.of<UserPlaces>(context).findById(_placeId);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('${_place.title}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      // child: FittedBox(
                      child: Image.file(
                        _place.image,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                      //   fit: BoxFit.cover,
                      // ),
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                          width: 1,
                          color: Colors.grey,
                          style: BorderStyle.solid),
                      // background image (appear in normal size, if defined height: in Container() )
                      // image: DecorationImage(
                      //   fit: BoxFit.cover,
                      //   image: FileImage(_place.image),
                      // ),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  ListTile(
                    title: Center(
                      child: Text(
                        '${_place.title}',
                        style: TextStyle(
                          // backgroundColor: Colors.grey,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    subtitle: Center(
                      child: Text(
                        '${_place.location.address}',
                        style: TextStyle(
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                    trailing: Consumer<UserPlaces>(
                        builder: (context, refreshedUserPlaces, child) {
                      final refreshedPlace =
                          refreshedUserPlaces.findById(_placeId);
                      return IconButton(
                        icon: refreshedPlace.isFavorite
                            ? Icon(Icons.star, color: Colors.red)
                            : Icon(Icons.star_border),
                        onPressed: () {
                          _changePlaceFavorit(context, refreshedPlace.id);
                        },
                      );
                    }),
                  ),
                  SizedBox(height: 10.0),
                ],
              ),
            ),
          ),
          TextButton.icon(
            icon: Icon(Icons.map),
            label: Text('View on the map'),
            style: ButtonStyle(
              minimumSize:
                  MaterialStateProperty.all<Size>(Size.fromHeight(40.00)),
              foregroundColor: MaterialStateProperty.all<Color>(
                  Theme.of(context).primaryColor),
              backgroundColor:
                  MaterialStateProperty.resolveWith<Color>((states) {
                if (states.contains(MaterialState.pressed)) {
                  return Theme.of(context).splashColor;
                } else {
                  return Theme.of(context).buttonColor;
                }
              }),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  fullscreenDialog: true, // it does not madatory
                  builder: (ctx) => MapScreen(
                    initLocation: _place.location.latitude == null ||
                            _place.location.longitude == null
                        ? PlaceLocation(
                            //default location
                            latitude: 37.422,
                            longitude: -122.084,
                          )
                        : PlaceLocation(
                            //place location
                            latitude: _place.location.latitude,
                            longitude: _place.location.longitude,
                          ),
                    isSelecting: false,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _changePlaceFavorit(context, id) async {
    print('$MAIN_TAG.onPressed -> _changePlaceFavorit(id)  id: $id');
    // await context.read<UserPlaces>().updateFavorite(id);
    await Provider.of<UserPlaces>(context, listen: false).updateFavorite(id);
  }
}

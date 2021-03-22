import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';

import '../models/place.dart';
import '../helpers/db_helper.dart';

enum SequencePlacesList {
  NONE,
  LATER_AHEAD,
  EARLIER_AHEAD,
  SHUFFLE,
}

enum FilterPlacesListBy {
  NONE,
  FAVORITE,
  TITLE,
  LOCATION,
}

class UserPlaces with ChangeNotifier {
  static const String MAIN_TAG = '## UserPlaces';
  List<Place> _items = [];
  String namePlacesDbTable = 'user_places';

  List<Place> get items {
    return [..._items];
  }

  Place findById(String id) {
    return items.firstWhere((element) => element.id == id);
  }

  void addPlace({
    String pickedTitle,
    File pickedImage,
    PlaceLocation pickedLocation,
  }) {
    final newPlace = Place(
      id: DateTime.now().toIso8601String(),
      title: pickedTitle,
      image: pickedImage,
      location: pickedLocation,
      isFavorite: false,
    );
    _items.insert(0, newPlace);
    notifyListeners();
    DBHelper.insert(
      namePlacesDbTable,
      {
        'id': newPlace.id,
        'title': newPlace.title,
        'image': newPlace.image.path,
        'latitude': pickedLocation.latitude,
        'longitude': pickedLocation.longitude,
        'address': pickedLocation.address,
        'is_favorite': newPlace.isFavorite.toString(),
      },
      //'CREATE TABLE $table(id TEXT PRIMARY KEY, title TEXT, image TEXT, latitude REAL, longitude REAL, address TEXT, is_favorite TEXT)');
    );
  }

  Future<void> updateFavorite(String id) async {
    log('$MAIN_TAG.changeFavorite(id) ENTRANCE');
    int index = items.indexWhere((item) => item.id == id);
    Place place = items[index];
    place.isFavorite = !place.isFavorite;
    items[index] = place;
    notifyListeners();
    Map<String, Object> data = {
      'is_favorite': place.isFavorite.toString(),
    };
    int count =
        await DBHelper.update(namePlacesDbTable, data, whereIs: "id = \"$id\"");
    print('$MAIN_TAG.changeFavorite(id); count: $count');
  }

  /// method provides loading places record from database [DBHelper],
  /// filtering [filterBy] and ordering [listOrder] list of places
  Future<void> fetchAndSetPlaces({
    SequencePlacesList listSequence = SequencePlacesList.NONE,
    FilterPlacesListBy filterBy = FilterPlacesListBy.NONE,
    Object value, // it might be wheater String or PlaceLocation
  }) async {
    log('$MAIN_TAG.fetchAndSetPlaces() ENTRANCE filterBy: $filterBy');
    try {
      final fetchedData = await DBHelper.getData(
        namePlacesDbTable,
        orderBy: "id",
        where: _setFilterForDBRequest(filterBy),
      );
      _setPlaces(fetchedData, listSequence);
    } catch (error) {
      throw error;
    }
  }

  void _setPlaces(
      List<Map<String, dynamic>> fetchedData, SequencePlacesList listSequence) {
    _items = [];
    if (fetchedData != null) {
      fetchedData.forEach((dbPlaceRecord) {
        _items.add(
          Place(
              id: dbPlaceRecord['id'],
              image: File(dbPlaceRecord['image']),
              title: dbPlaceRecord['title'],
              location: PlaceLocation(
                latitude: dbPlaceRecord['latitude'],
                longitude: dbPlaceRecord['longitude'],
                address: dbPlaceRecord['address'],
              ),
              isFavorite: _stringToBool(dbPlaceRecord['is_favorite'])),
        );
      });
      _sortPlaceList(listSequence);
      notifyListeners();
    } else
      throw 'No data loaded from the database';
  }

  void _sortPlaceList(SequencePlacesList listSequence) {
    if (listSequence == SequencePlacesList.EARLIER_AHEAD) {
      _items = _items.reversed.toList();
    }
    if (listSequence == SequencePlacesList.SHUFFLE) {
      _items.shuffle(math.Random());
    }
  }

  bool _stringToBool(String boolValueAsString) {
    if (boolValueAsString.trim().toLowerCase() == 'true') {
      return true;
    }
    return false;
  }

  String _setFilterForDBRequest(
    FilterPlacesListBy filter,
  ) {
    switch (filter) {
      case FilterPlacesListBy.NONE:
        {
          return null;
        }
      case FilterPlacesListBy.FAVORITE:
        {
          return "is_favorite = \"true\"";
        }
      default:
        {
          return null;
        }
    }
  }
}

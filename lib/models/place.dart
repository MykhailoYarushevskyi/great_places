import 'dart:io';

import 'package:flutter/cupertino.dart';

class PlaceLocation {
  final double latitude;
  final double longitude;
  final String address;

  const PlaceLocation({
    @required this.latitude,
    @required this.longitude,
    this.address = '',
  });
}

class Place {
  final String id;
  final String title;
  final File image;
  final PlaceLocation location;
  bool isFavorite;

  Place({
    @required this.id,
    @required this.title,
    @required this.image,
    @required this.location,
    this.isFavorite = false,
  });

  @override
  String toString() {
    return 'Place instance; id: $id, title: $title';
    // return super.toString();
  }
}

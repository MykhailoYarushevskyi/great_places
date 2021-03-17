import 'dart:convert' as convert;
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/services.dart';

class LocationHelper {
  static const String MAIN_TAG = '## LocationHelper';

  /// From the file in the assets folder obtain
  /// a [Google Map API Key] for access to the Maps API
  static Future<String> get getMapApiKey async {
    log('$MAIN_TAG.getMapApiKey Entrance');

    return await rootBundle
        .loadString('assets/text-files/google_map_api_key.txt');
  }

  ///This method uses [latitude] and [longitude] as the center
  ///of our place and returns a URL where contain a map of our place
  static Future<String> generateLocationPreviewImage({
    @required double latitude,
    @required double longitude,
    String label = 'A',
  }) async {
    log('$MAIN_TAG.generateLocationPreviewImage Entrance');
    try {
      final _googleMapApiKey = await getMapApiKey;
      return 'https://maps.googleapis.com/maps/api/staticmap?center=&$latitude,$longitude&zoom=16&size=600x300&maptype=roadmap&markers=color:red%7Clabel:$label%7C$latitude,$longitude&key=$_googleMapApiKey';
    } catch (error) {
      throw error;
    }
  }

  static Future<String> getPlaceAddress({
    @required double latitude,
    @required double longitude,
  }) async {
    log('$MAIN_TAG.getPlaceAddress Entrance');
    try {
      final _googleMapApiKey = await getMapApiKey;
      String url =
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&language=uk&key=$_googleMapApiKey';
      // 'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$_googleMapApiKey';
      final response = await http.get(url);
      if (response == null) {
        return '';
      }
      Map<String, dynamic> responseMap =
          convert.jsonDecode(response.body) as Map<String, dynamic>;
      if (!responseMap.containsKey("status")) {
        throw "Lacking Response's Status";
      }
      print(
          '$MAIN_TAG.getPlaceAddress($latitude, $longitude); responseMap["status"]: ${responseMap["status"]}');
      if (responseMap['status'] == "ZERO_RESULTS") {
        return '';
      }
      if (responseMap['status'] == "OK") {
        print(
            '$MAIN_TAG.getPlaceAddress($latitude, $longitude); responseMap["results"]: ${responseMap["results"][0]["formatted_address"]}');
        return responseMap["results"][0]["formatted_address"].toString();
      }
      throw responseMap['status'];
    } catch (error) {
      throw error;
    }
  }
}
// RESOURSES:
//https://developers.google.com/maps/documentation/geocoding/overview#ReverseGeocoding
/*
  The "status" field within the Geocoding response object contains the status of the request, and may contain debugging information to help you track down why reverse geocoding is not working. The "status" field may contain the following values:

    "OK" indicates that no errors occurred and at least one address was returned.
    "ZERO_RESULTS" indicates that the reverse geocoding was successful but returned no results. This may occur if the geocoder was passed a latlng in a remote location.
    "OVER_QUERY_LIMIT" indicates that you are over your quota.
    "REQUEST_DENIED" indicates that the request was denied. Possibly because the request includes a result_type or location_type parameter but does not include an API key or client ID.
    "INVALID_REQUEST" generally indicates one of the following:
        The query (address, components or latlng) is missing.
        An invalid result_type or location_type was given.
    "UNKNOWN_ERROR" indicates that the request could not be processed due to a server error. The request may succeed if you try again.

  */

//   Example of reverse geocoding
// The following query contains the latitude/longitude value for a location in Brooklyn:
// https://maps.googleapis.com/maps/api/geocode/json?latlng=40.714224,-73.961452&key=YOUR_API_KEY
// Note: Ensure that no space exists between the latitude and longitude values when passed in the latlng parameter.
// The above query returns the following result:

/* The above query returns the following result:
  {
   "results" : [
      {
         "address_components" : [
            {
               "long_name" : "277",
               "short_name" : "277",
               "types" : [ "street_number" ]
            },
            {
               "long_name" : "Bedford Avenue",
               "short_name" : "Bedford Ave",
               "types" : [ "route" ]
            },
            {
               "long_name" : "Williamsburg",
               "short_name" : "Williamsburg",
               "types" : [ "neighborhood", "political" ]
            },
            {
               "long_name" : "Brooklyn",
               "short_name" : "Brooklyn",
               "types" : [ "sublocality", "political" ]
            },
            {
               "long_name" : "Kings",
               "short_name" : "Kings",
               "types" : [ "administrative_area_level_2", "political" ]
            },
            {
               "long_name" : "New York",
               "short_name" : "NY",
               "types" : [ "administrative_area_level_1", "political" ]
            },
            {
               "long_name" : "United States",
               "short_name" : "US",
               "types" : [ "country", "political" ]
            },
            {
               "long_name" : "11211",
               "short_name" : "11211",
               "types" : [ "postal_code" ]
            }
         ],
         "formatted_address" : "277 Bedford Avenue, Brooklyn, NY 11211, USA",
         "geometry" : {
            "location" : {
               "lat" : 40.714232,
               "lng" : -73.9612889
            },
            "location_type" : "ROOFTOP",
            "viewport" : {
               "northeast" : {
                  "lat" : 40.7155809802915,
                  "lng" : -73.9599399197085
               },
               "southwest" : {
                  "lat" : 40.7128830197085,
                  "lng" : -73.96263788029151
               }
            }
         },
         "place_id" : "ChIJd8BlQ2BZwokRAFUEcm_qrcA",
         "types" : [ "street_address" ]
      }, 
        ... Additional results[] ...
 */

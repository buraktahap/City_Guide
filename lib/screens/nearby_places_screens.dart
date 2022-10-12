import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../homepage.dart';
import '../response/nearby_places_response.dart';

class NearByPlacesScreen extends StatefulWidget {
  const NearByPlacesScreen({Key? key}) : super(key: key);

  @override
  State<NearByPlacesScreen> createState() => _NearByPlacesScreenState();
}

class _NearByPlacesScreenState extends State<NearByPlacesScreen> {
  String apiKey = "AIzaSyAOySBRKwifABRcXPQFETKnDLfhUKqqbOg";
  String radius = "1500";

  double latitude = 31.5111093;
  double longitude = 74.279664;

  NearbyPlacesResponse nearbyPlacesResponse = NearbyPlacesResponse();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Places'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ElevatedButton(
                onPressed: () {
                  getUserCurrentLocation().then((value) {
                    latitude = value.latitude;
                    longitude = value.longitude;
                  });
                },
                child: const Text("Get My Location")),
            ElevatedButton(
                onPressed: () {
                  getNearbyPlaces();
                },
                child: const Text("Get Nearby Places")),
            if (nearbyPlacesResponse.results != null)
              for (int i = 0; i < nearbyPlacesResponse.results!.length; i++)
                nearbyPlacesWidget(nearbyPlacesResponse.results![i])
          ],
        ),
      ),
    );
  }

  Future<Position> getUserCurrentLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) async {
      await Geolocator.requestPermission();
      print("ERROR$error");
    });
    return await Geolocator.getCurrentPosition();
  }

  void getNearbyPlaces() async {
    var url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?type=museum|art_gallery|mosque|cemetery|church|&location=$latitude,$longitude&radius=$radius&key=$apiKey');

    var response = await http.post(url);

    nearbyPlacesResponse =
        NearbyPlacesResponse.fromJson(jsonDecode(response.body));

    setState(() {});
  }

  nearbyPlacesWidget(Results results) {
    for (int i = 0; i < nearbyPlacesResponse.results!.length; i++) {
      markers.add(Marker(
        markerId: MarkerId(i.toString()),
        position: LatLng(
            results.geometry!.location!.lat!, results.geometry!.location!.lng!),
        infoWindow: InfoWindow(
          title: "Name: ${results.name!}",
        ),
      ));
    }
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          Text("Name: ${results.name!}"),
          Text(
              "Location: ${results.geometry!.location!.lat} , ${results.geometry!.location!.lng}"),
          Text(results.openingHours != null ? "Open" : "Closed"),
        ],
      ),
    );
  }
}

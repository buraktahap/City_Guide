
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../response/nearby_places_response.dart';
  String apiKey = "AIzaSyAOySBRKwifABRcXPQFETKnDLfhUKqqbOg";
  String radius = "1500";

  double latitude = 31.5111093;
  double longitude = 74.279664;

  NearbyPlacesResponse nearbyPlacesResponse = NearbyPlacesResponse();
class NearByPlacesScreen extends StatefulWidget {
  const NearByPlacesScreen({Key? key}) : super(key: key);

  @override
  State<NearByPlacesScreen> createState() => _NearByPlacesScreenState();
}

class _NearByPlacesScreenState extends State<NearByPlacesScreen> {


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
                onPressed: () async{
                  await nearbyPlacesWidget();
                },
                child: const Text("Get Nearby Places")),
          ],
        ),
      ),
    );
  }

  
}
Future<Position> getUserCurrentLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) async {
      await Geolocator.requestPermission();
      print("ERROR$error");
    });
    longitude = await Geolocator.getCurrentPosition().then((value) => value.longitude);
    latitude = await Geolocator.getCurrentPosition().then((value) => value.latitude);
    return await Geolocator.getCurrentPosition();
  }



  nearbyPlacesWidget() async {
    
  }
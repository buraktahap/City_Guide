
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../response/nearby_places_response.dart';
  String apiKey = "AIzaSyAOySBRKwifABRcXPQFETKnDLfhUKqqbOg";
  double radius = 1500;

  double latitude = 38.45817;

  double longitude = 27.2116;


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




  nearbyPlacesWidget() async {
    
  }
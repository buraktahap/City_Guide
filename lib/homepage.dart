import 'dart:async';
import 'dart:convert';
import 'package:city_guide/response/nearby_places_response.dart';
import 'package:city_guide/screens/nearby_places_screens.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import 'custom_widgets/place_info_window.dart';

List<Marker> markers = <Marker>[];

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Completer<GoogleMapController> _controller = Completer();
// on below line we have specified camera position
  static const CameraPosition _kGoogle = CameraPosition(
    target: LatLng(20.42796133580664, 80.885749655962),
    zoom: 14.4746,
  );

// on below line we have created the list of markers

// created method for getting user current location
  Future<Position> getUserCurrentLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) async {
      await Geolocator.requestPermission();
    });
    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    int initialIndex = 0;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F9D58),
        // on below line we have given title of app
        title: const Text("Map Sample"),
      ),
      body: SafeArea(
        // on below line creating google maps
        child: GoogleMap(
          // on below line setting camera position
          initialCameraPosition: _kGoogle,
          // on below line we are setting markers on the map
          markers: Set<Marker>.of(markers),
          // on below line specifying map type.
          mapType: MapType.normal,
          // on below line setting user location enabled.
          myLocationEnabled: true,
          // on below line setting compass enabled.
          compassEnabled: true,
          // on below line specifying controller on map complete.
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
        ),
      ),
      // on pressing floating action button the camera will take to user current location
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          getUserCurrentLocation().then((value) async {
            //print("${value.latitude} ${value.longitude}");

            // marker added for current users location
            // markers.add(Marker(
            //   markerId: const MarkerId("2"),
            //   position: LatLng(value.latitude, value.longitude),
            //   infoWindow: const InfoWindow(
            //     title: 'My Current Location',
            //   ),
            // ));

            // specified current users location
            CameraPosition cameraPosition = CameraPosition(
              target: LatLng(value.latitude, value.longitude),
              zoom: 14,
            );

            await getNearbyPlaces();
            // setState(() {
            // });
            final GoogleMapController controller = await _controller.future;
            controller
                .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
            setState(() {});
          });
        },
        child: const Icon(Icons.local_activity),
      ),

      bottomNavigationBar: //bottom navigation bar
          BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Business',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'School',
          ),
        ],
        currentIndex: initialIndex,
        selectedItemColor: Colors.amber[800],
        onTap: (value) {
          setState(() {
            initialIndex = value;
          });
        },
      ),
    );
  }
     getNearbyPlaces() async {
    await getUserCurrentLocation();
    var url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?type=museum|art_gallery|mosque|cemetery|church|&location=$latitude,$longitude&radius=$radius&key=$apiKey');
    var response = await http.post(url);

    nearbyPlacesResponse = 
        NearbyPlacesResponse.fromJson(jsonDecode(response.body));
    markers.clear();
    for (var i in nearbyPlacesResponse.results!) {
      markers.add(Marker(
        markerId: MarkerId(i.placeId.toString()),
        position: LatLng(
            i.geometry!.location!.lat!, i.geometry!.location!.lng!),
        infoWindow: InfoWindow(
          title: i.name!,
          snippet: i.vicinity!,
          onTap: () => dialogWindowForPlaceInfo(context, i.name!, i.vicinity!, "OK"),
        ),
      ));
      
    }
  }
}

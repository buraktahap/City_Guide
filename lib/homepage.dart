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
// on below line we have specified camera position
  static final CameraPosition _kGoogle = CameraPosition(
    target: LatLng(latitude, longitude),
    zoom: 13,
  );

  final Completer<GoogleMapController> _controller = Completer();

// on below line we have created the list of markers

// created method for getting user current location
  Future<Position> getUserCurrentLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) async {
      await Geolocator.requestPermission();
      print("ERROR$error");
    });
    longitude =
        await Geolocator.getCurrentPosition().then((value) => value.longitude);
    latitude =
        await Geolocator.getCurrentPosition().then((value) => value.latitude);
    return await Geolocator.getCurrentPosition();
  }

  getNearbyPlaces() async {
    var url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?type=museum|art_gallery|mosque|cemetery|church|&location=$latitude,$longitude&radius=${radius.toString()}&key=$apiKey');
    var response = await http.post(url);

    nearbyPlacesResponse =
        NearbyPlacesResponse.fromJson(jsonDecode(response.body));
    markers.clear();
    for (var i in nearbyPlacesResponse.results!) {
      if (i.businessStatus != "OPERATIONAL") {
        continue;
      } else {
        markers.add(Marker(
          markerId: MarkerId(i.placeId.toString()),
          position:
              LatLng(i.geometry!.location!.lat!, i.geometry!.location!.lng!),
          infoWindow: InfoWindow(
            title: i.name!,
            snippet: i.vicinity!,
            onTap: () => dialogWindowForPlaceInfo(
              context,
              i,
              // i.name!,
              // i.photos == null ? "" : i.photos!.single.photoReference,
              // "OK",
              // i.rating == null ? 0 : i.rating!.toDouble(),
            ),
          ),
        ));
      }
    }
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
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              child: Text("Nearby Places"),
            ),
            ListTile(
              title: const Text("Museum"),
              onTap: () {
                setState(() {
                  initialIndex = 0;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("Art Gallery"),
              onTap: () {
                setState(() {
                  initialIndex = 1;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("Mosque"),
              onTap: () {
                setState(() {
                  initialIndex = 2;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("Cemetery"),
              onTap: () {
                setState(() {
                  initialIndex = 3;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("Church"),
              onTap: () {
                setState(() {
                  initialIndex = 4;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        // on below line creating google maps
        child: Column(children: [
          Slider(
              max: 5000.0,
              min: 750.0,
              value: radius,
              divisions: 10,
              onChanged: (newVal) {
                setState(() {
                  radius = newVal;
                });
              }),
          Expanded(
            child: SizedBox(
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
                // on below line we are setting on tap listener on map.
              ),
            ),
          ),
        ]),
      ),
      // on pressing floating action button the camera will take to user current location
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          getUserCurrentLocation().then((value) async {
            debugPrint("${value.latitude} ${value.longitude}");

            // specified current users location
            CameraPosition cameraPosition = CameraPosition(
              target: LatLng(value.latitude, value.longitude),
              zoom: 15 - radius / 2000,
            );
            await getUserCurrentLocation();

            await getNearbyPlaces();
            // setState(() {
            // });
            final GoogleMapController controller = await _controller.future;
            controller
                .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
            setState(() {});
          });
        },
        child: const Icon(Icons.where_to_vote_rounded),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 4.0,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}

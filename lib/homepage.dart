import 'dart:async';
import 'dart:convert';
import 'package:city_guide/custom_widgets/error_window.dart';
import 'package:city_guide/response/nearby_places_response.dart';
import 'package:city_guide/screens/nearby_places_screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import 'custom_widgets/place_info_window.dart';

List<Marker> markers = <Marker>[];

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        //custom drawer
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.red,
              ),
              child: Column(
                children: const [
                  Icon(
                    Icons.location_city,
                    size: 100,
                    color: Colors.white,
                  ),
                  Text(
                    "City Guide",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            //weather of the city
            ListTile(
              leading: const Icon(Icons.wb_sunny),
              title: const Text("How is the weather?"),
              onTap: () {
                Navigator.pop(context);
                showErrorWindow(context);
              },
            ),
            //news
            ListTile(
              leading: const Icon(Icons.newspaper),
              title: const Text("News"),
              onTap: () {
                Navigator.pop(context);
                showErrorWindow(context);
              },
            ),
            //events
            ListTile(
              leading: const Icon(Icons.event),
              title: const Text("Events"),
              onTap: () {
                Navigator.pop(context);
                showErrorWindow(context);
              },
            ),
            //tips
            ListTile(
              leading: const Icon(Icons.lightbulb),
              title: const Text("Tips"),
              onTap: () {
                Navigator.pop(context);
                showErrorWindow(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.credit_card),
              title: const Text("Buy Card"),
              onTap: () {
                Navigator.pop(context);
                showErrorWindow(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              onTap: () {
                Navigator.pop(context);
                showErrorWindow(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text("Help"),
              onTap: () {
                Navigator.pop(context);
                showErrorWindow(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text("Exit"),
              onTap: () {
                Navigator.pop(context);
                showErrorWindow(context);
              },
            ),
            //about
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text("About"),
              onTap: () {
                Navigator.pop(context);
                showErrorWindow(context);
              },
            ),

            //version
            const ListTile(
              title: Text("Version 0.1.0"),
            ),
          ],
        ),
      ),
      body: SafeArea(
        // on below line creating google maps
        child: Stack(children: [
          SizedBox(
            child: GoogleMap(
              myLocationButtonEnabled: false,
              myLocationEnabled: true,
              // on below line setting camera position
              initialCameraPosition: _kGoogle,
              // on below line we are setting markers on the map
              markers: Set<Marker>.of(markers),
              // on below line specifying map type.
              mapType: MapType.normal,
              // on below line setting user location enabled.
              // on below line setting compass enabled.
              compassEnabled: true,
              // on below line specifying controller on map complete.
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              // on below line we are setting on tap listener on map.
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.fromLTRB(15, 10, 15, 0),
              width: MediaQuery.of(context).size.width,
              height: 50,
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //zoom out
                  IconButton(
                    onPressed: () {
                      if (radius > 750) {
                        setState(() {
                          radius -= 425;
                        });
                      }
                    },
                    icon: const Icon(Icons.zoom_out),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: Slider(
                        max: 5000.0,
                        min: 750.0,
                        value: radius,
                        divisions: 10,
                        onChanged: (newVal) {
                          setState(() {
                            radius = newVal;
                          });
                        }),
                  ),
                  //zoom in
                  IconButton(
                    onPressed: () {
                      if (radius < 5000) {
                        setState(() {
                          radius += 425;
                        });
                      }
                    },
                    icon: const Icon(Icons.zoom_in),
                  ),
                ],
              ),
            ),
          ),
          nearbyPlacesResponse.results != null ? placeCards() : Container(),
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
              zoom: 15 + (radius - 5000) / 2000,
            );
            await getUserCurrentLocation();

            await getNearbyPlaces();
            await placeCards();
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
            Builder(
              builder: (BuildContext context) {
                return IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () {
                      return Scaffold.of(context).openDrawer();
                    });
              },
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

  Future<Position> getUserCurrentLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) async {
      await Geolocator.requestPermission();
      debugPrint("ERROR$error");
    });
    longitude =
        await Geolocator.getCurrentPosition().then((value) => value.longitude);
    latitude =
        await Geolocator.getCurrentPosition().then((value) => value.latitude);
    return await Geolocator.getCurrentPosition();
  }

  getNearbyPlaces() async {
    var url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?type=museum|art_gallery|hindu_temple|mosque|synagogue|tourist_attraction|cemetery|church|&location=$latitude,$longitude&radius=${(5750 - radius).toString()}&key=$apiKey');
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

  placeCards() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.25,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: nearbyPlacesResponse.results?.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                dialogWindowForPlaceInfo(
                  context,
                  nearbyPlacesResponse.results![index],
                );
              },
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: Card(
                    margin: const EdgeInsets.all(8.0),
                    elevation: 10,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.1,
                            child: nearbyPlacesResponse
                                        .results?[index].photos ==
                                    null
                                ? const Icon(Icons.image_not_supported_rounded)
                                : Image.network(
                                    "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=${nearbyPlacesResponse.results![index].photos!.single.photoReference}&key=$apiKey",
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          Text(
                            nearbyPlacesResponse.results?[index].name! ?? "",
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                overflow: TextOverflow.ellipsis),
                          ),
                          Text(
                            nearbyPlacesResponse.results?[index].vicinity ?? "",
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                overflow: TextOverflow.ellipsis),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              //rating bar
                              RatingBar.builder(
                                initialRating: nearbyPlacesResponse
                                            .results?[index].rating ==
                                        null
                                    ? 0
                                    : nearbyPlacesResponse
                                        .results?[index].rating
                                        .toDouble(),
                                minRating: 1,
                                direction: Axis.horizontal,
                                allowHalfRating: true,
                                itemCount: 5,
                                itemSize: 20,
                                itemBuilder: (context, _) => const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                                onRatingUpdate: (rating) {},
                              ),
                              Text(
                                nearbyPlacesResponse.results?[index].rating ==
                                        null
                                    ? "0"
                                    : nearbyPlacesResponse
                                        .results![index].rating!
                                        .toString(),
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )),
              ),
            );
          },
        ),
      ),
    );
  }
}

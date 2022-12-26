import 'dart:async';
import 'package:city_guide/custom_widgets/error_window.dart';
import 'package:city_guide/l10n/app_l10n.dart';
import 'package:city_guide/main.dart';
import 'dart:convert';
import 'package:city_guide/response/nearby_places_response.dart';
import 'package:city_guide/screens/transportation_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../custom_widgets/place_info_window.dart';

final lightTheme = ThemeData.light().copyWith();

final darkTheme = ThemeData.dark().copyWith(
    // Define the default brightness and colors for the dark theme here
    );
List<Marker> markers = <Marker>[];
//Circle
Set<Circle> _circles = <Circle>{};
double latitude = 38.45817;
const apiKey = "AIzaSyCbZ7uHZmGNtqwUa7ZGESdvRAxiUbcAVJg";

List nearbyPlaces = [];

double longitude = 27.2116;
double radius = 1500;
NearbyPlacesResponse nearbyPlacesResponse =
    NearbyPlacesResponse(results: [], status: '');

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    radius = 1000;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getUserCurrentLocation();
    });
  }

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
      drawer: drawer(context),
      body: SafeArea(
        // on below line creating google maps
        child: Stack(children: [
          SizedBox(
            child: GoogleMap(
                circles: _circles,
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
                }
                // on below line we are setting on tap listener on map.
                ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.fromLTRB(15, 10, 15, 0),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.075,
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //zoom out
                  GestureDetector(
                    onTap: () {
                      if (radius < 4575) {
                        setState(() {
                          radius -= 425;
                        });
                      }
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.zoom_in),
                        Text("750m", style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: Slider(
                        max: 5000.0,
                        min: 750.0,
                        value: radius,
                        divisions: 10,
                        onChangeEnd: (newVal) {
                          _circles.clear();
                          setState(() {
                            radius = newVal;
                          });
                          _setCircle(LatLng(latitude, longitude));
                        },
                        onChanged: (newVal) {
                          setState(() {
                            radius = newVal;
                          });
                        }),
                  ),
                  //zoom in

                  GestureDetector(
                    onTap: () {
                      if (radius > 1175) {
                        setState(() {
                          radius += 425;
                        });
                      }
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.zoom_out,
                        ),
                        Text("5000m", style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          (nearbyPlacesResponse.results != null &&
                  nearbyPlacesResponse.results!.isNotEmpty)
              ? placeCards()
              : Container(),
        ]),
      ),
      // on pressing floating action button the camera will take to user current location
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          getUserCurrentLocation().then((value) async {
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
        notchMargin: 6,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Builder(
              builder: (BuildContext context) {
                return IconButton(
                    constraints:
                        const BoxConstraints.tightFor(width: 72, height: 55),
                    padding: EdgeInsets.zero,
                    icon: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.menu,
                        ),
                        Text(AppLocalizations.of(context)!.menu)
                      ],
                    ),
                    onPressed: Scaffold.of(context).openDrawer,
                    tooltip: AppLocalizations.of(context)!.menu);
              },
            ),
            IconButton(
              constraints: const BoxConstraints.tightFor(width: 72, height: 55),
              padding: EdgeInsets.zero,
              icon: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.search,
                  ),
                  Text(AppLocalizations.of(context)!.search)
                ],
              ),
              onPressed: () {
                showErrorWindow(context);
              },
              tooltip: AppLocalizations.of(context)!.search,
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
    await getUserCurrentLocation();

    int requestCount = 0;
    nearbyPlaces.clear();
    markers.clear();

    var url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?request_count=${requestCount.toString()}&type=museum|art_gallery|hindu_temple|mosque|synagogue|tourist_attraction|cemetery|church|&location=$latitude,$longitude&radius=${radius.toString()}&key=$apiKey');

    var response = await http.post(url);
    requestCount++;

    nearbyPlacesResponse =
        NearbyPlacesResponse.fromJson(jsonDecode(response.body));

    nearbyPlacesResponse.results?.forEach((element) {
      nearbyPlaces.add(element);
    });

    while (nearbyPlacesResponse.nextPageToken != null) {
      await Future.delayed(const Duration(seconds: 2), () {});

      final url = Uri.parse(
          'https://maps.googleapis.com/maps/api/place/nearbysearch/json?pagetoken=${nearbyPlacesResponse.nextPageToken.toString()}&key=$apiKey');

      var response = await http.post(url);

      nearbyPlacesResponse =
          NearbyPlacesResponse.fromJson(jsonDecode(response.body));

      nearbyPlacesResponse.results?.forEach((element) {
        nearbyPlaces.add(element);
      });
    }

    requestCount = 0;

    debugPrint(nearbyPlaces.length.toString());

    for (var i in nearbyPlaces
        .where((element) => (element.rating ?? 0.0) >= 3.0)
        .toList()) {
      markers.add(Marker(
        markerId: MarkerId(i.placeId.toString()),
        position:
            LatLng(i.geometry!.location!.lat!, i.geometry!.location!.lng!),
        infoWindow: InfoWindow(
          title: i.name!,
          // ignore: use_build_context_synchronously
          snippet: i.vicinity ?? AppLocalizations.of(context)!.no_info,
          onTap: () => dialogWindowForPlaceInfo(
            context,
            i,
          ),
        ),
      ));
    }
  }

  placeCards() {
    final cardList = nearbyPlaces
        .where((element) => (element.rating ?? 0.0) >= 3.0)
        .toList();
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
          ),
          height: MediaQuery.of(context).size.height * 0.15,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: cardList.length,
            itemBuilder: (context, index) {
              final card = cardList[index];
              return GestureDetector(
                onTap: () {
                  dialogWindowForPlaceInfo(
                    context,
                    card,
                  );
                },
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Card(
                      elevation: 10,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.15,
                              width: MediaQuery.of(context).size.height * 0.15,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: card.photos == null
                                  ? Container(
                                      color: Colors.grey,
                                      child: const Icon(
                                          Icons.image_not_supported_rounded),
                                    )
                                  : Image.network(
                                      "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=${card.photos!.single.photoReference}&key=$apiKey",
                                      fit: BoxFit.fill,
                                    ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.5,
                                height:
                                    MediaQuery.of(context).size.height * 0.07,
                                child: Text(
                                  card.name ?? "",
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    overflow: TextOverflow.clip,
                                  ),
                                ),
                              ),
                              // SizedBox(
                              //   width: MediaQuery.of(context).size.width * 0.5,
                              //   child: Text(
                              //     nearbyPlacesResponse
                              //             .results?[index].vicinity ??
                              //         "",
                              //     style: const TextStyle(
                              //         fontSize: 15,
                              //         fontWeight: FontWeight.bold,
                              //         overflow: TextOverflow.clip),
                              //   ),
                              // ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  //rating bar
                                  RatingBarIndicator(
                                    rating: card.rating == null
                                        ? 0
                                        : card.rating!.toDouble(),
                                    itemCount: 5,
                                    itemSize: 20.0,
                                    direction: Axis.horizontal,
                                    itemBuilder: (context, _) => const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),
                                  ),
                                  Text(
                                    card.rating == null
                                        ? "0"
                                        : card.rating.toString(),
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      )),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  _setCircle(LatLng point) async {
    final GoogleMapController controller = await _controller.future;

    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: point, zoom: 12)));
    setState(() {
      _circles.add(Circle(
          circleId: const CircleId('circle'),
          center: point,
          fillColor: Colors.blue.withOpacity(0.1),
          radius: radius,
          strokeColor: Colors.blue,
          strokeWidth: 1));
    });
  }

  Drawer drawer(BuildContext context) {
    bool value = false;
    return Drawer(
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
            title: Text(AppLocalizations.of(context)!.weather_title),
            onTap: () {
              Navigator.pop(context);
              showErrorWindow(context);
            },
          ),
          //news
          ListTile(
            leading: const Icon(Icons.newspaper),
            title: Text(AppLocalizations.of(context)!.news),
            onTap: () {
              Navigator.pop(context);
              showErrorWindow(context);
            },
          ),
          //events
          ListTile(
            leading: const Icon(Icons.event),
            title: Text(AppLocalizations.of(context)!.events),
            onTap: () {
              Navigator.pop(context);
              showErrorWindow(context);
            },
          ),
          //tips
          ListTile(
            leading: const Icon(Icons.lightbulb),
            title: Text(AppLocalizations.of(context)!.tips),
            onTap: () {
              Navigator.pop(context);
              showErrorWindow(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.credit_card),
            title: Text(
                AppLocalizations.of(context)!.purchase_transportation_card),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const TransportationCard()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(AppLocalizations.of(context)!.settings),
            onTap: () {
              Navigator.pop(context);
              showErrorWindow(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: Text(AppLocalizations.of(context)!.help),
            onTap: () {
              Navigator.pop(context);
              showErrorWindow(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: Text(AppLocalizations.of(context)!.logout),
            onTap: () {
              SystemNavigator.pop();
            },
          ),
          //about
          ListTile(
            leading: const Icon(Icons.info),
            title: Text(AppLocalizations.of(context)!.about),
            onTap: () {
              showAboutDialog(
                  context: context,
                  applicationName: "City Guide",
                  applicationVersion: "0.1.0",
                  applicationIcon: const Icon(Icons.location_city),
                  applicationLegalese: "© 2021 City Guide",
                  children: [
                    const Text(
                        "City Guide is an application that helps you find places in your city. It also provides you with information about the weather, news, events and tips. It is a very useful application for tourists and locals alike."),
                  ]);
            },
          ),
          //language changing switch with applocalizations and l10n
          ListTile(
            title: const Text("Switch Language"),
            trailing: Switch(
              value: value,
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    lookupL10n(const Locale('en', 'US'));
                    value = !value;
                  } else {
                    lookupL10n(const Locale('tr', 'TR'));
                    value = !value;
                  }
                });
              },
              activeTrackColor: const Color(0xff007AFF),
              activeColor: const Color(0xff007AFF),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: Text(AppLocalizations.of(context)!.logout),
            onTap: () {
              setState(() {
                L10n.delegate.load(const Locale('tr', 'TR'));
              });
            },
          ),

          //version
          const ListTile(
            title: Text("Version 0.1.0"),
          ),
        ],
      ),
    );
  }
}

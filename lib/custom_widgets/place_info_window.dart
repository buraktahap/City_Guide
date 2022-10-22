import 'package:city_guide/screens/nearby_places_screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../response/nearby_places_response.dart';

void dialogWindowForPlaceInfo(BuildContext context, Results placeInfo) {
  double imageWidth = MediaQuery.of(context).size.width;
  double imageHeight = imageWidth *
      MediaQuery.of(context).size.width /
      MediaQuery.of(context).size.height;
  var photoRef =
      placeInfo.photos == null ? "" : placeInfo.photos!.single.photoReference;
  var rating =
      placeInfo.rating == null ? 0.toDouble() : placeInfo.rating!.toDouble();
  showDialog(
      context: context,
      builder: (context) {
        return Scaffold(
          appBar: AppBar(
              title: Text(placeInfo.name!),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              )),
          body: Column(
            children: [
              Container(
                  padding: const EdgeInsets.all(10),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    placeInfo.vicinity!,
                    style: const TextStyle(
                        fontSize: 20, fontStyle: FontStyle.italic),
                  )),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    //adress

                    RatingBarIndicator(
                      itemBuilder: (BuildContext context, int index) {
                        return const Icon(
                          Icons.star,
                          color: Color.fromARGB(255, 254, 212, 84),
                        );
                      },
                      rating: rating,
                      itemCount: 5,
                      itemSize: 35.0,
                      direction: Axis.horizontal,
                    ),
                    Text("  $rating / 5  (${placeInfo.userRatingsTotal ?? 0})"),
                  ],
                ),
              ),
              photoRef == ""
                  ? const Icon(
                      Icons.image_not_supported,
                      size: 100,
                    )
                  : Image.network(
                      "https://maps.googleapis.com/maps/api/place/photo?maxwidth=${imageWidth.toInt()}&maxheight=${imageHeight.toInt()}&photoreference=$photoRef&key=$apiKey",
                      fit: BoxFit.contain,
                      // width: MediaQuery.of(context).size.width - 50,
                    ),
              const SizedBox(),
              // more detail
              Expanded(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                  alignment: Alignment.topLeft,
                  child: Text(
                    placeInfo.openingHours == null
                        ? "No Info"
                        : placeInfo.openingHours!.openNow == true
                            ? "Open Now"
                            : "Not Open Now",
                    style: const TextStyle(
                        fontSize: 20, fontStyle: FontStyle.italic),
                  ),
                ),
              ),
            ],
          ),
        );
      });
}

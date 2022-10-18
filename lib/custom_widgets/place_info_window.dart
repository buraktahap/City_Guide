import 'package:city_guide/screens/nearby_places_screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

void dialogWindowForPlaceInfo(BuildContext context, String title,
    String? photoRef, String buttonText, double rating) {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            children: [
              Row(
                children: [
                  RatingBarIndicator(
                    itemBuilder: (BuildContext context, int index) {
                      return const Icon(
                        Icons.star,
                        color: Color.fromARGB(255, 254, 212, 84),
                      );
                    },
                    rating: rating,
                    itemCount: 5,
                    itemSize: 25.0,
                    direction: Axis.horizontal,
                  ),
                  Text(" $rating / 5"),
                ],
              ),
              photoRef == ""
                  ? const Text("No Image Available")
                  : Image.network(
                      "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$photoRef&key=$apiKey")
            ],
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(buttonText))
          ],
        );
      });
}

import 'package:city_guide/screens/nearby_places_screens.dart';
import 'package:flutter/material.dart';

void dialogWindowForPlaceInfo(
    BuildContext context, String title, String photoRef, String buttonText) {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Image.network("https://maps.googleapis.com/maps/api/place/photo?photoreference=$photoRef&sensor=false&maxheight=400&maxwidth=400&key=$apiKey"),
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
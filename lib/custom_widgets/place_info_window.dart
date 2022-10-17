import 'package:flutter/material.dart';

void dialogWindowForPlaceInfo(
    BuildContext context, String title, String message, String buttonText) {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
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
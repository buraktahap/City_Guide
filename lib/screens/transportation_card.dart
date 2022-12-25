import 'package:city_guide/custom_widgets/error_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_fonts/google_fonts.dart';

class TransportationCard extends StatefulWidget {
  const TransportationCard({super.key});

  @override
  State<TransportationCard> createState() => _TransportationCardState();
}

class _TransportationCardState extends State<TransportationCard> {
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Purchase Transportation Card",
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: GoogleFonts.quicksand().fontFamily),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  "lib/assets/kart.jpg",
                  fit: BoxFit.cover,
                ),

                //form for purchasing transportation card
                Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.always,
                    child: Column(
                      children: [
                        customTextField("Name"),
                        customTextField("Email",
                            type: TextInputType.emailAddress),
                        customTextField("Phone Number",
                            type: TextInputType.number),
                        customTextField("Address"),
                        customTextField("Zip Code", type: TextInputType.number),
                        customTextField("Card Number",
                            type: TextInputType.number),
                        customTextField("Expiration Date",
                            type: TextInputType.number),
                        customTextField("CVV", type: TextInputType.number),
                        customTextField("Cardholder Name"),
                      ],
                    )),

                //button for purchasing transportation card

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        showErrorWindow(context);
                      }
                    },
                    child: const Text("Purchase"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  customTextField(String hint, {TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: GoogleFonts.quicksand().fontFamily),
        textInputAction: TextInputAction.next,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "*Neseseri";
          }
          return null;
        },
        decoration: InputDecoration(
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
          ),
          hintText: hint,
        ),
        keyboardType: type,
      ),
    );
  }
}

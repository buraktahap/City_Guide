import 'package:city_guide/custom_widgets/error_window.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
          AppLocalizations.of(context)!.purchase_transportation_card,
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
                        customTextField(AppLocalizations.of(context)!.name),
                        customTextField(AppLocalizations.of(context)!.surname),
                        customTextField(AppLocalizations.of(context)!.email),
                        customTextField(
                            AppLocalizations.of(context)!.phone_number,
                            type: TextInputType.number),
                        customTextField(AppLocalizations.of(context)!.address),
                        customTextField(AppLocalizations.of(context)!.zip_code,
                            type: TextInputType.number),
                        customTextField(
                            AppLocalizations.of(context)!.card_number,
                            type: TextInputType.number),
                        customTextField(
                            AppLocalizations.of(context)!.expiration_date,
                            type: TextInputType.number),
                        customTextField(AppLocalizations.of(context)!.cvv,
                            type: TextInputType.number),
                        customTextField(
                            AppLocalizations.of(context)!.card_holder_name),
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
                    child: Text(AppLocalizations.of(context)!.purchase),
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
        textCapitalization: TextCapitalization.words,
        style: TextStyle(
            fontSize: 16,
            // fontWeight: FontWeight.bold,
            fontFamily: GoogleFonts.quicksand().fontFamily),
        textInputAction: TextInputAction.next,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "*Required";
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

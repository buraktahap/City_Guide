import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wikidart/wikidart.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../config.dart';
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
              centerTitle: true,
              elevation: 0,
              title: Text(placeInfo.name!,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.clip,
                      fontFamily: GoogleFonts.quicksand().fontFamily),
                  textAlign: TextAlign.center),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              )),
          body: Column(
            children: [
              Container(
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    placeInfo.vicinity?.toString() ?? "",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.clip,
                        fontFamily: GoogleFonts.quicksand().fontFamily),
                  )),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
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
              Container(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                alignment: Alignment.topLeft,
                child: Text(
                  placeInfo.openingHours == null
                      ? AppLocalizations.of(context).noData
                      : placeInfo.openingHours!.openNow == true
                          ? "Open Now"
                          : "Not Open Now",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.clip,
                      fontFamily: GoogleFonts.quicksand().fontFamily),
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
              const SizedBox(
                height: 8,
              ),
              // more detail
              const Divider(
                thickness: 2,
                indent: 10,
                endIndent: 10,
              ),
              FutureBuilder(
                  future: wiki(placeInfo.name!),
                  builder: (context, AsyncSnapshot data) {
                    if (data.connectionState == ConnectionState.waiting) {
                      return const Align(
                        alignment: Alignment.bottomCenter,
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (data.data == null) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 100, color: Colors.red),
                          Text(
                            AppLocalizations.of(context).noWikiData,
                            style: TextStyle(
                                fontSize: 18,
                                overflow: TextOverflow.clip,
                                fontFamily: GoogleFonts.quicksand().fontFamily),
                          ),
                        ],
                      );
                    }
                    return Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Container(
                          margin: const EdgeInsets.only(top: 20),
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                blurRadius: 20,
                                spreadRadius: 8,
                              ),
                            ],
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20)),
                            color: Colors.grey.shade100,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 0, 16, 10),
                                alignment: Alignment.topLeft,
                                child: Text(
                                  data.data,
                                  style: TextStyle(
                                      fontSize: 18,
                                      overflow: TextOverflow.clip,
                                      fontFamily:
                                          GoogleFonts.quicksand().fontFamily),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
            ],
          ),
        );
      });
}

Future wiki(String query) async {
  var res = await Wikidart.searchQuery(
    query.contains("izmir") ? query : "izmir $query",
  );
  var pageid = res?.results?.first.pageId;

  if (pageid != null) {
    var google = await Wikidart.summary(pageid);

    if (google != null) {
      // handle errors here
      return google.extract;
    }
  }
  return null;
}

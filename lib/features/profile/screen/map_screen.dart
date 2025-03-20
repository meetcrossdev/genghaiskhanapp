// ///
// /// AVANCED EXAMPLE:
// /// Screen with map and search box on top. When the user selects a place through autocompletion,
// /// the screen is moved to the selected location, a path that demonstrates the route is created, and a "start route"
// /// box slides in to the screen.
// ///

// import 'dart:async';
// import 'dart:developer';

// import 'package:flutter/material.dart';

// import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'dart:io' show Platform;

// import 'package:location/location.dart';
// import 'package:toast/toast.dart';

// class MapLocation extends StatefulWidget {
//   MapLocation({Key? key}) : super(key: key);
//     static const routeName = '/map-screen';
//   // var address;
//   // final Function(String address, String city, String state, String country)?
//   // onPickAddress;
//   // MapLocation({Key? key, this.onPickAddress}) : super(key: key);
//   @override
//   State<MapLocation> createState() => MapLocationState();
// }

// class MapLocationState extends State<MapLocation>
//     with SingleTickerProviderStateMixin {
//   PickResult? selectedPlace;
//   static LatLng kInitialPosition = LatLng(
//     51.52034098371205,
//     -0.12637399200000668,
//   ); // London , arbitary value

//   GoogleMapController? _controller;

//   Future<void> _onMapCreated(GoogleMapController controller) async {
//     _controller = controller;
//     // String value = await DefaultAssetBundle.of(context)
//     //     .loadString('assets/map_style.json');
//     // _controller.setMapStyle(value);
//     setState(() {});
//   }

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();

//     setDummyInitialLocation();
//     // if (widget.address.location_available) {
//     //   setInitialLocation();
//     // }else{
//     //   setDummyInitialLocation();
//     // }
//   }

//   Future<void> setUserCurrentLocation() async {
//     final location = Location();

//     // Check if location services are enabled
//     bool serviceEnabled = await location.serviceEnabled();
//     if (!serviceEnabled) {
//       serviceEnabled = await location.requestService();
//       if (!serviceEnabled) {
//         print('Location services are disabled.');
//         return;
//       }
//     }

//     // Check for location permissions
//     PermissionStatus permissionGranted = await location.hasPermission();
//     if (permissionGranted == PermissionStatus.denied) {
//       permissionGranted = await location.requestPermission();
//       if (permissionGranted != PermissionStatus.granted) {
//         print('Location permissions are denied.');
//         return;
//       }
//     }

//     // Get the user's current location
//     final LocationData currentLocation = await location.getLocation();

//     if (currentLocation.latitude != null && currentLocation.longitude != null) {
//       kInitialPosition = LatLng(
//         currentLocation.latitude!,
//         currentLocation.longitude!,
//       );
//       print(
//         'User location set to: ${kInitialPosition.latitude}, ${kInitialPosition.longitude}',
//       );
//     } else {
//       print('Unable to fetch user location.');
//     }
//   }

//   setInitialLocation() {
//     // kInitialPosition = LatLng(widget.address.lat, widget.address.lang);
//     kInitialPosition = LatLng(51.52034098371205, -0.12637399200000668);
//     setState(() {});
//   }

//   setDummyInitialLocation() {
//     // kInitialPosition = LatLng(51.52034098371205, -0.12637399200000668); // London , arbitary value
//     kInitialPosition = LatLng(29.378586, 47.990341);
//     setState(() {});
//   }

//   onTapPickHere(selectedPlace) async {}

//   @override
//   Widget build(BuildContext context) {
//     return PlacePicker(

//       hintText: 'Your Delivery Location',
//       apiKey: "AIzaSyDYtn83aed8w84MFMGZRGnBAFRFvbvW9MM",
//       initialPosition: kInitialPosition,
//       useCurrentLocation: true,
//       //selectInitialPosition: true,
//       //onMapCreated: _onMapCreated, // this causes error , do not open this
//       //initialMapType: MapType.terrain,
//  usePlaceDetailSearch: false,
//       //usePlaceDetailSearch: true,
//       onPlacePicked: (result) {
//         selectedPlace = result;

//         print("onPlacePicked..." + result.toString());
//         // Navigator.of(context).pop();
//         setState(() {});
//       },
//       //forceSearchOnZoomChanged: true,
//       automaticallyImplyAppBarLeading: false,
//       //autocompleteLanguage: "ko",
//       //region: 'au',
//       //selectInitialPosition: true,
//       selectedPlaceWidgetBuilder: (
//         _,
//         selectedPlace,
//         state,
//         isSearchBarFocused,
//       ) {
//         // print("state: $state, isSearchBarFocused: $isSearchBarFocused");
//         // print(selectedPlace.toString());
//         // print("-------------");
//         /*
//         if(!isSearchBarFocused && state != SearchingState.Searching){
//           ToastComponent.showDialog("Hello", context,
//               gravity: Toast.center, duration: Toast.lengthLong);
//         }*/
//         return isSearchBarFocused
//             ? Container()
//             : FloatingCard(
//               height: 50,
//               bottomPosition: 60.0,
//               // MediaQuery.of(context) will cause rebuild. See MediaQuery document for the information.
//               leftPosition: 0.0,
//               rightPosition: 0.0,
//               width: 500,
//               borderRadius: const BorderRadius.only(
//                 topLeft: const Radius.circular(8.0),
//                 bottomLeft: const Radius.circular(8.0),
//                 topRight: const Radius.circular(8.0),
//                 bottomRight: const Radius.circular(8.0),
//               ),
//               child:
//                   state == SearchingState.Searching
//                       ? Center(child: Text('Calculating'))
//                       : Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Row(
//                           children: [
//                             Expanded(
//                               flex: 2,
//                               child: Container(
//                                 child: Center(
//                                   child: Padding(
//                                     padding: const EdgeInsets.only(
//                                       left: 2.0,
//                                       right: 2.0,
//                                     ),
//                                     child: Text(
//                                       selectedPlace!.formattedAddress!,
//                                       maxLines: 2,
//                                       style: TextStyle(),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             Expanded(
//                               flex: 1,
//                               child: ElevatedButton(
//                                 child: Text(
//                                   'Pick here',
//                                   style: TextStyle(),
//                                 ),
//                                 onPressed: () {
//                                   //   // IMPORTANT: You MUST manage selectedPlace data yourself as using this build will not invoke onPlacePicker as
//                                   //   //            this will override default 'Select here' Button.
//                                   //   /*print("do something with [selectedPlace] data");
//                                   //  */
//                                   // for (var v
//                                   //     in selectedPlace.addressComponents!) {
//                                   //   log(v.longName);
//                                   // }
//                                   // print(selectedPlace.geometry?.location.lat);
//                                   // print(selectedPlace.geometry?.location.lng);

//                                   //   onTapPickHere(selectedPlace);

//                                   List<String> addressParts = [];

//                                   for (var v
//                                       in selectedPlace.addressComponents!) {
//                                     log(v.longName);
//                                     addressParts.add(v.longName);
//                                   }

//                                   int len = addressParts.length;

//                                   String country = "", state = "", city = "";

//                                   if (len >= 3) {
//                                     // Check if the last value is a placeholder (e.g., "00000" or similar)
//                                     if (RegExp(
//                                       r'^\d+$',
//                                     ).hasMatch(addressParts[len - 1])) {
//                                       // If last value is numeric, use the 2nd last, 3rd last, and 4th last values
//                                       country = addressParts[len - 2];
//                                       state = addressParts[len - 3];
//                                       city = addressParts[len - 4];
//                                     } else {
//                                       // Otherwise, use the last, 2nd last, and 3rd last values
//                                       country = addressParts[len - 1];
//                                       state = addressParts[len - 2];
//                                       city = addressParts[len - 3];
//                                     }
//                                   }

//                                   //  Navigator.pop(context); // Close the picker
//                                 },
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//             );
//       },
//       pinBuilder: (context, state) {
//         if (state == PinState.Idle) {
//           return Image.asset('assets/images/delivery_map_icon.png', height: 60);
//         } else {
//           return Image.asset('assets/images/delivery_map_icon.png', height: 80);
//         }
//       },
//     );
//   }
// }

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gzresturent/features/profile/controller/profile_controller.dart';
import 'package:place_picker_google/place_picker_google.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapLocation extends ConsumerStatefulWidget {
  const MapLocation({super.key});
  static const routeName = '/map-screen';
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MapLocationState();
}

class _MapLocationState extends ConsumerState<MapLocation> {
  GoogleMapController? mapController;
  LatLng? _currentLocation;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  /// Get the user's current location
  Future<void> _getUserLocation() async {
    Location location = Location();

    // Check if location service is enabled
    bool _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) return;
    }

    // Check location permission
    PermissionStatus _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) return;
    }

    // Get current location
    LocationData _locationData = await location.getLocation();
    if (_locationData.latitude != null && _locationData.longitude != null) {
      setState(() {
        _currentLocation = LatLng(
          _locationData.latitude!,
          _locationData.longitude!,
        );
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : PlacePicker(
                mapsBaseUrl:
                    kIsWeb
                        ? 'https://cors-anywhere.herokuapp.com/https://maps.googleapis.com/maps/api/'
                        : "https://maps.googleapis.com/maps/api/",
                usePinPointingSearch: true,
                apiKey: "AIzaSyDYtn83aed8w84MFMGZRGnBAFRFvbvW9MM",
                onPlacePicked: (LocationResult result) async {
                  debugPrint("Place picked: ${result.formattedAddress}");
                  FirebaseAuth auth = FirebaseAuth.instance;
                  debugPrint("Place picked: ${result.formattedAddress}");
                  await ref
                      .read(userProfileControllerProvider.notifier)
                      .updateLocation(
                        id: auth.currentUser!.uid,
                        location: result.formattedAddress!,
                        context: context,
                      );

                  Navigator.of(context).pop();
                },
                enableNearbyPlaces: false,
                showSearchInput: true,
                initialLocation:
                    _currentLocation!, // Set user's current location
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                onMapCreated: (controller) {
                  mapController = controller;
                },
                searchInputConfig: const SearchInputConfig(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  autofocus: false,
                  textDirection: TextDirection.ltr,
                ),
                searchInputDecorationConfig: const SearchInputDecorationConfig(
                  hintText: "Search for a building, street or ...",
                ),
                autocompletePlacesSearchRadius: 150,
              ),
      // appBar: AppBar(),
      // body: Center(
      //   child: ElevatedButton(
      //     child: const Text("Pick Delivery Location"),
      //     onPressed: () {
      //       if (_currentLocation != null) {
      //         showPlacePicker(_currentLocation!);
      //       } else {
      //         ScaffoldMessenger.of(context).showSnackBar(
      //           SnackBar(content: Text("Fetching current location... Please wait!")),
      //         );
      //       }
      //     },
      //   ),
      // ),
    );
  }

  void showPlacePicker(LatLng initialLocation) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return PlacePicker(
            mapsBaseUrl:
                kIsWeb
                    ? 'https://cors-anywhere.herokuapp.com/https://maps.googleapis.com/maps/api/'
                    : "https://maps.googleapis.com/maps/api/",
            usePinPointingSearch: true,
            apiKey: "AIzaSyDYtn83aed8w84MFMGZRGnBAFRFvbvW9MM",
            onPlacePicked: (LocationResult result) async {
              FirebaseAuth auth = FirebaseAuth.instance;
              debugPrint("Place picked: ${result.formattedAddress}");
              await ref
                  .read(userProfileControllerProvider.notifier)
                  .updateLocation(
                    id: auth.currentUser!.uid,
                    location: result.formattedAddress!,
                    context: context,
                  );
            },
            enableNearbyPlaces: false,
            showSearchInput: true,
            initialLocation: initialLocation, // Set user's current location
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onMapCreated: (controller) {
              mapController = controller;
            },
            searchInputConfig: const SearchInputConfig(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              autofocus: false,
              textDirection: TextDirection.ltr,
            ),
            searchInputDecorationConfig: const SearchInputDecorationConfig(
              hintText: "Search for a building, street or ...",
            ),
            autocompletePlacesSearchRadius: 150,
          );
        },
      ),
    );
  }
}

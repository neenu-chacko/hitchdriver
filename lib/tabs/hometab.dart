import 'dart:async';

import 'package:cabdriver/brand_colors.dart';
import 'package:cabdriver/datamodels/driver.dart';
import 'package:cabdriver/globalvariabels.dart';
import 'package:cabdriver/helpers/helpermethods.dart';
import 'package:cabdriver/helpers/pushnotificationservice.dart';
import 'package:cabdriver/widgets/AvailabilityButton.dart';
import 'package:cabdriver/widgets/ConfirmSheet.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeTab extends StatefulWidget {
  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {

  GoogleMapController mapController;
  Completer<GoogleMapController> _controller = Completer();

  DatabaseReference tripRequestRef;

  var geoLocator = Geolocator();
  var locationOptions = LocationOptions(accuracy: LocationAccuracy.bestForNavigation, distanceFilter: 4);

  String availabilityTitle = 'OFFER A RIDE';
  Color availabilityColor = BrandColors.colorGreen;

  bool isAvailable = false;

TextEditingController driverdestination= new TextEditingController();

  void getCurrentPosition() async {

    Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPosition = position;
    LatLng pos = LatLng(position.latitude, position.longitude);
    mapController.animateCamera(CameraUpdate.newLatLng(pos));

  }

  void getCurrentDriverInfo () async {

    currentFirebaseUser = await FirebaseAuth.instance.currentUser();
    DatabaseReference driverRef = FirebaseDatabase.instance.reference().child('drivers/${currentFirebaseUser.uid}');
    driverRef.once().then((DataSnapshot snapshot){

      if(snapshot.value != null){
        currentDriverInfo = Driver.fromSnapshot(snapshot);
        print(currentDriverInfo.fullName);
      }

    });

    PushNotificationService pushNotificationService = PushNotificationService();

    pushNotificationService.initialize(context);
    pushNotificationService.getToken();

    HelperMethods.getHistoryInfo(context);
    HelperMethods.getdriverInfo(context);
    HelperMethods.getmail(context);
    HelperMethods.getphone(context);
  }

  @override
  void initState() {
    super.initState();
    getCurrentDriverInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        GoogleMap(
          padding: EdgeInsets.only(top: 135),
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          mapType: MapType.normal,
          initialCameraPosition: googlePlex,
          onMapCreated: (GoogleMapController controller){
            _controller.complete(controller);
            mapController = controller;

            getCurrentPosition();
          },
        ),
        Container(
          
          height: 195,
          width: double.infinity,
          color: Colors.white,
          
        
        ),
        
          Positioned(
            top:60,
            left:25,
            right:25,
                      child: new TextFormField(
                        controller: driverdestination,
                        decoration: new InputDecoration(
                          labelText: "Enter Destination",
                          fillColor: Colors.white,
                          border: new OutlineInputBorder(
                            borderRadius: new BorderRadius.circular(25.0),
                            borderSide: new BorderSide(
                            ),
                          ),
                          //fillColor: Colors.green
                        ),
                        
                        keyboardType: TextInputType.emailAddress,
                        style: new TextStyle(
                          fontFamily: "Poppins",
                        ),
                      ),
          ),
        


        Positioned(
          top: 130,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AvailabilityButton(
                title: availabilityTitle,
                color: availabilityColor,
                onPressed: (){


                  //ivde
                DatabaseReference dest = FirebaseDatabase.instance.reference().child('drivers/${currentFirebaseUser.uid}/destination');
                dest.set(driverdestination.text);

                showModalBottomSheet(
                  isDismissible: false,
                    context: context,
                    builder: (BuildContext context) => ConfirmSheet(
                      title: (!isAvailable) ? 'OFFER A RIDE' : 'STOP ACCEPTING',
                      subtitle: (!isAvailable) ? 'You are about to become available to receive trip requests. Confirm to continue!': 'You will stop receiving new trip requests.',

                      onPressed: (){


                        if(!isAvailable){
                          GoOnline();
                          getLocationUpdates();
                          Navigator.pop(context);

                          setState(() {
                            availabilityColor = Colors.red;
                            availabilityTitle = 'STOP ACCEPTING';
                            isAvailable = true;
                          });

                        }
                        else{

                          GoOffline();
                          Navigator.pop(context);
                          setState(() {
                            availabilityColor = BrandColors.colorGreen;
                            availabilityTitle = 'OFFER A RIDE';
                            isAvailable = false;
                          });
                        }

                      },
                    ),
                );

                },
              ),
              SizedBox(height:5),
              
            ],
          ),
        )

      ],
    );
  }

  void GoOnline(){
    Geofire.initialize('driversAvailable');
    Geofire.setLocation(currentFirebaseUser.uid, currentPosition.latitude, currentPosition.longitude);

    tripRequestRef = FirebaseDatabase.instance.reference().child('drivers/${currentFirebaseUser.uid}/newtrip');
    tripRequestRef.set('waiting');

    tripRequestRef.onValue.listen((event) {

    });

  }

  void GoOffline (){

    Geofire.removeLocation(currentFirebaseUser.uid);
    tripRequestRef.onDisconnect();
    tripRequestRef.remove();
    tripRequestRef = null;

  }

  void getLocationUpdates(){

    homeTabPositionStream = geoLocator.getPositionStream(locationOptions).listen((Position position) {
      currentPosition = position;

      if(isAvailable){
        Geofire.setLocation(currentFirebaseUser.uid, position.latitude, position.longitude);
      }

      LatLng pos = LatLng(position.latitude, position.longitude);
      mapController.animateCamera(CameraUpdate.newLatLng(pos));

    });

  }
}

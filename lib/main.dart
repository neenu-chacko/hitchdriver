import 'package:cabdriver/dataprovider.dart';
import 'package:cabdriver/globalvariabels.dart';
import 'package:cabdriver/screens/login.dart';
import 'package:cabdriver/screens/mainpage.dart';
import 'package:cabdriver/screens/registration.dart';
import 'package:cabdriver/screens/vehicleinfo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:provider/provider.dart';

import 'screens/mainpage.dart';
import 'screens/registration.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final FirebaseApp app = await FirebaseApp.configure(
    name: 'db2',
    options: Platform.isIOS
        ? const FirebaseOptions(
      googleAppID: '1:169450788828:ios:565f2d4b4623a7dbf9a119',
      gcmSenderID: '169450788828',
      databaseURL: 'https://finaltry-622c5.firebaseio.com',
    )
        : const FirebaseOptions(
      googleAppID: '1:151917049307:android:6a2d325f6c05c125f0e3fe',
      apiKey: 'AIzaSyDQSm22dfjceA0OiQ9XL-0tQ0d7_XZTXpQ',
      databaseURL: 'https://finaltry-622c5.firebaseio.com',
    ),
  );

  currentFirebaseUser = await FirebaseAuth.instance.currentUser();

  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider(
      create: (context) => AppData(),
      child: MaterialApp(
        theme: ThemeData(

          fontFamily: 'Brand-Regular',
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        //initialRoute: (currentFirebaseUser == null) ? LoginPage.id : MainPage.id,
        initialRoute: RegistrationPage.id,
        routes: {
          MainPage.id: (context) => MainPage(),
          RegistrationPage.id: (context) => RegistrationPage(),
          VehicleInfoPage.id: (context) => VehicleInfoPage(),
          LoginPage.id: (context) => LoginPage(),
        },
      ),
    );
  }
}


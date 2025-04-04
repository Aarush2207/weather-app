import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:weather/homescreen.dart';
import 'package:weather/week_model.dart';

class Screen extends StatefulWidget {
  const Screen({super.key});

  @override
  State<Screen> createState() => _ScreenState();
}

class _ScreenState extends State<Screen> {
  double lat = 0.0;
  double long = 0.0;

  @override
  void initState() {
    super.initState();
    determinePosition(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/icon/b2.jpeg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/icon/homeimage.png',
                height: 400,
                width: 270,
              ),
              Image.asset(
                'assets/icon/Weather ForeCasts.png',
                height: 150,
                width: 250,
              ),
              SizedBox(height: 50),
              Container(
                height: 60,
                width: 250,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextButton(
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                  ),
                  onPressed: () {
                    sendLocationToApi();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Homescreen(),
                      ),
                    );
                  },
                  child: Text(
                    'GET STARTED',
                    style: TextStyle(fontSize: 23),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Position> determinePosition(BuildContext context) async {
    final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
    LocationPermission permission;
    bool serviceEnabled;

    serviceEnabled = await _geolocatorPlatform.isLocationServiceEnabled();
    if (!serviceEnabled) {
      alertPopup(
        context,
        title: "Location Services Disabled",
        message: "Please enable location services to use this app.",
        action: () async {
          await Geolocator.openLocationSettings();
          Navigator.pop(context);
        },
      );
      return Future.error('Location services are disabled.');
    }

    permission = await _geolocatorPlatform.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _geolocatorPlatform.requestPermission();
      if (permission == LocationPermission.denied) {
        alertPopup(
          context,
          title: "Location Permission Denied",
          message: "Location permission is required to use this app.",
          action: () async {
            await Geolocator.openAppSettings();
            Navigator.pop(context);
          },
        );
        return Future.error('Location permission denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      alertPopup(
        context,
        title: "Location Permission Permanently Denied",
        message: "Please enable location permission in app settings.",
        action: () async {
          await Geolocator.openAppSettings();
          Navigator.pop(context);
        },
      );
      return Future.error('Location permission permanently denied.');
    }

    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );
    StreamSubscription<Position> positionStream =
    Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position? position) {
        if (position != null) {
          lat = position.latitude;
          long = position.longitude;
          dev.log("Latitude: $lat, Longitude: $long");
        }
      },
    );

    return await _geolocatorPlatform.getCurrentPosition();
  }

  void alertPopup(BuildContext context,
      {required String title, required String message, required VoidCallback action}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: action,
                child: const Text('OK'),
              ),
            ],
          ),
        );
      },
    );
  }

  sendLocationToApi() async {
    var url =
        "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$long&appid=f93ca9595e1af4c92dc4c70c84be7b2c";
    var response = await http.get(Uri.parse(url));
    dev.log('Response status: ${response.statusCode}');
    dev.log('Response body: ${response.body}');
    if (response.statusCode == 200) {
      return OpenApiModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load data');
    }
  }
}

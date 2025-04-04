import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class LastScreen extends StatefulWidget {
  const LastScreen({super.key});

  @override
  State<LastScreen> createState() => _LastScreenState();
}

class _LastScreenState extends State<LastScreen> {
  late Future<List<Map<String, dynamic>>> futureWeatherData;
  double? latitude;
  double? longitude;

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<Map<String, dynamic>> fetchWeatherOpenWeather() async {
    Position position = await _determinePosition();
    latitude = position.latitude;
    longitude = position.longitude;

    var url =
        "https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=f93ca9595e1af4c92dc4c70c84be7b2c&units=metric";

    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception('Failed to fetch weather data from OpenWeather');
    }
  }

  Future<Map<String, dynamic>> fetchWeatherWeatherAPI() async {
    Position position = await _determinePosition();
    latitude = position.latitude;
    longitude = position.longitude;

    var url =
        "http://api.weatherapi.com/v1/current.json?key=0807ba1b521a43d2b0874019252101&q=$latitude,$longitude";

    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception('Failed to fetch weather data from WeatherAPI');
    }
  }

  Future<List<Map<String, dynamic>>> fetchWeatherData() async {
    var openWeatherData = fetchWeatherOpenWeather();
    var weatherAPIData = fetchWeatherWeatherAPI();

    return await Future.wait([openWeatherData, weatherAPIData]);
  }

  @override
  void initState() {
    super.initState();
    futureWeatherData = fetchWeatherData();
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
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: futureWeatherData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              var openWeatherData = snapshot.data![0];
              var weatherAPIData = snapshot.data![1];
              var weather = openWeatherData['weather'][0];
              var main = openWeatherData['main'];
              var sys = openWeatherData['sys'];
              var weatherAPICondition = weatherAPIData['current']['condition'];
              var weatherAPITemperature = weatherAPIData['current']['temp_c'];
              var location = weatherAPIData['location'];
              var city = location['name'];
              var region = location['region'];
              var country = location['country'];

              String iconUrl =
                  'https://openweathermap.org/img/wn/${weather['icon']}@2x.png';
              String weatherAPIIconUrl = "http:${weatherAPICondition['icon']}";

              return Column(
                children: [
                  SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(40.0),
                    height: 410,
                    width: 450,
                    alignment: Alignment.topCenter,
                    child: Column(
                      children: [
                        Text(
                          "${country}",
                          style: TextStyle(fontSize: 30, color: Colors.black87),
                        ),
                        Text(
                          "${region}",
                          style: TextStyle(fontSize: 30, color: Colors.black87),
                        ),
                        Text(
                          "${city}",
                          style: TextStyle(fontSize: 30, color: Colors.black87),
                        ),
                        Text(
                          "Max: ${main['temp_max']}°C",
                          style: TextStyle(fontSize: 20, color: Colors.black87),
                        ),
                        Text(
                          "Min: ${main['temp_min']}°C",
                          style: TextStyle(fontSize: 20, color: Colors.black87),
                        ),
                        SizedBox(height: 20),
                        Text(
                          "${weatherAPITemperature}°C",
                          style: TextStyle(fontSize: 28, color: Colors.black87),
                        ),
                        Text(
                          "${weatherAPICondition['text']}",
                          style: TextStyle(fontSize: 25, color: Colors.black87),
                        ),
                        SizedBox(
                          height:7,
                        ),
                        Image.network(weatherAPIIconUrl,height: 40,width: 100,) ,
                      ],
                    ),
                  ),
                  Container(
                    height: 150,
                    width: 500,
                    padding: EdgeInsets.all(0),
                    child: Card(
                      color: Colors.transparent,
                      elevation: 5.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      margin: EdgeInsets.all(18.0),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(40.0),
                            child: Image.asset(
                              "assets/icon/airquality.png",
                              height: 20,
                              width: 20,
                            ),
                          ),
                          Text(
                            "Wind Speed:",
                            style: TextStyle(fontSize: 20, color: Colors.black87),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Text(
                            "${openWeatherData['wind']['speed']} m/s",
                            style: TextStyle(fontSize: 20, color: Colors.black87),
                          )
                        ],
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        height: 200,
                        width: 180,
                        child: Card(
                          color: Colors.transparent,
                          elevation: 5.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          margin: EdgeInsets.all(15.0),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                SizedBox(height: 20),
                                Image.asset('assets/icon/star.png'),
                                Column(
                                  children: [
                                    SizedBox(height: 0),
                                    Text(
                                      'SUNRISE',
                                      style: TextStyle(fontSize: 20, color: Colors.white),
                                    ),
                                    Text(
                                      DateFormat('hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(sys['sunrise'] * 1000)),
                                      style: TextStyle(fontSize: 20, color: Colors.black87),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 200,
                        width: 180,
                        child: Card(
                          color: Colors.transparent,
                          elevation: 5.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          margin: EdgeInsets.all(15.0),
                          child: Column(
                            children: [
                              SizedBox(height: 20),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  children: [
                                    SizedBox(height: 0),
                                    Text(
                                      'SUNSET',
                                      style: TextStyle(fontSize: 20, color: Colors.white),
                                    ),
                                    Text(
                                      DateFormat('hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(sys['sunset'] * 1000)),
                                      style: TextStyle(fontSize: 20, color: Colors.black87),
                                    ),
                                  ],
                                ),
                              ),
                              Image.asset('assets/icon/star.png')
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            } else {
              return const Center(child: Text('No data available'));
            }
          },
        ),
      ),
    );
  }
}

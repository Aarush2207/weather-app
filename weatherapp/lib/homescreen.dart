import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'week_model.dart';
import 'lastscreen.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:weather/HourlyForecast.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  late Future<OpenApiModel> futureWeather;
  late Future<HourlyForecast> futureHourlyWeather;
  late Future<Map<String, dynamic>> futureLocationData;

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

  Future<OpenApiModel> fetchWeather() async {
    Position position = await _determinePosition();
    double lat = position.latitude;
    double lon = position.longitude;

    var url =
        "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=f93ca9595e1af4c92dc4c70c84be7b2c&units=metric";

    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return OpenApiModel.fromJson(data);
    } else {
      throw Exception('Failed to fetch weather data');
    }
  }

  Future<HourlyForecast> fetchHourlyWeatherData() async {
    Position position = await _determinePosition();
    double lat = position.latitude;
    double lon = position.longitude;

    var url =
        "http://api.weatherapi.com/v1/forecast.json?key=0807ba1b521a43d2b0874019252101&q=$lat,$lon&hours=24";

    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return HourlyForecast.fromJson(data);
    } else {
      throw Exception('Failed to fetch hourly forecast data');
    }
  }

  Future<Map<String, dynamic>> fetchLocationData() async {
    Position position = await _determinePosition();
    double lat = position.latitude;
    double lon = position.longitude;

    var url =
        "http://api.weatherapi.com/v1/current.json?key=0807ba1b521a43d2b0874019252101&q=$lat,$lon";

    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data['location'];
    } else {
      throw Exception('Failed to fetch location data');
    }
  }

  @override
  void initState() {
    super.initState();
    futureWeather = fetchWeather();
    futureHourlyWeather = fetchHourlyWeatherData();
    futureLocationData = fetchLocationData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.small(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LastScreen()),
        ),
        child: Image.asset('assets/icon/nextpage1.png', height: 35),
      ),
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/icon/b2.jpeg',
            fit: BoxFit.cover,
          ),
          FutureBuilder<OpenApiModel>(
            future: futureWeather,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                OpenApiModel weatherData = snapshot.data!;

                int timezoneOffset = weatherData.timezone;
                DateTime utcTime = DateTime.now().toUtc();
                DateTime localTime = utcTime.add(Duration(seconds: timezoneOffset));
                String formattedTime = DateFormat('hh:mm a').format(localTime);

                return Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Column(
                      children: [
                        Image.asset('assets/icon/weathercloud.png', height: 200, width: 500),
                        SizedBox(height: 0, width: 250),
                        FutureBuilder<Map<String, dynamic>>(
                          future: futureLocationData,
                          builder: (context, locationSnapshot) {
                            if (locationSnapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            } else if (locationSnapshot.hasError) {
                              return Center(child: Text('Error: ${locationSnapshot.error}'));
                            } else if (locationSnapshot.hasData) {
                              var locationData = locationSnapshot.data!;
                              String region = locationData['region'];
                              String name = locationData['name'];
                              String country = locationData['country'];

                              return Column(
                                children: [
                                  Text(
                                    "$country",
                                    style: TextStyle(fontSize: 40, color: Colors.black87, fontWeight: FontWeight.w400),
                                  ),
                                  Text(
                                    "$region",
                                    style: TextStyle(fontSize: 30, color: Colors.black87, fontWeight: FontWeight.w400),
                                  ),
                                  Text(
                                    "$name",
                                    style: TextStyle(fontSize: 30, color: Colors.black87, fontWeight: FontWeight.w400),
                                  ),
                                ],
                              );
                            } else {
                              return Center(child: Text('No location data available'));
                            }
                          },
                        ),
                        FutureBuilder<HourlyForecast>(
                          future: futureHourlyWeather,
                          builder: (context, hourlySnapshot) {
                            if (hourlySnapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            } else if (hourlySnapshot.hasError) {
                              return Center(child: Text('Error: ${hourlySnapshot.error}'));
                            } else if (hourlySnapshot.hasData) {
                              HourlyForecast hourlyData = hourlySnapshot.data!;

                              double currentTemp = hourlyData.hourly[0].temp;

                              return Column(
                                children: [
                                  Text(
                                    " $currentTemp°C",
                                    style: TextStyle(fontSize: 35, color: Colors.black87, fontWeight: FontWeight.w400),
                                  ),
                                ],
                              );
                            } else {
                              return Center(child: Text('No hourly data available'));
                            }
                          },
                        ),
                        SizedBox(height: 30),
                        Text(
                          "Pressure: ${weatherData.main.pressure} hPa",
                          style: TextStyle(fontSize: 18, color: Colors.black87, fontWeight: FontWeight.w400),
                        ),
                        Text(
                          "Humidity: ${weatherData.main.humidity}%",
                          style: TextStyle(fontSize: 18, color: Colors.black87, fontWeight: FontWeight.w400),
                        ),
                        Text(
                          "Sealevel: ${weatherData.main.seaLevel} m",
                          style: TextStyle(fontSize: 18, color: Colors.black87, fontWeight: FontWeight.w400),
                        ),
                        SizedBox(height: 40),
                        Container(
                          height: 230,
                          width: 370,
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 122, 135, 140).withOpacity(0.7),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(3.0),
                                      child: Text(
                                        "Today",
                                        style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w400),
                                      ),
                                    ),
                                    Text(
                                      " $formattedTime",
                                      style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w400),
                                    ),
                                  ],
                                ),
                              ),
                              Divider(
                                color: Color.fromARGB(255, 32, 24, 24),
                                thickness: 2,
                              ),
                              SizedBox(height: 10),
                              FutureBuilder<HourlyForecast>(
                                future: futureHourlyWeather,
                                builder: (context, oneCallSnapshot) {
                                  if (oneCallSnapshot.connectionState == ConnectionState.waiting) {
                                    return const Center(child: CircularProgressIndicator());
                                  } else if (oneCallSnapshot.hasError) {
                                    return Center(child: Text('Error: ${oneCallSnapshot.error}'));
                                  } else if (oneCallSnapshot.hasData) {
                                    HourlyForecast oneCallData = oneCallSnapshot.data!;

                                    return SizedBox(
                                      height: 140,
                                      width: double.infinity,
                                      child: ListView.builder(
                                        itemCount: oneCallData.hourly.length,
                                        shrinkWrap: true,
                                        scrollDirection: Axis.horizontal,
                                        itemBuilder: (context, index) {
                                          var hourly = oneCallData.hourly[index];
                                          var time = DateTime.parse(hourly.time);
                                          String timeFormatted = DateFormat('hh:mm a').format(time);

                                          return Container(
                                            padding: EdgeInsets.all(10),
                                            child: Column(
                                              children: [
                                                Text("${hourly.temp}°C"),
                                                Image.network(
                                                  'https:${hourly.icon}',
                                                  height: 70,
                                                  width: 70,
                                                ),
                                                Text(timeFormatted),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  } else {
                                    return Center(child: Text('No hourly data available'));
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              } else {
                return Center(child: Text('No data available'));
              }
            },
          ),
        ],
      ),
    );
  }
}

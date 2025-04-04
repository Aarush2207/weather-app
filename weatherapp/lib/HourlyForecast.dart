class CurrentWeatherModel {
  final Location location;
  final Current current;

  CurrentWeatherModel({required this.location, required this.current});

  factory CurrentWeatherModel.fromJson(Map<String, dynamic> json) {
    return CurrentWeatherModel(
      location: Location.fromJson(json['location']),
      current: Current.fromJson(json['current']),
    );
  }
}

class Location {
  final String name;
  final String country;
  final double lat;
  final double lon;

  Location({
    required this.name,
    required this.country,
    required this.lat,
    required this.lon,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      name: json['name'],
      country: json['country'],
      lat: json['lat'],
      lon: json['lon'],
    );
  }
}

class Current {
  final double tempC;
  final double tempF;
  final double windKph;
  final double windMph;
  final double humidity;
  final Condition condition;

  Current({
    required this.tempC,
    required this.tempF,
    required this.windKph,
    required this.windMph,
    required this.humidity,
    required this.condition,
  });

  factory Current.fromJson(Map<String, dynamic> json) {
    return Current(
      tempC: json['temp_c'],
      tempF: json['temp_f'],
      windKph: json['wind_kph'],
      windMph: json['wind_mph'],
      humidity: json['humidity'],
      condition: Condition.fromJson(json['condition']),
    );
  }
}

class Condition {
  final String text;
  final String icon;
  final int code;

  Condition({required this.text, required this.icon, required this.code});

  factory Condition.fromJson(Map<String, dynamic> json) {
    return Condition(
      text: json['text'],
      icon: json['icon'],
      code: json['code'],
    );
  }
}

class HourlyForecast {
  final List<Hourly> hourly;

  HourlyForecast({required this.hourly});

  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    var list = json['forecast']['forecastday'][0]['hour'] as List;
    List<Hourly> hourlyList = list.map((i) => Hourly.fromJson(i)).toList();
    return HourlyForecast(hourly: hourlyList);
  }
}

class Hourly {
  final String time;
  final double temp;
  final String icon;

  Hourly({required this.time, required this.temp, required this.icon});

  factory Hourly.fromJson(Map<String, dynamic> json) {
    return Hourly(
      time: json['time'],
      temp: json['temp_c'],
      icon: json['condition']['icon'],
    );
  }
}

class DailyForecast {
  final List<ForecastDay> forecastDay;

  DailyForecast({required this.forecastDay});

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    var list = json['forecast']['forecastday'] as List;
    List<ForecastDay> forecastList = list.map((i) => ForecastDay.fromJson(i)).toList();
    return DailyForecast(forecastDay: forecastList);
  }
}

class ForecastDay {
  final String date;
  final double maxTempC;
  final double minTempC;
  final Condition condition;

  ForecastDay({
    required this.date,
    required this.maxTempC,
    required this.minTempC,
    required this.condition,
  });

  factory ForecastDay.fromJson(Map<String, dynamic> json) {
    return ForecastDay(
      date: json['date'],
      maxTempC: json['day']['maxtemp_c'],
      minTempC: json['day']['mintemp_c'],
      condition: Condition.fromJson(json['day']['condition']),
    );
  }
}

class WeatherAPIModel {
  final CurrentWeatherModel currentWeather;
  final HourlyForecast hourlyForecast;
  final DailyForecast dailyForecast;

  WeatherAPIModel({
    required this.currentWeather,
    required this.hourlyForecast,
    required this.dailyForecast,
  });

  factory WeatherAPIModel.fromJson(Map<String, dynamic> json) {
    return WeatherAPIModel(
      currentWeather: CurrentWeatherModel.fromJson(json),
      hourlyForecast: HourlyForecast.fromJson(json),
      dailyForecast: DailyForecast.fromJson(json),
    );
  }
}

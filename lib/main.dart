import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(WeatherApp());

class WeatherApp extends StatefulWidget {
  @override
  _WeatherAppState createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  String apiKey =
      '0b65ccf66ad2b73d7d1bf772a558702d'; // Ganti dengan API key OpenWeather Anda
  String city = 'jember'; // Kota default

  String temperature = '';
  String weatherCondition = '';
  String errorMessage = '';
  String windSpeed = '';
  String weatherPrediction = '';

  Future<void> fetchWeatherData(String cityName) async {
    try {
      var url = Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey&units=metric');
      var response = await http.get(url);
      var jsonData = jsonDecode(response.body);

      setState(() {
        temperature = jsonData['main']['temp'].toString();
        weatherCondition = jsonData['weather'][0]['main'];
        windSpeed = jsonData['wind']['speed'].toString();
        errorMessage = '';
      });

      await fetchWeatherPrediction(
          jsonData['coord']['lat'], jsonData['coord']['lon']);
    } catch (error) {
      setState(() {
        temperature = '';
        weatherCondition = '';
        windSpeed = '';
        weatherPrediction = '';
        errorMessage = 'Failed to fetch weather data.';
      });
    }
  }

  Future<void> fetchWeatherPrediction(double lat, double lon) async {
    try {
      var url = Uri.parse(
          'https://api.openweathermap.org/data/2.5/onecall?lat=$lat&lon=$lon&appid=$apiKey&units=metric');
      var response = await http.get(url);
      var jsonData = jsonDecode(response.body);

      var dailyForecast = jsonData['daily'];
      var nextDayForecast = dailyForecast[1];
      var weatherPredictionCondition = nextDayForecast['weather'][0]['main'];
      var weatherPredictionTemp = nextDayForecast['temp']['day'].toString();
      var windPredictionSpeed = nextDayForecast['wind_speed'].toString();

      setState(() {
        weatherPrediction =
            'Condition: $weatherPredictionCondition, Temperature: $weatherPredictionTemp°C, Wind Speed: $windPredictionSpeed m/s';
      });
    } catch (error) {
      setState(() {
        weatherPrediction = '';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchWeatherData(city);
  }

  void searchCity(String cityName) {
    setState(() {
      city = cityName;
    });
    fetchWeatherData(cityName);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Center(
              child: Text(
            'Weather App',
            style: TextStyle(color: Colors.black),
          )),
          backgroundColor: Colors.white,
        ),
        body: Column(
          children: <Widget>[
            Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    TextField(
                      onChanged: (value) {
                        searchCity(value);
                      },
                      decoration: InputDecoration(
                        labelText: 'Search City',
                      ),
                    ),
                  ],
                )),
            SizedBox(
              height: 20,
            ),
            Image.asset(
              'images/sun.png',
              width: 100,
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              city,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            SizedBox(
              height: 20,
            ),
            if (errorMessage.isNotEmpty)
              Text(
                errorMessage,
                style: TextStyle(fontSize: 20),
              ),
            if (temperature.isNotEmpty)
              Text(
                'Temperature: $temperature°C',
                style: TextStyle(fontSize: 24),
              ),
            if (weatherCondition.isNotEmpty)
              Text(
                'Condition: $weatherCondition',
                style: TextStyle(fontSize: 24),
              ),
            if (windSpeed.isNotEmpty)
              Text(
                'Wind Speed: $windSpeed m/s',
                style: TextStyle(fontSize: 24),
              ),
            if (weatherPrediction.isNotEmpty)
              Text(
                'Weather Prediction for Tomorrow: $weatherPrediction',
                style: TextStyle(fontSize: 24),
              ),
          ],
        ),
      ),
    );
  }
}

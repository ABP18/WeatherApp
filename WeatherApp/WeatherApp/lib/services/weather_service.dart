import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:weatherapp/screens/weather_model.dart';

class WeatherService {
  static const String _apiKey = 'fd230250f8244ab1b55132725250904';
  static const String _baseUrl = 'http://api.weatherapi.com/v1';

  Future<WeatherData> getCurrentWeather(String query) async {
    final url = '$_baseUrl/current.json?key=$_apiKey&q=$query&aqi=yes';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      return WeatherData.fromJson(json);
    } else {
      throw Exception('Error: ${response.statusCode} - ${response.body}');
    }
  }

  Future<List<ForecastData>> getForecast(String query, int days) async {
    final url = '$_baseUrl/forecast.json?key=$_apiKey&q=$query&days=$days&alerts=yes';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return (json['forecast']['forecastday'] as List)
          .map((day) => ForecastData.fromJson(day))
          .toList();
    } else {
      throw Exception('Error: ${response.statusCode}');
    }
  }

  Future<HistoryData> getHistory(String query, String date) async {
    final url = '$_baseUrl/history.json?key=$_apiKey&q=$query&dt=$date';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return HistoryData.fromJson(json['forecast']['forecastday'][0]);
    } else {
      throw Exception('Error: ${response.statusCode}');
    }
  }

  Future<List<AlertData>> getAlerts(String query) async {
    final url = '$_baseUrl/forecast.json?key=$_apiKey&q=$query&alerts=yes';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final alerts = json['alerts']['alert'] as List?;
      return alerts?.map((alert) => AlertData.fromJson(alert)).toList() ?? [];
    } else {
      throw Exception('Error: ${response.statusCode}');
    }
  }

  Future<AstronomyData> getAstronomy(String query, String date) async {
    final url = '$_baseUrl/astronomy.json?key=$_apiKey&q=$query&dt=$date';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return AstronomyData.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error: ${response.statusCode}');
    }
  }

  Future<List<SearchResult>> searchLocation(String query) async {
    final url = '$_baseUrl/search.json?key=$_apiKey&q=$query';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as List;
      return json.map((item) => SearchResult.fromJson(item)).toList();
    } else {
      throw Exception('Error: ${response.statusCode}');
    }
  }

  Future<AirQualityData> getAirQuality(String query) async {
    final url = '$_baseUrl/current.json?key=$_apiKey&q=$query&aqi=yes';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return AirQualityData.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error: ${response.statusCode}');
    }
  }

  Future<WeatherData> getWeatherByIP() async {
    final url = '$_baseUrl/current.json?key=$_apiKey&q=auto:ip';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return WeatherData.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error: ${response.statusCode}');
    }
  }

  Future<FutureData> getFutureWeather(String query, String date) async {
    final url = '$_baseUrl/future.json?key=$_apiKey&q=$query&dt=$date';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return FutureData.fromJson(json['forecast']['forecastday'][0]);
    } else {
      throw Exception('Error: ${response.statusCode} - Solo disponible en planes pagos');
    }
  }
}
class WeatherData {
  final String cityName;
  final double temperature;
  final String description;
  final int humidity;
  final double windSpeed;
  final double? feelsLike;
  final double? uvIndex;   // Cambiado a double?, ya que el índice UV puede ser decimal
  final String? timeZone;

  WeatherData({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.humidity,
    required this.windSpeed,
    this.feelsLike,
    this.uvIndex,
    this.timeZone,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      cityName: json['location']['name'],
      temperature: (json['current']['temp_c'] as num).toDouble(),
      description: json['current']['condition']['text'],
      humidity: json['current']['humidity'] as int,
      windSpeed: (json['current']['wind_kph'] as num).toDouble() / 3.6,
      feelsLike: (json['current']['feelslike_c'] as num?)?.toDouble(),
      uvIndex: (json['current']['uv'] as num?)?.toDouble(),   // Convertido a double?
      timeZone: json['location']['tz_id'],
    );
  }
}

class ForecastData {
  final DateTime date;
  final double maxTemp;
  final double minTemp;
  final String condition;

  ForecastData({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.condition,
  });

  factory ForecastData.fromJson(Map<String, dynamic> json) {
    return ForecastData(
      date: DateTime.parse(json['date']),
      maxTemp: (json['day']['maxtemp_c'] as num).toDouble(),
      minTemp: (json['day']['mintemp_c'] as num).toDouble(),
      condition: json['day']['condition']['text'],
    );
  }
}

class HistoryData {
  final DateTime date;
  final double avgTemp;
  final double precipitation;

  HistoryData({
    required this.date,
    required this.avgTemp,
    required this.precipitation,
  });

  factory HistoryData.fromJson(Map<String, dynamic> json) {
    return HistoryData(
      date: DateTime.parse(json['date']),
      avgTemp: (json['day']['avgtemp_c'] as num).toDouble(),
      precipitation: (json['day']['totalprecip_mm'] as num).toDouble(),
    );
  }
}

class AlertData {
  final String headline;
  final String severity;
  final String description;

  AlertData({
    required this.headline,
    required this.severity,
    required this.description,
  });

  factory AlertData.fromJson(Map<String, dynamic> json) {
    return AlertData(
      headline: json['headline'],
      severity: json['severity'],
      description: json['desc'],
    );
  }
}

class AstronomyData {
  final String sunrise;
  final String sunset;
  final String moonPhase;

  AstronomyData({
    required this.sunrise,
    required this.sunset,
    required this.moonPhase,
  });

  factory AstronomyData.fromJson(Map<String, dynamic> json) {
    return AstronomyData(
      sunrise: json['astronomy']['astro']['sunrise'],
      sunset: json['astronomy']['astro']['sunset'],
      moonPhase: json['astronomy']['astro']['moon_phase'],
    );
  }
}

class SearchResult {
  final String name;
  final String region;
  final String country;

  SearchResult({
    required this.name,
    required this.region,
    required this.country,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      name: json['name'],
      region: json['region'],
      country: json['country'],
    );
  }
}

class AirQualityData {
  final double aqi;   // Cambiado a double?, ya que el índice AQI puede ser decimal

  AirQualityData({required this.aqi});

  factory AirQualityData.fromJson(Map<String, dynamic> json) {
    return AirQualityData(
      aqi: (json['current']['air_quality']['us-epa-index'] as num).toDouble(),  // Convertido a double
    );
  }
}

class FutureData {
  final DateTime date;
  final double avgTemp;

  FutureData({
    required this.date,
    required this.avgTemp,
  });

  factory FutureData.fromJson(Map<String, dynamic> json) {
    return FutureData(
      date: DateTime.parse(json['date']),
      avgTemp: (json['day']['avgtemp_c'] as num).toDouble(),
    );
  }
}

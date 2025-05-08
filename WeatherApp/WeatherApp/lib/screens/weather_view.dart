import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'weather_model.dart';
import 'dart:ui';

class WeatherView extends StatelessWidget {
  final bool isLoading;
  final WeatherData? currentWeather;
  final List<ForecastData>? forecast;
  final HistoryData? history;
  final List<AlertData>? alerts;
  final AstronomyData? astronomy;
  final List<SearchResult>? searchResults;
  final AirQualityData? airQuality;
  final FutureData? futureWeather;
  final TextEditingController cityController;
  final VoidCallback onSearch;
  final Function(String) onSearchTyping;

  const WeatherView({
    required this.isLoading,
    required this.currentWeather,
    required this.forecast,
    required this.history,
    required this.alerts,
    required this.astronomy,
    required this.searchResults,
    required this.airQuality,
    required this.futureWeather,
    required this.cityController,
    required this.onSearch,
    required this.onSearchTyping,
    required dynamic weatherData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20.0),
      children: [
        const SizedBox(height: 15), // Reduced from 30 to 15
        if (isLoading)
          Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                isDarkMode ? Colors.white : Colors.blue,
              ),
            ),
          )
        else ...[
          if (currentWeather != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: WeatherDisplay(weatherData: currentWeather!),
            ),
          if (forecast != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: ForecastDisplay(forecast: forecast!),
            ),
          if (history != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: HistoryDisplay(history: history!),
            ),
          if (alerts != null && alerts!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: AlertsDisplay(alerts: alerts!),
            ),
          if (astronomy != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: AstronomyDisplay(astronomy: astronomy!),
            ),
          if (airQuality != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: AirQualityDisplay(airQuality: airQuality!),
            ),
          if (futureWeather != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: FutureDisplay(futureWeather: futureWeather!),
            ),
          if (searchResults != null && searchResults!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: SearchResultsDisplay(searchResults: searchResults!),
            ),
        ],
      ],
    );
  }
}

class WeatherDisplay extends StatelessWidget {
  final WeatherData weatherData;

  const WeatherDisplay({required this.weatherData});

  static const Map<String, String> _weatherTranslations = {
    "Sunny": "Soleado",
    "Clear": "Despejado",
    "Partly cloudy": "Parcialmente nublado",
    "Cloudy": "Nublado",
    "Overcast": "Cubierto",
    "Mist": "Neblina",
    "Patchy rain possible": "Posible lluvia irregular",
    "Patchy rain nearby": "Posible lluvia cerca",
    "Light rain": "Lluvia ligera",
    "Moderate rain": "Lluvia moderada",
    "Heavy rain": "Lluvia intensa",
    "Thunderstorm": "Tormenta eléctrica",
  };

  static const Map<String, String> _timeZoneTranslations = {
    "Europe": "Europa",
    "America": "América",
    "Asia": "Asia",
    "Africa": "África",
    "Australia": "Australia",
    "Pacific": "Pacífico",
    "Atlantic": "Atlántico",
    "Indian": "Índico",
    "Antarctica": "Antártida",
  };

  String _translateTimeZone(String? timeZone) {
    if (timeZone == null) return 'N/A';
    final parts = timeZone.split('/');
    if (parts.isEmpty) return timeZone;
    final region = _timeZoneTranslations[parts[0]] ?? parts[0];
    return parts.length > 1 ? '$region/${parts[1]}' : region;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String translatedDescription = _weatherTranslations[weatherData.description] ?? weatherData.description;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.wb_sunny, color: Colors.orange, size: 36),
                  const SizedBox(width: 12),
                  Text(
                    'Clima actual - ${weatherData.cityName}',
                    style: theme.textTheme.titleLarge?.copyWith(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '${weatherData.temperature}°C',
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 60, fontWeight: FontWeight.bold),
              ),
              Text(
                translatedDescription,
                style: theme.textTheme.bodySmall?.copyWith(fontSize: 22, fontWeight: FontWeight.w400),
              ),
              const SizedBox(height: 20),
              _buildInfoRow('Sensación', '${weatherData.feelsLike ?? 'N/A'}°C', Icons.thermostat, theme),
              _buildInfoRow('UV', '${weatherData.uvIndex ?? 'N/A'}', Icons.wb_sunny, theme),
              _buildInfoRow('Zona horaria', _translateTimeZone(weatherData.timeZone), Icons.access_time, theme),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildInfoColumn(Icons.water_drop, '${weatherData.humidity}%', 'Humedad', Colors.blue, theme),
                  _buildInfoColumn(Icons.air, '${weatherData.windSpeed.toStringAsFixed(1)} m/s', 'Viento', Colors.teal, theme),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: theme.iconTheme.color, size: 24),
          const SizedBox(width: 12),
          Text('$label: ', style: theme.textTheme.bodySmall?.copyWith(fontSize: 18, fontWeight: FontWeight.w500)),
          Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 18, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(IconData icon, String value, String label, Color color, ThemeData theme) {
    return Column(
      children: [
        Icon(icon, color: color, size: 36),
        const SizedBox(height: 8),
        Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: theme.textTheme.bodySmall?.copyWith(fontSize: 16, color: color.withOpacity(0.9))),
      ],
    );
  }
}

class ForecastDisplay extends StatelessWidget {
  final List<ForecastData> forecast;

  const ForecastDisplay({required this.forecast});

  static const Map<String, String> _forecastTranslations = {
    "Sunny": "Soleado",
    "Clear": "Despejado",
    "Partly Cloudy": "Parcialmente nublado",
    "Cloudy": "Nublado",
    "Overcast": "Cubierto",
    "Mist": "Neblina",
    "Patchy rain possible": "Posible lluvia irregular",
    "Patchy rain nearby": "Posible lluvia cerca",
    "Light rain": "Lluvia ligera",
    "Moderate rain": "Lluvia moderada",
    "Heavy rain": "Lluvia intensa",
    "Thunderstorm": "Tormenta eléctrica",
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.teal, size: 36),
                  const SizedBox(width: 12),
                  Text('Pronóstico', style: theme.textTheme.titleLarge?.copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              ...forecast.map((day) {
                String translatedCondition = _forecastTranslations[day.condition] ?? day.condition;
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${day.date.day}/${day.date.month}',
                          style: theme.textTheme.bodyMedium?.copyWith(fontSize: 16, fontWeight: FontWeight.w500)),
                      Text(translatedCondition, style: theme.textTheme.bodySmall?.copyWith(fontSize: 16)),
                      Text('${day.minTemp}°C - ${day.maxTemp}°C',
                          style: theme.textTheme.bodyMedium?.copyWith(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class HistoryDisplay extends StatelessWidget {
  final HistoryData history;

  const HistoryDisplay({required this.history});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.history, color: Colors.purple, size: 36),
                  const SizedBox(width: 12),
                  Text('Historial', style: theme.textTheme.titleLarge?.copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              Text('Fecha: ${history.date.day}/${history.date.month}/${history.date.year}',
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 18, fontWeight: FontWeight.w500)),
              Text('Temp. promedio: ${history.avgTemp}°C',
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 18, fontWeight: FontWeight.w500)),
              Text('Precipitación: ${history.precipitation} mm',
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 18, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}

class AlertsDisplay extends StatefulWidget {
  final List<AlertData> alerts;

  const AlertsDisplay({required this.alerts, super.key});

  @override
  _AlertsDisplayState createState() => _AlertsDisplayState();
}

class _AlertsDisplayState extends State<AlertsDisplay> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: GestureDetector(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.8),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning, color: Colors.white, size: 36),
                        const SizedBox(width: 12),
                        Text(
                          'Alertas',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.white,
                      size: 24,
                    ),
                  ],
                ),
                if (_isExpanded) ...[
                  const SizedBox(height: 12),
                  ...widget.alerts.map((alert) => Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alert.headline,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${alert.severity} - ${alert.description}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
class AstronomyDisplay extends StatelessWidget {
  final AstronomyData astronomy;

  const AstronomyDisplay({required this.astronomy});

  static const Map<String, String> _moonPhaseTranslations = {
    "New Moon": "Luna nueva",
    "Waxing Crescent": "Creciente",
    "First Quarter": "Cuarto creciente",
    "Waxing Gibbous": "Gibosa creciente",
    "Full Moon": "Luna llena",
    "Waning Gibbous": "Gibosa menguante",
    "Last Quarter": "Cuarto menguante",
    "Waning Crescent": "Creciente menguante",
  };

  String _convertTime(String timeStr) {
    try {
      final inputFormat = DateFormat.jm();
      final outputFormat = DateFormat.Hm();
      final time = inputFormat.parse(timeStr);
      return outputFormat.format(time);
    } catch (e) {
      return timeStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String translatedMoonPhase = _moonPhaseTranslations[astronomy.moonPhase] ?? astronomy.moonPhase;
    final String convertedSunrise = _convertTime(astronomy.sunrise);
    final String convertedSunset = _convertTime(astronomy.sunset);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.nightlight_round, color: Colors.indigo, size: 36),
                  const SizedBox(width: 12),
                  Text('Astronomía', style: theme.textTheme.titleLarge?.copyWith(fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              Text('Amanecer: $convertedSunrise',
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 18, fontWeight: FontWeight.w500)),
              Text('Atardecer: $convertedSunset',
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 18, fontWeight: FontWeight.w500)),
              Text('Fase lunar: $translatedMoonPhase',
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 18, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}

class SearchResultsDisplay extends StatelessWidget {
  final List<SearchResult> searchResults;

  const SearchResultsDisplay({required this.searchResults});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.search, color: Colors.green, size: 36),
                  const SizedBox(width: 12),
                  Text('Resultados de búsqueda',
                      style: theme.textTheme.titleLarge?.copyWith(fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              ...searchResults.map((result) => Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(result.name,
                        style: theme.textTheme.bodyMedium?.copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('${result.region}, ${result.country}',
                        style: theme.textTheme.bodySmall?.copyWith(fontSize: 16)),
                  ],
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}

class AirQualityDisplay extends StatelessWidget {
  final AirQualityData airQuality;

  const AirQualityDisplay({required this.airQuality});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.cloud, color: Colors.cyan, size: 36),
                  const SizedBox(width: 12),
                  Text('Calidad del aire',
                      style: theme.textTheme.titleLarge?.copyWith(fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              Text('Índice AQI: ${airQuality.aqi}',
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 18, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}

class FutureDisplay extends StatelessWidget {
  final FutureData futureWeather;

  const FutureDisplay({required this.futureWeather});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.event, color: Colors.deepOrange, size: 36),
                  const SizedBox(width: 12),
                  Text('Clima futuro',
                      style: theme.textTheme.titleLarge?.copyWith(fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              Text('Fecha: ${futureWeather.date.day}/${futureWeather.date.month}/${futureWeather.date.year}',
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 18, fontWeight: FontWeight.w500)),
              Text('Temp. promedio: ${futureWeather.avgTemp}°C',
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 18, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:weatherapp/services/weather_service.dart';
import 'package:weatherapp/screens/weather_model.dart';
import 'package:weatherapp/screens/weather_view.dart';
import 'package:weatherapp/services/weather_radar_page.dart';
import '../effects/rain_effect.dart';
import '../effects/sunny_effect.dart';
import '../effects/thunderstorm_effect.dart';
import 'dart:ui';
import '../services/favoritesManager.dart';

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({super.key});

  @override
  _WeatherHomePageState createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  final WeatherService _weatherService = WeatherService();
  final FavoritesManager _favoritesManager = FavoritesManager();
  WeatherData? _currentWeather;
  List<ForecastData>? _forecast;
  HistoryData? _history;
  List<AlertData>? _alerts;
  AstronomyData? _astronomy;
  List<SearchResult>? _searchResults;
  AirQualityData? _airQuality;
  FutureData? _futureWeather;
  List<String> _favoriteLocations = [];
  final TextEditingController _cityController = TextEditingController();
  bool _isLoading = false;
  bool _isDarkMode = false;
  late PageController _pageController;
  int _currentFavoriteIndex = 0;
  final String _initialCity = "Lleida";

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _getAllWeatherData(_initialCity);
    _loadFavorites();
  }

  @override
  void dispose() {
    _cityController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    final favorites = await _favoritesManager.getFavoriteLocations();
    setState(() {
      _favoriteLocations = favorites;
      List<String> allLocations = [_initialCity, ..._favoriteLocations.where((loc) => loc != _initialCity)];
      if (_currentWeather != null) {
        _currentFavoriteIndex = allLocations.indexOf(_currentWeather!.cityName);
        if (_currentFavoriteIndex == -1) _currentFavoriteIndex = 0;
        _pageController.jumpToPage(_currentFavoriteIndex);
      }
    });
  }

  Future<void> _toggleFavorite(String location) async {
    final isFavorite = await _favoritesManager.isFavorite(location);
    if (isFavorite) {
      await _favoritesManager.removeFavoriteLocation(location);
    } else {
      await _favoritesManager.addFavoriteLocation(location);
    }
    await _loadFavorites();
  }

  Future<void> _getAllWeatherData(String query) async {
    if (query.isEmpty) return;
    setState(() => _isLoading = true);

    try {
      final today = DateTime.now();
      final historyDate = today.subtract(Duration(days: 3)).toIso8601String().split('T')[0];
      final astronomyDate = today.toIso8601String().split('T')[0];

      final current = await _weatherService.getCurrentWeather(query);
      final forecast = await _weatherService.getForecast(query, 3);
      final history = await _weatherService.getHistory(query, historyDate);
      final alerts = await _weatherService.getAlerts(query);
      final astronomy = await _weatherService.getAstronomy(query, astronomyDate);
      final airQuality = await _weatherService.getAirQuality(query);

      setState(() {
        _currentWeather = current;
        _forecast = forecast.cast<ForecastData>();
        _history = history;
        _alerts = alerts.cast<AlertData>();
        _astronomy = astronomy;
        _airQuality = airQuality;
        _futureWeather = null;
        _isLoading = false;
        List<String> allLocations = [_initialCity, ..._favoriteLocations.where((loc) => loc != _initialCity)];
        _currentFavoriteIndex = allLocations.indexOf(query);
        if (_currentFavoriteIndex != -1) {
          _pageController.jumpToPage(_currentFavoriteIndex);
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError(e.toString());
    }
  }

  Future<void> _searchLocations(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = null);
      return;
    }

    try {
      final results = await _weatherService.searchLocation(query);
      setState(() {
        _searchResults = results.cast<SearchResult>();
      });
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $message')),
    );
  }

  void _toggleDarkMode() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  void _onFavoritesChanged() {
    _loadFavorites();
  }

  void _onPageChanged(int index) {
    List<String> allLocations = [_initialCity, ..._favoriteLocations.where((loc) => loc != _initialCity)];
    if (allLocations.isNotEmpty && index != _currentFavoriteIndex) {
      setState(() {
        _currentFavoriteIndex = index;
      });
      _getAllWeatherData(allLocations[index]);
    }
  }

  bool _isRainyWeather() {
    if (_currentWeather == null) return false;
    final description = _currentWeather!.description.toLowerCase();
    return description.contains('rain') || description.contains('lluvia');
  }

  bool _isSunnyWeather() {
    if (_currentWeather == null) return false;
    final description = _currentWeather!.description.toLowerCase();
    return description.contains('sunny') ||
        description.contains('soleado') ||
        description.contains('despejado') ||
        description.contains('clear');
  }

  bool _isCloudyWeather() {
    if (_currentWeather == null) return false;
    final description = _currentWeather!.description.toLowerCase();
    return description.contains('cloudy') || description.contains('nublado');
  }

  bool _isThunderstormWeather() {
    if (_currentWeather == null) return false;
    final description = _currentWeather!.description.toLowerCase();
    return description.contains('thunderstorm') ||
        description.contains('tormenta eléctrica');
  }

  LinearGradient _getBackgroundGradient() {
    if (_isSunnyWeather()) {
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.yellow[200]!, Colors.blue[100]!],
      );
    } else if (_isRainyWeather() || _isThunderstormWeather()) {
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.grey[600]!, Colors.blueGrey[900]!],
      );
    } else if (_isCloudyWeather()) {
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.grey[400]!, Colors.grey[700]!],
      );
    }
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.blue[100]!, Colors.blue[300]!],
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> allLocations = [_initialCity, ..._favoriteLocations.where((loc) => loc != _initialCity)];

    return MaterialApp(
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.transparent,
        cardTheme: CardTheme(
          color: Colors.white.withOpacity(0.3),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          clipBehavior: Clip.antiAlias,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
          bodySmall: TextStyle(color: Colors.black54),
          titleLarge: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.blueGrey),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue.shade800.withOpacity(0.8),
          foregroundColor: Colors.white,
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        cardTheme: CardTheme(
          color: Colors.grey[800]!.withOpacity(0.95),
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
          bodySmall: TextStyle(color: Colors.white70),
          titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue[900],
          foregroundColor: Colors.white,
        ),
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: _isDarkMode ? Colors.black : null,
                gradient: !_isDarkMode ? _getBackgroundGradient() : null,
              ),
            ),
            if (!_isDarkMode) ...[
              if (_isRainyWeather() && !_isThunderstormWeather())
                IgnorePointer(child: Positioned.fill(child: RainEffect())),
              if (_isSunnyWeather())
                IgnorePointer(child: Positioned.fill(child: SunnyEffect())),
              if (_isCloudyWeather())
                IgnorePointer(child: Positioned.fill(child: StaticCloudEffect())),
              if (_isThunderstormWeather())
                IgnorePointer(child: Positioned.fill(child: ThunderstormEffect())),
            ],
            Column(
              children: [
                AppBar(
                  title: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.cloud_circle, size: 32),
                      const SizedBox(width: 8),
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [Colors.white, Colors.yellow.shade200],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: const Text(
                          'Weather App',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Roboto',
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                offset: Offset(2, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  centerTitle: true,
                  elevation: 4,
                  backgroundColor: _isDarkMode ? Colors.blue[900] : Colors.blue.shade800.withOpacity(0.8),
                  actions: [
                    IconButton(
                      icon: FutureBuilder<bool>(
                        future: _currentWeather != null
                            ? _favoritesManager.isFavorite(_currentWeather!.cityName)
                            : Future.value(false),
                        builder: (context, snapshot) {
                          return Icon(
                            snapshot.data == true ? Icons.star : Icons.star_border,
                          );
                        },
                      ),
                      tooltip: 'Agregar a favoritas',
                      onPressed: () {
                        if (_currentWeather != null) {
                          _toggleFavorite(_currentWeather!.cityName);
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        showSearch(
                          context: context,
                          delegate: _WeatherSearchDelegate(
                            _weatherService,
                            _getAllWeatherData,
                            _favoritesManager,
                            onFavoritesChanged: _onFavoritesChanged,
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        _isDarkMode ? Icons.wb_sunny : Icons.nightlight_round,
                      ),
                      onPressed: _toggleDarkMode,
                      tooltip: _isDarkMode ? 'Modo Claro' : 'Modo Oscuro',
                    ),
                  ],
                ),
                if (allLocations.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18.0),
                    child: PageIndicator(
                      count: allLocations.length,
                      currentIndex: _currentFavoriteIndex,
                      isDarkMode: _isDarkMode,
                    ),
                  ),
                Expanded(
                  child: allLocations.isEmpty
                      ? const Center(child: Text('No hay ciudades disponibles'))
                      : PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: allLocations.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 0.5),
                        child: WeatherView(
                          isLoading: _isLoading,
                          currentWeather: _currentWeather,
                          forecast: _forecast,
                          history: _history,
                          alerts: _alerts,
                          astronomy: _astronomy,
                          searchResults: _searchResults,
                          airQuality: _airQuality,
                          futureWeather: _futureWeather,
                          cityController: _cityController,
                          onSearch: () => _getAllWeatherData(_cityController.text),
                          onSearchTyping: _searchLocations,
                          weatherData: _currentWeather,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WeatherRadarPage()),
            );
          },
          backgroundColor: Colors.blue[800], // Cambia el color de fondo
          foregroundColor: Colors.white, // Cambia el color del ícono
          tooltip: 'Radar',
          child: const Icon(Icons.radar_sharp), // Cambia el ícono
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}

class PageIndicator extends StatelessWidget {
  final int count;
  final int currentIndex;
  final bool isDarkMode;

  const PageIndicator({
    super.key,
    required this.count,
    required this.currentIndex,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          width: index == currentIndex ? 12.0 : 8.0,
          height: index == currentIndex ? 12.0 : 8.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index == currentIndex
                ? (isDarkMode ? Colors.white : Colors.blue.shade800)
                : (isDarkMode ? Colors.grey[600] : Colors.grey[400]),
          ),
        );
      }),
    );
  }
}

class _WeatherSearchDelegate extends SearchDelegate {
  final WeatherService _weatherService;
  final Function(String) onSearch;
  final FavoritesManager _favoritesManager;
  final VoidCallback? onFavoritesChanged;

  _WeatherSearchDelegate(
      this._weatherService,
      this.onSearch,
      this._favoritesManager, {
        this.onFavoritesChanged,
      });

  @override
  String get searchFieldLabel => 'Buscar ciudad';

  String normalizeText(String text) {
    return text
        .toLowerCase()
        .replaceAll('ñ', 'n')
        .replaceAll('à', 'a')
        .replaceAll('á', 'a')
        .replaceAll('â', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('ä', 'a')
        .replaceAll('ç', 'c')
        .replaceAll('è', 'e')
        .replaceAll('é', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('ë', 'e')
        .replaceAll('ì', 'i')
        .replaceAll('í', 'i')
        .replaceAll('î', 'i')
        .replaceAll('ï', 'i')
        .replaceAll('ò', 'o')
        .replaceAll('ó', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ö', 'o')
        .replaceAll('ù', 'u')
        .replaceAll('ú', 'u')
        .replaceAll('û', 'u')
        .replaceAll('ü', 'u');
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return ThemeData(
      appBarTheme: AppBarTheme(
        backgroundColor: isDarkMode ? Colors.blue[900] : Colors.blue.shade800,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Roboto',
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDarkMode ? Colors.blueGrey[800] : Colors.blue[100],
        hintStyle: TextStyle(color: isDarkMode ? Colors.blueGrey[300] : Colors.blueGrey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      scaffoldBackgroundColor: isDarkMode ? Colors.blueGrey[900] : Colors.blue[50],
    );
  }

  @override
  Widget buildSearchField(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return TextField(
      onChanged: (value) {
        query = value;
      },
      style: TextStyle(color: isDarkMode ? Colors.white : Colors.blueGrey[900], fontFamily: 'Roboto'),
      decoration: InputDecoration(
        hintText: searchFieldLabel,
        prefixIcon: Icon(Icons.search, color: isDarkMode ? Colors.blueGrey[300] : Colors.blueGrey[600]),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final normalizedQuery = normalizeText(query);

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: query.isEmpty
          ? FutureBuilder<List<String>>(
        future: _favoritesManager.getFavoriteLocations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: isDarkMode ? Colors.blueGrey[300] : Colors.blue[700],
              ),
            );
          }

          final favorites = snapshot.data ?? [];
          if (favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.star_border,
                    size: 48,
                    color: isDarkMode ? Colors.blueGrey[300] : Colors.blueGrey[600],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No favorites yet",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Roboto',
                      color: isDarkMode ? Colors.blueGrey[200] : Colors.blueGrey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Add cities from the main screen",
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.blueGrey[400] : Colors.blueGrey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final location = favorites[index];
              return FutureBuilder<WeatherData>(
                future: _weatherService.getCurrentWeather(location),
                builder: (context, weatherSnapshot) {
                  if (weatherSnapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (!weatherSnapshot.hasData) {
                    return const SizedBox.shrink();
                  }

                  final weather = weatherSnapshot.data!;
                  IconData weatherIcon;
                  Color accentColor;

                  if (weather.description.toLowerCase().contains('sunny') ||
                      weather.description.toLowerCase().contains('soleado') ||
                      weather.description.toLowerCase().contains('clear') ||
                      weather.description.toLowerCase().contains('despejado')) {
                    weatherIcon = Icons.wb_sunny;
                    accentColor = Colors.yellow[700]!;
                  } else if (weather.description.toLowerCase().contains('rain') ||
                      weather.description.toLowerCase().contains('lluvia')) {
                    weatherIcon = Icons.water_drop;
                    accentColor = Colors.blue[700]!;
                  } else if (weather.description.toLowerCase().contains('cloudy') ||
                      weather.description.toLowerCase().contains('nublado')) {
                    weatherIcon = Icons.cloud;
                    accentColor = Colors.blueGrey[600]!;
                  } else if (weather.description.toLowerCase().contains('thunderstorm') ||
                      weather.description.toLowerCase().contains('tormenta')) {
                    weatherIcon = Icons.flash_on;
                    accentColor = Colors.blue[900]!;
                  } else {
                    weatherIcon = Icons.wb_cloudy;
                    accentColor = Colors.blueGrey[700]!;
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        onSearch(location);
                        close(context, null);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.blueGrey[700] : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: accentColor.withOpacity(0.1),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  bottomLeft: Radius.circular(12),
                                ),
                              ),
                              child: Icon(
                                weatherIcon,
                                size: 32,
                                color: accentColor,
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      location,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Roboto',
                                        color: isDarkMode ? Colors.white : Colors.blueGrey[900],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          '${weather.temperature.toStringAsFixed(1)}°C',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: isDarkMode ? Colors.blueGrey[200] : Colors.blueGrey[800],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Sen: ${weather.feelsLike?.toStringAsFixed(1)}°C',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: isDarkMode ? Colors.blueGrey[400] : Colors.blueGrey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.close,
                                size: 24,
                                color: isDarkMode ? Colors.blueGrey[300] : Colors.blueGrey[600],
                              ),
                              onPressed: () async {
                                await _favoritesManager.removeFavoriteLocation(location);
                                onFavoritesChanged?.call();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      )
          : FutureBuilder<List<SearchResult>>(
        future: _weatherService.searchLocation(query),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: isDarkMode ? Colors.blueGrey[300] : Colors.blue[700],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 48,
                    color: isDarkMode ? Colors.blueGrey[300] : Colors.blueGrey[600],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No results found",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Roboto',
                      color: isDarkMode ? Colors.blueGrey[200] : Colors.blueGrey[800],
                    ),
                  ),
                ],
              ),
            );
          }

          final locations = snapshot.data!;
          final filteredLocations = locations.where((location) {
            final normalizedCityName = normalizeText(location.name);
            return normalizedCityName.contains(normalizedQuery);
          }).toList();

          return ListView.builder(
            itemCount: filteredLocations.length,
            itemBuilder: (context, index) {
              final location = filteredLocations[index];
              return FutureBuilder<bool>(
                future: _favoritesManager.isFavorite(location.name),
                builder: (context, favSnapshot) {
                  if (favSnapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: GestureDetector(
                      onTap: () {
                        onSearch(location.name);
                        close(context, null);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.blueGrey[700] : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          title: Text(
                            location.name,
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: isDarkMode ? Colors.white : Colors.blueGrey[900],
                            ),
                          ),
                          subtitle: Text(
                            '${location.region}, ${location.country}',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDarkMode ? Colors.blueGrey[400] : Colors.blueGrey[600],
                            ),
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              favSnapshot.data == true ? Icons.star : Icons.star_border,
                              color: isDarkMode ? Colors.blue[300] : Colors.blue[700],
                            ),
                            onPressed: () async {
                              if (favSnapshot.data == true) {
                                await _favoritesManager.removeFavoriteLocation(location.name);
                              } else {
                                await _favoritesManager.addFavoriteLocation(location.name);
                              }
                              onFavoritesChanged?.call();
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class StaticCloudEffect extends StatelessWidget {
  const StaticCloudEffect({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: StaticCloudPainter(),
      size: Size.infinite,
    );
  }
}

class StaticCloudPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12.0);

    const cloudPositions = [
      Offset(100, 100),
      Offset(300, 150),
      Offset(500, 120),
      Offset(200, 300),
      Offset(400, 350),
    ];

    for (int i = 0; i < cloudPositions.length; i++) {
      final offset = cloudPositions[i];
      final cloudSize = 80.0 + i * 20;

      final basePaint = Paint()
        ..color = Colors.grey[600]!.withOpacity(0.5)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12.0);
      canvas.drawCircle(offset, cloudSize, basePaint);

      final highlightPaint = Paint()
        ..color = Colors.grey[400]!.withOpacity(0.3)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0);
      canvas.drawCircle(
        Offset(offset.dx - 5, offset.dy - 5),
        cloudSize * 0.8,
        highlightPaint,
      );

      final shadowPaint = Paint()
        ..color = Colors.grey[800]!.withOpacity(0.25)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12.0);
      canvas.drawCircle(
        Offset(offset.dx + 5, offset.dy + 5),
        cloudSize * 0.9,
        shadowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
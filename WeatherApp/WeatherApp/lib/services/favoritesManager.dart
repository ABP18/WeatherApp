import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weatherapp/services/notification_service.dart';

class FavoritesManager {
  static const String _favoritesKey = 'favorite_locations';

  Future<List<String>> getFavoriteLocations() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getString(_favoritesKey);
    if (favoritesJson != null) {
      return List<String>.from(jsonDecode(favoritesJson));
    }
    return [];
  }

  Future<void> addFavoriteLocation(String location) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavoriteLocations();
    if (!favorites.contains(location)) {
      favorites.add(location);
      await prefs.setString(_favoritesKey, jsonEncode(favorites));
      // Show notification when city is added to favorites
      await NotificationService().showNotification(location);
    }
  }

  Future<void> removeFavoriteLocation(String location) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavoriteLocations();
    if (favorites.contains(location)) {
      favorites.remove(location);
      await prefs.setString(_favoritesKey, jsonEncode(favorites));
    }
  }

  Future<bool> isFavorite(String location) async {
    final favorites = await getFavoriteLocations();
    return favorites.contains(location);
  }
}
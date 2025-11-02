import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class FavoritesProvider with ChangeNotifier {
  late Box _favoritesBox;
  List<String> _favoriteKeys = []; // Store only the keys (botanical names)

  // Getter for the favorite keys
  List<String> get favoriteKeys => _favoriteKeys;

  FavoritesProvider() {
    _init(); // Initialize Hive box and load initial keys
  }

  // Initialize and load keys
  Future<void> _init() async {
    _favoritesBox = Hive.box('favorites');
    _loadFavoriteKeys();
   
    _favoritesBox.listenable().addListener(_loadFavoriteKeys);
  }

  // Load keys from the Hive box
  void _loadFavoriteKeys() {
    _favoriteKeys = _favoritesBox.keys.cast<String>().toList();
    notifyListeners(); // Notify UI when keys change
  }

  // Check if a plant is a favorite
  bool isFavorite(String botanicalName) {
    return _favoritesBox.containsKey(botanicalName);
    // Or you could check: _favoriteKeys.contains(botanicalName);
  }

  // Toggle favorite status
  Future<void> toggleFavorite(String botanicalName, String commonName) async {
    if (_favoritesBox.containsKey(botanicalName)) {
      await _favoritesBox.delete(botanicalName);
      // SnackBar logic can be moved to the UI calling this method
    } else {
      // Store common name as value, just like before
      await _favoritesBox.put(botanicalName, commonName);
      // SnackBar logic can be moved to the UI calling this method
    }
  }

 }
}


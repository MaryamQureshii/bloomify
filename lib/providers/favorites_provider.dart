import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
// Note: We don't import PlantProvider here directly to avoid tight coupling.
// We'll look up plants using the PlantProvider instance available via context.

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
    // Listen for changes in the Hive box to automatically update the UI
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
    // No need to call _loadFavoriteKeys or notifyListeners here,
    // because the Hive listener in _init() will automatically do it.
  }

  // Optional: Override dispose to remove the listener if needed,
  // though for long-lived providers it might not be strictly necessary.
  // @override
  // void dispose() {
  //   _favoritesBox.listenable().removeListener(_loadFavoriteKeys);
  //   super.dispose();
  // }
}

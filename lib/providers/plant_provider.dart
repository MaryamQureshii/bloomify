import 'dart:convert';
import 'package:flutter/foundation.dart'; // Import ChangeNotifier
import 'package:flutter/services.dart' show rootBundle;
import '../plant_model.dart'; // Adjust import path if needed

class PlantProvider with ChangeNotifier {
  List<Plant> _allPlants = [];
  List<Plant> _filteredPlants = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';
  String _searchQuery = '';

  // Getters to access the state from UI
  List<Plant> get allPlants => _allPlants;
  List<Plant> get filteredPlants => _filteredPlants;
  bool get isLoading => _isLoading;
  String get selectedFilter => _selectedFilter;
  String get searchQuery => _searchQuery;

  PlantProvider() {
    loadPlants(); // Load plants when the provider is created
  }

  // Method to load plant data from JSON
  Future<void> loadPlants() async {
    _isLoading = true;
    notifyListeners(); // Notify UI about loading start

    try {
      final String jsonString =
          await rootBundle.loadString('assets/house_plants.json');
      final List<dynamic> data = await json.decode(jsonString);

      // Using the corrected Plant.fromJson logic
      _allPlants = data.map((json) => Plant.fromJson(json)).toList();
      // Initially, filtered list is all plants (apply filter later if needed)
      _filterPlants(); // Apply initial filter/search if any
    } catch (e) {
      debugPrint("Error loading plant data in Provider: $e");
      _allPlants = []; // Set empty list on error
      _filteredPlants = [];
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify UI that loading is finished (success or error)
    }
  }

  // Method to update the search query
  void updateSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    _filterPlants(); // Re-apply filters when search changes
  }

  // Method to update the selected filter chip
  void updateFilter(String filter) {
    _selectedFilter = filter;
    _filterPlants(); // Re-apply filters when filter chip changes
  }

  // Internal method to perform the actual filtering
  void _filterPlants() {
    _filteredPlants = _allPlants.where((plant) {
      final nameMatches = plant.commonName.toLowerCase().contains(_searchQuery);
      final filterMatches = _selectedFilter == 'All' ||
          (_selectedFilter == 'Indoor' && plant.isIndoor()) ||
          (_selectedFilter == 'Outdoor' && !plant.isIndoor());
      return nameMatches && filterMatches;
    }).toList();

    notifyListeners(); // Notify UI about the updated filtered list
  }

  // Helper method to find a specific plant by botanical name
  // Useful for the Favorites screen
  Plant? findPlantByBotanicalName(String botanicalName) {
    try {
      return _allPlants
          .firstWhere((plant) => plant.botanicalName == botanicalName);
    } catch (e) {
      // Plant not found in the current list
      debugPrint("Plant with botanical name $botanicalName not found.");
      return null;
    }
  }
}

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:hive_flutter/hive_flutter.dart';
import 'plant_model.dart';
import 'plant_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Plant> _allPlants = [];
  List<Plant> _filteredPlants = []; 
  bool _isLoading = true;
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();
  late Box _favoritesBox; 

  @override
  void initState() {
    super.initState();
    _favoritesBox = Hive.box('favorites'); 
    _loadPlantData();
    _searchController.addListener(_filterPlants);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterPlants);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPlantData() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/house_plants.json');
      final List<dynamic> data = await json.decode(jsonString);

      setState(() {
        _allPlants = data.map((json) => Plant.fromJson(json)).toList().take(6).toList();
        _filteredPlants = _allPlants;
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading plant data: $e");
      setState(() {
        _isLoading = false;

      });
    }
  }

  void _filterPlants() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredPlants = _allPlants.where((plant) {
        final nameMatches = plant.commonName.toLowerCase().contains(query);
        final filterMatches = _selectedFilter == 'All' ||
            (_selectedFilter == 'Indoor' && plant.isIndoor()) ||
            (_selectedFilter == 'Outdoor' && !plant.isIndoor());
        return nameMatches && filterMatches;
      }).toList();
    });
  }

  void _updateFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    _filterPlants();
  }
  void _toggleFavorite(Plant plant) {
    setState(() {
      if (_favoritesBox.containsKey(plant.botanicalName)) {
        _favoritesBox.delete(plant.botanicalName);
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Removed from Favorites'), duration: Duration(seconds: 1)),
        );
      } else {
        _favoritesBox.put(plant.botanicalName, plant.commonName);
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Added to Favorites'), duration: Duration(seconds: 1)),
        );
      }
    });
  }
  bool _isFavorite(Plant plant) {
    return _favoritesBox.containsKey(plant.botanicalName);
  }

  void _showPlantDetails(BuildContext context, Plant plant) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return PlantDetailScreen(plant: plant);
      },
    ).then((_) {
      setState(() {});
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/logo.png', height: 30),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildSearchBar(),
                _buildFilterChips(),
                Expanded(
                  // Handle case where no plants match filter/search
                  child: _filteredPlants.isEmpty
                      ? const Center(child: Text("No plants found."))
                      : _buildPlantGrid(),
                ),
              ],
            ),
    );
  }

  Widget _buildSearchBar() {
     return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: IconButton(
            icon: Icon(Icons.filter_list, color: Theme.of(context).colorScheme.primary),
            onPressed: () {},
          ),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

 Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildChoiceChip('Indoor Plants', 'Indoor'),
          const SizedBox(width: 8),
          _buildChoiceChip('Outdoor Plants', 'Outdoor'),
           const SizedBox(width: 8),
          _buildChoiceChip('All', 'All'),
        ],
      ),
    );
  }

   Widget _buildChoiceChip(String label, String filterValue) {
    final bool isSelected = _selectedFilter == filterValue;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          _updateFilter(filterValue);
        }
      },
      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      labelStyle: TextStyle(
        color: isSelected ? Theme.of(context).colorScheme.primary : Colors.black54,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
        side: BorderSide(
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[300]!,
        )
      ),
      backgroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
    );
  }


  Widget _buildPlantGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 0.7,
      ),
      itemCount: _filteredPlants.length,
      itemBuilder: (context, index) {
        final plant = _filteredPlants[index];
        final isFavorite = _isFavorite(plant); 

        return Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: InkWell(
                   onTap: () => _showPlantDetails(context, plant),

                  child: Image.asset( 
                    plant.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      debugPrint("Error loading asset: ${plant.imageUrl} - $error"); 
                      return  Text("Error loading asset: ${plant.imageUrl} - $error") ;
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plant.commonName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      plant.isIndoor() ? 'Indoor Plant' : 'Outdoor Plant',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _showPlantDetails(context, plant),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Explore',
                              style: TextStyle(fontSize: 12, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            size: 20
                          ),
                          color: isFavorite ? Theme.of(context).colorScheme.primary : Colors.grey,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => _toggleFavorite(plant),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


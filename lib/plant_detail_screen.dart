import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'plant_model.dart';

// --- Already Correctly StatefulWidget ---
class PlantDetailScreen extends StatefulWidget {
  final Plant plant;
  const PlantDetailScreen({super.key, required this.plant});

  @override
  State<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends State<PlantDetailScreen> {
  late Box _favoritesBox;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _favoritesBox = Hive.box('favorites');
    _checkIfFavorite();
  }

  void _checkIfFavorite() {
    if (mounted) {
      setState(() {
        _isFavorite = _favoritesBox.containsKey(widget.plant.botanicalName);
      });
    }
  }

  void _toggleFavorite() {
    if (mounted) {
      setState(() {
        final key = widget.plant.botanicalName;
        if (_isFavorite) {
          _favoritesBox.delete(key);
          _isFavorite = false;
          ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Removed from Favorites'), duration: Duration(seconds: 1)),
          );
        } else {
          _favoritesBox.put(key, widget.plant.commonName);
          _isFavorite = true;
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Added to Favorites'), duration: Duration(seconds: 1)),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: ListView(
            controller: controller,
            children: [
              _buildHeader(context),
              _buildBody(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          // --- FIX: Use Image.asset ---
          child: Image.asset( // Changed from Image.network
            widget.plant.imageUrl, // Access plant via widget property
            width: double.infinity,
            height: 300,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Log the specific error for this asset
              print("Detail Screen - Error loading asset: ${widget.plant.imageUrl} - $error");
              return Container(height: 300, color: Colors.grey[200], child: const Icon(Icons.local_florist, size: 100, color: Colors.grey));
            }
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: CircleAvatar(
            backgroundColor: Colors.black.withOpacity(0.4),
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
              tooltip: 'Close',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    // ... (Rest of _buildBody remains the same as previous correct version) ...
     return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start, // Align top
            children: [
              Expanded(
                child: Text(
                  widget.plant.commonName, // Access plant data via widget.plant
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  // softWrap: true, // Allow wrapping if needed
                ),
              ),
              IconButton( // Favorite button logic
                icon: Icon(
                  // Show filled heart if favorite, outline otherwise
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  // Use theme color when favorited
                  color: _isFavorite ? Theme.of(context).colorScheme.primary : Colors.grey,
                  size: 30,
                ),
                tooltip: _isFavorite ? 'Remove Favorite' : 'Add Favorite',
                onPressed: _toggleFavorite, // Call function on tap
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.plant.isIndoor() ? 'Indoor Plant' : 'Outdoor Plant', // Access via widget.plant
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
          const SizedBox(height: 24),
          Text(
            widget.plant.description, // Access via widget.plant
            style: TextStyle(fontSize: 16, height: 1.5, color: Colors.grey[800]),
          ),
          const SizedBox(height: 24),
          _buildInfoRow(Icons.wb_sunny_outlined, 'Light', widget.plant.light), // Access via widget.plant
          const SizedBox(height: 16),
          _buildInfoRow(Icons.water_drop_outlined, 'Watering', widget.plant.watering), // Access via widget.plant
          const SizedBox(height: 16),
          _buildInfoRow(Icons.warning_amber_rounded, 'Toxicity', widget.plant.toxicity), // Access via widget.plant
          const SizedBox(height: 32),
          // "Add to Collection" button is REMOVED
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String subtitle) {
      // Using Row layout
      return Row(
      crossAxisAlignment: CrossAxisAlignment.start, // Align icon and text top
      children: [
        Icon(icon, color: Colors.grey[600], size: 28),
        const SizedBox(width: 16), // Spacing
        // Use Expanded to allow text to wrap if it's long
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Align text left
            children: [
              // Title text (e.g., "Light")
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4), // Spacing
              // Subtitle text (e.g., "Bright light")
              Text(
                  subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  // softWrap: true, // Allow wrapping
                ),
            ],
          ),
        ),
      ],
    );
  }
}
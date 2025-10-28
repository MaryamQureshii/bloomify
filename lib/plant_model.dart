class Plant {
  final String commonName;
  final String botanicalName;
  final String description;
  final String light;
  final String watering;
  final String toxicity;
  final String careDifficulty;
  final String imageUrl; 
  const Plant({
    required this.commonName,
    required this.botanicalName,
    required this.description,
    required this.light,
    required this.watering,
    required this.toxicity,
    required this.careDifficulty,
    required this.imageUrl,
  });

  factory Plant.fromJson(Map<String, dynamic> json) {
    String getCommonName(dynamic commonValue) {
      if (commonValue is List && commonValue.isNotEmpty) {
        return commonValue[0] as String? ?? 'Unknown';
      } else if (commonValue is String) {
        return commonValue;
      }
      return 'Unknown';
    }

   String imagePathFromJson = json['imagePath'] ?? 'assets/placeholder_plant.webp';


    if (imagePathFromJson.startsWith(' ')) {
        imagePathFromJson = imagePathFromJson.trim();
    }


    return Plant(
      commonName: getCommonName(json['common']),
      botanicalName: json['latin'] ?? 'Unknown',
      description: 'Care details and description coming soon.', 
      light: json['ideallight'] ?? 'Unknown',
      watering: json['watering'] ?? 'Unknown',
      toxicity: 'Info unavailable', 
      careDifficulty: 'Moderate', 
      imageUrl: imagePathFromJson,
    );
  } 

  bool isIndoor() {
    final lightLower = light.toLowerCase();
    return lightLower.contains('indoor') ||
           lightLower.contains('indirect') ||
           lightLower.contains('diffused') ||
           lightLower.contains('bright light');
  }
} 


class Landmark {
  final int? id;
  final String title;
  final double lat;
  final double lon;
  final String image;
  final bool isSynced;
  final DateTime timestamp;

  Landmark({
    this.id,
    required this.title,
    required this.lat,
    required this.lon,
    required this.image,
    this.isSynced = true,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  // Helper method to safely parse double from dynamic value
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  // Helper method to safely parse string
  static String _parseString(dynamic value, String defaultValue) {
    if (value == null) return defaultValue;
    if (value is String) return value;
    return value.toString();
  }

  // Convert to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'lat': lat,
      'lon': lon,
      'image': image,
      'isSynced': isSynced ? 1 : 0,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  // Create from Map (Database) - Handle both String and num types
  factory Landmark.fromMap(Map<String, dynamic> map) {
    return Landmark(
      id: map['id'] as int?,
      title: _parseString(map['title'], 'Untitled'),
      lat: _parseDouble(map['lat']),
      lon: _parseDouble(map['lon']),
      image: _parseString(map['image'], ''),
      isSynced: (map['isSynced'] as int?) == 1,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        map['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  // Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'lat': lat,
      'lon': lon,
      'image': image,
    };
  }

  // Create from JSON (API Response) - Handle both String and num types
  factory Landmark.fromJson(Map<String, dynamic> json) {
    return Landmark(
      id: json['id'] as int?,
      title: _parseString(json['title'], 'Untitled'),
      lat: _parseDouble(json['lat']),
      lon: _parseDouble(json['lon']),
      // Handle null or missing image with a placeholder
      image: _parseString(json['image'], 'https://via.placeholder.com/400x300?text=No+Image'),
    );
  }

  Landmark copyWith({
    int? id,
    String? title,
    double? lat,
    double? lon,
    String? image,
    bool? isSynced,
    DateTime? timestamp,
  }) {
    return Landmark(
      id: id ?? this.id,
      title: title ?? this.title,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      image: image ?? this.image,
      isSynced: isSynced ?? this.isSynced,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
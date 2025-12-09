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

  // Create from Map
  factory Landmark.fromMap(Map<String, dynamic> map) {
    return Landmark(
      id: map['id'] as int?,
      title: map['title'] as String,
      lat: (map['lat'] as num).toDouble(),
      lon: (map['lon'] as num).toDouble(),
      image: map['image'] as String,
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

  // Create from JSON
  factory Landmark.fromJson(Map<String, dynamic> json) {
    return Landmark(
      id: json['id'] as int?,
      title: json['title'] as String,
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      image: json['image'] as String,
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
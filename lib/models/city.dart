class City {
  final String id;
  final String name;
  final String plate;
  final double latitude;
  final double longitude;

  City({
    required this.id,
    required this.name,
    required this.plate,
    required this.latitude,
    required this.longitude,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'] as String,
      name: json['name'] as String,
      plate: json['plate'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'plate': plate,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

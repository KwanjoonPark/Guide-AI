class Location {
  final double latitude;
  final double longitude;
  final String? address;

  Location({
    required this.latitude,
    required this.longitude,
    this.address,
  });

  String toCoords() {
    return '$longitude,$latitude';
  }

  @override
  String toString() {
    return 'Location(lat: $latitude, lng: $longitude${address != null ? ', address: $address' : ''})';
  }
}
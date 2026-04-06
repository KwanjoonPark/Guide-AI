class RouteInfo {
  final int totalDistance;
  final int totalDuration;
  final int tollFare;
  final List<List<double>> path;
  final List<RouteGuide> guides;

  RouteInfo({
    required this.totalDistance,
    required this.totalDuration,
    required this.tollFare,
    required this.path,
    required this.guides,
  });

  factory RouteInfo.fromJson(Map<String, dynamic> json) {
    var summary = json['summary'];

    List<List<double>> pathList = [];
    if (json['path'] != null) {
      for (var point in json['path']) {
        pathList.add([
          (point[0] as num).toDouble(),
          (point[1] as num).toDouble(),
        ]);
      }
    }

    List<RouteGuide> guideList = [];
    if (json['guide'] != null) {
      for (var guide in json['guide']) {
        guideList.add(RouteGuide.fromJson(guide));
      }
    }

    return RouteInfo(
      totalDistance: summary['distance'] ?? 0,
      totalDuration: (summary['duration'] ?? 0) ~/ 1000,
      tollFare: summary['tollFare'] ?? 0,
      path: pathList,
      guides: guideList,
    );
  }

  int get durationInMinutes => (totalDuration / 60).ceil();
  double get distanceInKm => totalDistance / 1000.0;

  @override
  String toString() {
    return 'RouteInfo(distance: ${distanceInKm.toStringAsFixed(1)}km, '
        'duration: ${durationInMinutes}분, tollFare: ${tollFare}원, '
        'guides: ${guides.length}개)';
  }
}

class RouteGuide {
  final int pointIndex;
  final String instructions;
  final int distance;
  final int duration;

  RouteGuide({
    required this.pointIndex,
    required this.instructions,
    required this.distance,
    required this.duration,
  });

  factory RouteGuide.fromJson(Map<String, dynamic> json) {
    return RouteGuide(
      pointIndex: json['pointIndex'] ?? 0,
      instructions: json['instructions'] ?? '',
      distance: json['distance'] ?? 0,
      duration: (json['duration'] ?? 0) ~/ 1000,
    );
  }

  @override
  String toString() {
    return '${instructions} (${distance}m)';
  }
}



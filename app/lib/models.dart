class Spot {
  const Spot({
    required this.id,
    required this.name,
    required this.city,
    required this.description,
    required this.tags,
    required this.lat,
    required this.lng,
    required this.checkinRadiusM,
  });

  final String id;
  final String name;
  final String city;
  final String description;
  final List<String> tags;
  final double lat;
  final double lng;
  final int checkinRadiusM;

  factory Spot.fromJson(Map<String, dynamic> json) => Spot(
        id: json['id'] as String,
        name: json['name'] as String,
        city: json['city'] as String,
        description: json['description'] as String,
        tags: (json['tags'] as List).cast<String>(),
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
        checkinRadiusM: json['checkin_radius_m'] as int,
      );
}

class Campaign {
  const Campaign({
    required this.id,
    required this.title,
    required this.slogan,
    required this.description,
    required this.startsAt,
    required this.endsAt,
    required this.stampGoal,
    required this.reward,
    required this.spotIds,
  });

  final String id;
  final String title;
  final String slogan;
  final String description;
  final DateTime startsAt;
  final DateTime endsAt;
  final int stampGoal;
  final String reward;
  final List<String> spotIds;

  factory Campaign.fromJson(Map<String, dynamic> json) => Campaign(
        id: json['id'] as String,
        title: json['title'] as String,
        slogan: json['slogan'] as String,
        description: json['description'] as String,
        startsAt: DateTime.parse(json['starts_at'] as String),
        endsAt: DateTime.parse(json['ends_at'] as String),
        stampGoal: json['stamp_goal'] as int,
        reward: json['reward'] as String,
        spotIds: (json['spot_ids'] as List).cast<String>(),
      );
}

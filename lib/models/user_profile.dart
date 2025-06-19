// models/user_profile.dart
class UserProfile {
  double height;
  double weight;
  double proteinGoal;
  bool isMetric;
  List<String> cuisines;
  List<String> restrictions;

  UserProfile({
    this.height = 0,
    this.weight = 0,
    this.proteinGoal = 0,
    this.isMetric = true,
    this.cuisines = const [],
    this.restrictions = const [],
  });

  Map<String, dynamic> toJson() => {
    'height': height,
    'weight': weight,
    'proteinGoal': proteinGoal,
    'isMetric': isMetric,
    'cuisines': cuisines,
    'restrictions': restrictions,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    height: json['height'] ?? 0,
    weight: json['weight'] ?? 0,
    proteinGoal: json['proteinGoal'] ?? 0,
    isMetric: json['isMetric'] ?? true,
    cuisines: List<String>.from(json['cuisines'] ?? []),
    restrictions: List<String>.from(json['restrictions'] ?? []),
  );
}
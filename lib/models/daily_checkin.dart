class DailyCheckin {
  final String? id;
  final String userId;
  final DateTime date;
  final int? userMood;
  final double? sleepHours;
  final bool exercised;
  final int? waterGlasses;
  final String? createdAt;

  DailyCheckin({
    this.id,
    required this.userId,
    required this.date,
    this.userMood,
    this.sleepHours,
    this.exercised = false,
    this.waterGlasses,
    this.createdAt,
  });

  // Convert Supabase response to DailyCheckin object
  factory DailyCheckin.fromJson(Map<String, dynamic> json) {
    return DailyCheckin(
      id: json['id'],
      userId: json['user_id'],
      date: DateTime.parse(json['date']),
      userMood: json['user_mood'],
      sleepHours: json['sleep_hours']?.toDouble(),
      exercised: json['exercised'] ?? false,
      waterGlasses: json['water_glasses'],
      createdAt: json['created_at'],
    );
  }

  // Convert DailyCheckin object to Map for Supabase
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'date': date.toIso8601String().split('T')[0],
      'user_mood': userMood,
      'sleep_hours': sleepHours,
      'exercised': exercised,
      'water_glasses': waterGlasses,
    };
  }
}
class DailyCheckin {
  final String? id;
  final String userId;
  final DateTime date;
  final int? userMood;
  final double? sleepHours;
  final bool exercised;
  final int? waterGlasses;
  final String? aiMood;
  final String? aiInsight;
  final String? createdAt;

  DailyCheckin({
    this.id,
    required this.userId,
    required this.date,
    this.userMood,
    this.sleepHours,
    this.exercised = false,
    this.waterGlasses,
    this.aiMood,
    this.aiInsight,
    this.createdAt,
  });

  factory DailyCheckin.fromJson(Map<String, dynamic> json) {
    return DailyCheckin(
      id: json['id']?.toString(),
      userId: json['user_id']?.toString() ?? '',
      date: DateTime.parse(json['date']),
      userMood: json['user_mood'] != null
          ? int.parse(json['user_mood'].toString())
          : null,
      sleepHours: json['sleep_hours'] != null
          ? double.parse(json['sleep_hours'].toString())
          : null,
      exercised: json['exercised'] ?? false,
      waterGlasses: json['water_glasses'] != null
          ? int.parse(json['water_glasses'].toString())
          : null,
      aiMood: json['ai_mood']?.toString(),
      aiInsight: json['ai_insight']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'date': date.toIso8601String().split('T')[0],
      'user_mood': userMood,
      'sleep_hours': sleepHours,
      'exercised': exercised,
      'water_glasses': waterGlasses,
      if (aiMood != null) 'ai_mood': aiMood,
      if (aiInsight != null) 'ai_insight': aiInsight,
    };
  }
}
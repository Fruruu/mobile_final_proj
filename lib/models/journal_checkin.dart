class JournalEntry {
  final String? id;
  final String userId;
  final DateTime date;
  final String? journalText;
  final String? aiMood;
  final String? aiInsight;
  final String? createdAt;

  JournalEntry({
    this.id,
    required this.userId,
    required this.date,
    this.journalText,
    this.aiMood,
    this.aiInsight,
    this.createdAt,
  });

  // Convert Supabase response to JournalEntry object
  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'],
      userId: json['user_id'],
      date: DateTime.parse(json['date']),
      journalText: json['journal_text'],
      aiMood: json['ai_mood'],
      aiInsight: json['ai_insight'],
      createdAt: json['created_at'],
    );
  }

  // Convert JournalEntry object to Map for Supabase
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'date': date.toIso8601String().split('T')[0],
      'journal_text': journalText,
      'ai_mood': aiMood,
      'ai_insight': aiInsight,
    };
  }
}
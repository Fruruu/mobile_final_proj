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
      id: json['id']?.toString(),
      userId: json['user_id']?.toString() ?? '',
      date: DateTime.parse(json['date']),
      journalText: json['journal_text']?.toString(),
      aiMood: json['ai_mood']?.toString(),
      aiInsight: json['ai_insight']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }
  // Convert JournalEntry object to Map for Supabase
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'date': date.toIso8601String().split('T')[0],
      'journal_text': journalText,
      if (aiMood != null) 'ai_mood': aiMood,
      if (aiInsight != null) 'ai_insight': aiInsight,
    };
  }
}
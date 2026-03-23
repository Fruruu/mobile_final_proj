import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ClaudeService {
  final String _apiKey = dotenv.env['CLAUDE_API_KEY']!;
  final String _apiUrl = 'https://api.anthropic.com/v1/messages';

  // ANALYZE WITH JOURNAL + CHECK-IN + WEEK (FULL RAG)
  Future<Map<String, String>> analyzeJournal({
    required String journalText,
    required String todayCheckin,
    required String weekSummary,
  }) async {

    // Different prompt based on
    // whether journal was written or not
    final prompt = journalText.isEmpty
        ? _buildNoJournalPrompt(
            todayCheckin,
            weekSummary,
          )
        : _buildFullPrompt(
            journalText,
            todayCheckin,
            weekSummary,
          );

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': 'claude-haiku-4-5-20251001',
          'max_tokens': 200,
          'temperature': 0,
          'messages': [
            {
              'role': 'user',
              'content': prompt,
            }
          ],
        }),
      );

      final data = jsonDecode(response.body);
      final text = data['content'][0]['text'];
      return _parseResponse(text);

    } catch (e) {
      return {
        'mood': 'Neutral',
        'insight': 'Thanks for checking in today!',
      };
    }
  }

  // PROMPT WITH JOURNAL
  String _buildFullPrompt(
    String journalText,
    String todayCheckin,
    String weekSummary,
  ) {
    return """
You are a personal wellness assistant.

Here is the user's check-in data for today:
$todayCheckin

Here is their data from the past week:
$weekSummary

Today's journal entry: $journalText

Based on their habits today, 
this week's patterns, and journal:
1. Identify mood from journal and habits
2. Connect habits to mood
3. Give ONE personalized insight
4. Be warm and supportive

Respond in EXACTLY this format:
MOOD: [Happy/Neutral/Sad/Stressed/Anxious]
INSIGHT: [2-3 supportive sentences]
""";
  }

  // PROMPT WITHOUT JOURNAL
  String _buildNoJournalPrompt(
    String todayCheckin,
    String weekSummary,
  ) {
    return """
You are a personal wellness assistant.

The user did not write a journal today.

Here is their check-in data for today:
$todayCheckin

Here is their data from the past week:
$weekSummary

Based on their habits today
and this week's patterns:
1. Determine mood from check-in score
2. Give ONE supportive insight
   about their habits
3. Be warm and encouraging

Respond in EXACTLY this format:
MOOD: [Happy/Neutral/Sad/Stressed/Anxious]
INSIGHT: [2-3 supportive sentences]
""";
  }

  // BUILD TODAY'S CHECK-IN SUMMARY
  String buildTodayCheckin(Map<String, dynamic>? checkin) {
    if (checkin == null) {
      return 'No check-in data for today yet.';
    }
    return '''
Mood score: ${checkin['user_mood']}/5
Sleep: ${checkin['sleep_hours']} hours
Exercise: ${checkin['exercised'] ? 'Yes' : 'No'}
Water: ${checkin['water_glasses']} glasses
''';
  }

  // BUILD WEEK SUMMARY
  String buildWeekSummary(
      List<Map<String, dynamic>> checkins) {
    if (checkins.isEmpty) {
      return 'No check-in data available yet.';
    }

    String summary = '';
    for (var checkin in checkins) {
      summary += '''
Date: ${checkin['date']}
Mood: ${checkin['user_mood']}/5
Sleep: ${checkin['sleep_hours']} hours
Exercise: ${checkin['exercised'] ? 'Yes' : 'No'}
Water: ${checkin['water_glasses']} glasses
---
''';
    }
    return summary;
  }

  // PARSE CLAUDE RESPONSE
  Map<String, String> _parseResponse(String text) {
    try {
      final mood = text
          .split('MOOD:')[1]
          .split('\n')[0]
          .trim();
      final insight = text
          .split('INSIGHT:')[1]
          .trim();

      final validMoods = [
        'Happy',
        'Neutral',
        'Sad',
        'Stressed',
        'Anxious'
      ];

      return {
        'mood': validMoods.contains(mood) ? mood : 'Neutral',
        'insight': insight,
      };

    } catch (e) {
      return {
        'mood': 'Neutral',
        'insight': 'Thanks for checking in today!',
      };
    }
  }
}
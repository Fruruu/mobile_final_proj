import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/daily_checkin.dart';
import '../models/journal_checkin.dart';


class DatabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // CREATE
  Future<void> insertCheckin(DailyCheckin checkin) async {
    await _supabase
        .from('daily_checkins')
        .insert(checkin.toJson());
  }

  // READ
  Future<List<DailyCheckin>> getCheckins(String userId) async {
    final data = await _supabase
        .from('daily_checkins')
        .select()
        .eq('user_id', userId)
        .order('date', ascending: false);

    return data.map((e) => DailyCheckin.fromJson(e)).toList();
  }

  // READ LAST 7 DAYS (for RAG later)
  Future<List<DailyCheckin>> getLastSevenDays(String userId) async {
    final sevenDaysAgo = DateTime.now()
        .subtract(const Duration(days: 7))
        .toIso8601String()
        .split('T')[0];

    final data = await _supabase
        .from('daily_checkins')
        .select()
        .eq('user_id', userId)
        .gte('date', sevenDaysAgo)
        .order('date', ascending: true);

    return data.map((e) => DailyCheckin.fromJson(e)).toList();
  }

  // UPDATE
  Future<void> updateCheckin(DailyCheckin checkin) async {
    await _supabase
        .from('daily_checkins')
        .update(checkin.toJson())
        .eq('id', checkin.id!);
  }

  // DELETE
  Future<void> deleteCheckin(String id) async {
    await _supabase
        .from('daily_checkins')
        .delete()
        .eq('id', id);
  }

  // JOURNAL CRUD

  // CREATE
  Future<JournalEntry?> insertJournal(JournalEntry journal) async {
    try {
      final data = await _supabase
          .from('journal_entries')
          .insert(journal.toJson())
          .select()
          .single();
      return JournalEntry.fromJson(data);
    } catch (e) {
      print('Insert journal error: $e');
      return null;
    }
  }

  // READ
  Future<List<JournalEntry>> getJournals(String userId) async {
    final data = await _supabase
        .from('journal_entries')
        .select()
        .eq('user_id', userId)
        .order('date', ascending: false)
        .order('created_at', ascending: false);

    return data.map((e) => JournalEntry.fromJson(e)).toList();
  }

  // UPDATE
  Future<void> updateJournal(JournalEntry journal) async {
    await _supabase
        .from('journal_entries')
        .update(journal.toJson())
        .eq('id', journal.id!);
  }

  // DELETE
  Future<void> deleteJournal(String id) async {
    await _supabase
        .from('journal_entries')
        .delete()
        .eq('id', id);
  }
}

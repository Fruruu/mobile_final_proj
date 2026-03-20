import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/journal_entry.dart';

class JournalService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // CREATE
  Future<void> insertJournal(JournalEntry entry) async {
    await _supabase
        .from('journal_entries')
        .insert(entry.toJson());
  }

  // READ ALL
  Future<List<JournalEntry>> getJournals(String userId) async {
    final data = await _supabase
        .from('journal_entries')
        .select()
        .eq('user_id', userId)
        .order('date', ascending: false);

    return data.map((e) => JournalEntry.fromJson(e)).toList();
  }

  // read last nga 7 days. this is for rag 
  Future<List<JournalEntry>> getLastSevenDays(String userId) async {
    final sevenDaysAgo = DateTime.now()
        .subtract(const Duration(days: 7))
        .toIso8601String()
        .split('T')[0];

    final data = await _supabase
        .from('journal_entries')
        .select()
        .eq('user_id', userId)
        .gte('date', sevenDaysAgo)
        .order('date', ascending: true);

    return data.map((e) => JournalEntry.fromJson(e)).toList();
  }

  // UPDATE
  Future<void> updateJournal(JournalEntry entry) async {
    await _supabase
        .from('journal_entries')
        .update(entry.toJson())
        .eq('id', entry.id!);
  }

  // DELETE
  Future<void> deleteJournal(String id) async {
    await _supabase
        .from('journal_entries')
        .delete()
        .eq('id', id);
  }
}
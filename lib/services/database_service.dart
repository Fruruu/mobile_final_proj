import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/daily_checkin.dart';

class DatabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // CREATE OR UPDATE (upsert)
  Future<String?> insertCheckin(DailyCheckin checkin) async {
    final today = DateTime.now()
        .toIso8601String()
        .split('T')[0];

    // Check if check-in already exists for today
    final existing = await _supabase
        .from('daily_checkins')
        .select()
        .eq('user_id', checkin.userId)
        .eq('date', today)
        .maybeSingle();

    if (existing != null) {
      // Update existing check-in
      await _supabase
          .from('daily_checkins')
          .update(checkin.toJson())
          .eq('id', existing['id']);
      return existing['id']?.toString();
    } else {
      // Insert new check-in
      final inserted = await _supabase
          .from('daily_checkins')
          .insert(checkin.toJson())
          .select('id')
          .single();
      return inserted['id']?.toString();
    }
  }

  // READ ALL
  Future<List<DailyCheckin>> getCheckins(String userId) async {
    final data = await _supabase
        .from('daily_checkins')
        .select()
        .eq('user_id', userId)
        .order('date', ascending: false);

    return data.map((e) => DailyCheckin.fromJson(e)).toList();
  }

  // READ RECENT CHECK-INS (for faster streak calculation)
  Future<List<DailyCheckin>> getRecentCheckins(
    String userId, {
    int limit = 120,
  }) async {
    final data = await _supabase
        .from('daily_checkins')
        .select()
        .eq('user_id', userId)
        .order('date', ascending: false)
        .limit(limit);

    return data.map((e) => DailyCheckin.fromJson(e)).toList();
  }

  // READ TODAY'S CHECK-IN
  Future<DailyCheckin?> getTodayCheckin(String userId) async {
    final today = DateTime.now()
        .toIso8601String()
        .split('T')[0];

    final data = await _supabase
        .from('daily_checkins')
        .select()
        .eq('user_id', userId)
        .eq('date', today)
        .maybeSingle();

    if (data == null) return null;
    return DailyCheckin.fromJson(data);
  }

  // READ LAST 7 DAYS
  Future<List<DailyCheckin>> getLastSevenDays(
      String userId) async {
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

  // READ LAST 30 DAYS
  Future<List<DailyCheckin>> getLastThirtyDays(
      String userId) async {
    final thirtyDaysAgo = DateTime.now()
        .subtract(const Duration(days: 30))
        .toIso8601String()
        .split('T')[0];

    final data = await _supabase
        .from('daily_checkins')
        .select()
        .eq('user_id', userId)
        .gte('date', thirtyDaysAgo)
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

  // UPDATE AI RESULTS
  Future<void> updateCheckinAiResults(
    String id,
    String aiMood,
    String aiInsight,
  ) async {
    await _supabase
        .from('daily_checkins')
        .update({
          'ai_mood': aiMood,
          'ai_insight': aiInsight,
        })
        .eq('id', id);
  }

  // DELETE
  Future<void> deleteCheckin(String id) async {
    await _supabase
        .from('daily_checkins')
        .delete()
        .eq('id', id);
  }
}
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';

class ProfileService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _table = 'profiles';

  Future<void> upsertProfile(UserProfile profile) async {
    await _supabase.from(_table).upsert(profile.toJson());
  }

  Future<UserProfile?> getProfile(String userId) async {
    final data = await _supabase
        .from(_table)
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (data == null) return null;
    return UserProfile.fromJson(data);
  }
}

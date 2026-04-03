import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/user_profile.dart';
import '../../theme/app_colors.dart';
import '../../view_models/profile_view_model.dart';
import '../../widgets/frosted_app_bar.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  DateTime? _birthday;
  bool _isLoading = false;

  static const Color _bg = AppColors.white;
  static const Color _text = AppColors.black;
  static const Color _muted = Color(0xFF8F8B8C);
  static const Color _pink = AppColors.primaryPink;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _loadProfileData();
  }

  void _loadProfileData() {
    final profileVm = Provider.of<ProfileViewModel>(context, listen: false);
    if (profileVm.profile != null) {
      _nameController.text = profileVm.profile!.name ?? '';
      _phoneController.text = profileVm.profile!.phone ?? '';
      _birthday = profileVm.profile!.birthday;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final profileVm = Provider.of<ProfileViewModel>(context, listen: false);
      
      // Update profile with new data
      await profileVm.profileService.upsertProfile(
        _buildProfileFromForm(user.id, user.email ?? ''),
      );

      // Reload profile
      await profileVm.loadProfile(user.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Profile updated successfully!'),
            backgroundColor: Color(0xFF4CAF50),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  dynamic _buildProfileFromForm(String userId, String email) {
    // Return a UserProfile object for upserting
    return UserProfile(
      id: userId,
      email: email,
      name: _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
      birthday: _birthday,
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileVm = Provider.of<ProfileViewModel>(context);

    return Scaffold(
      backgroundColor: _bg,
      extendBodyBehindAppBar: true,
      appBar: const FrostedAppBar(title: 'Edit Profile'),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            18,
            MediaQuery.of(context).padding.top + FrostedAppBar.barHeight + 16,
            18,
            28,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: _text,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Help us personalize your mood insights',
                style: TextStyle(
                  fontSize: 14,
                  color: _muted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),

              // Name field
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  'Your Name',
                  style: TextStyle(
                    color: _muted,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Alex Smith',
                  hintStyle: const TextStyle(color: Color(0xFFD0CCCC)),
                  filled: true,
                  fillColor: const Color(0xFFFAF8F8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE6E1DC)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE6E1DC)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _pink, width: 2),
                  ),
                ),
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 18),

              // Phone field
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  'Phone Number (optional)',
                  style: TextStyle(
                    color: _muted,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: '+1 555 123 4567',
                  hintStyle: const TextStyle(color: Color(0xFFD0CCCC)),
                  filled: true,
                  fillColor: const Color(0xFFFAF8F8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE6E1DC)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE6E1DC)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _pink, width: 2),
                  ),
                ),
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 18),

              // Birthday picker
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  'Birthday (optional)',
                  style: TextStyle(
                    color: _muted,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  final now = DateTime.now();
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _birthday ?? DateTime(now.year - 25, now.month, now.day),
                    firstDate: DateTime(1900),
                    lastDate: now,
                  );
                  if (picked != null) {
                    setState(() => _birthday = picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF8F8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE6E1DC)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.cake_outlined, color: _muted),
                      const SizedBox(width: 12),
                      Text(
                        _birthday == null
                            ? 'Select your birthday'
                            : '${_birthday!.year}-${_birthday!.month.toString().padLeft(2, '0')}-${_birthday!.day.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 15,
                          color: _birthday == null ? _muted : _text,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (_birthday != null)
                GestureDetector(
                  onTap: () => setState(() => _birthday = null),
                  child: Text(
                    'Clear date',
                    style: TextStyle(
                      fontSize: 12,
                      color: _pink.withOpacity(0.7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const SizedBox(height: 32),

              // Save button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: FilledButton.styleFrom(
                    backgroundColor: _pink,
                    disabledBackgroundColor: _pink.withOpacity(0.5),
                    foregroundColor: AppColors.white,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(AppColors.white),
                          ),
                        )
                      : const Text('Save Profile'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _text,
                    side: const BorderSide(color: Color(0xFFE6E1DC)),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(height: 20),
              
              // Logout button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : () async {
                    await Supabase.instance.client.auth.signOut();
                    if (mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/login',
                        (route) => false,
                      );
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.red,
                    side: const BorderSide(color: AppColors.red),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Logout',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

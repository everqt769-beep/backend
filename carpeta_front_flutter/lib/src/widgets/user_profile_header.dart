import 'package:flutter/material.dart';
import 'package:myapp/src/services/auth_service.dart';

class UserProfileHeader extends StatefulWidget {
  const UserProfileHeader({super.key});

  @override
  State<UserProfileHeader> createState() => _UserProfileHeaderState();
}

class _UserProfileHeaderState extends State<UserProfileHeader> {
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final userProfile = await _authService.getUserProfile();
    setState(() {
      _userProfile = userProfile;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final username = _userProfile?['username'] as String? ?? 'No username';
    final avatarUrl = _userProfile?['avatar_url'] as String?;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
            child: avatarUrl == null
                ? const Icon(Icons.person, size: 40)
                : null,
          ),
          const SizedBox(width: 16),
          Text(
            'Welcome, $username',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ],
      ),
    );
  }
}

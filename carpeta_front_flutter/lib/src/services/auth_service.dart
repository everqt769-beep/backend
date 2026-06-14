import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final GoTrueClient _auth = Supabase.instance.client.auth;

  Stream<AuthState> get authStateChanges => _auth.onAuthStateChange;

  bool get isAuthenticated => _auth.currentSession != null;

  Future<void> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    await _auth.signUp(
      email: email,
      password: password,
      data: data,
    );
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.resetPasswordForEmail(email);
  }

  User? get currentUser => _auth.currentUser;

  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = currentUser;
    if (user != null) {
      final response = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();
      return response;
    }
    return null;
  }
}

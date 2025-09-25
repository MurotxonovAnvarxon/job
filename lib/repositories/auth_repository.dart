import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthRepository {
  final _supabase = Supabase.instance.client;

  Future<UserModel?> signUp(String email, String password) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        return UserModel(
          id: response.user!.id,
          email: response.user!.email!,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  Future<UserModel?> signIn(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        return UserModel(
          id: response.user!.id,
          email: response.user!.email!,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  UserModel? getCurrentUser() {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      return UserModel(
        id: user.id,
        email: user.email!,
      );
    }
    return null;
  }

  // Stream<AuthState> get authStateChanges {
  //   return _supabase.auth.onAuthStateChange.map((data) => data.event);
  // }
}
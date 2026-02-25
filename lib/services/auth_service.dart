import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  bool _isLoggedIn = false;
  String? _userEmail;
  bool _isAdmin = false;

  bool get isLoggedIn => _isLoggedIn;
  String? get userEmail => _userEmail;
  bool get isAdmin => _isAdmin;

  AuthService() {
    // Escutar mudanças no estado de autenticação do Supabase
    _supabase.auth.onAuthStateChange.listen((data) {
      final Session? session = data.session;
      final User? user = session?.user;
      
      if (user != null) {
        _isLoggedIn = true;
        _userEmail = user.email;
        // Lógica simples de admin por email para teste, mas no Supabase você usaria roles ou metadata
        _isAdmin = user.email == "admin@grimorio.com";
      } else {
        _isLoggedIn = false;
        _userEmail = null;
        _isAdmin = false;
      }
      notifyListeners();
    });
  }

  // Criar nova conta
  Future<String?> register(String email, String password) async {
    try {
      await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      return null; // Sucesso
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Erro inesperado ao criar conta.";
    }
  }

  // Login
  Future<String?> login(String email, String password) async {
    try {
      await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return null; // Sucesso
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Erro ao acessar o grimório.";
    }
  }

  // Logout
  Future<void> logout() async {
    await _supabase.auth.signOut();
  }
}

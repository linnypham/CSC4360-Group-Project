import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:weatherly/services/firebase_service.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseService _firebaseService;
  User? _currentUser;

  AuthProvider(this._firebaseService) {
    _init();
  }

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  void _init() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  Future<void> signInWithEmail(String email, String password) async {
    try {
      await _firebaseService.signInWithEmail(email, password);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _firebaseService.signOut();
  }
}
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;
  

  Map<String, dynamic>? _userData;
  
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;
  
  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      if (user != null) {
        _loadUserData();
      }
      notifyListeners();
    });
  }
  
  // Charger les données utilisateur depuis SharedPreferences
  Future<void> _loadUserData() async {
    if (_user == null) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_${_user!.uid}');
      
      if (userDataString != null) {
        _userData = json.decode(userDataString);
      } else {
        _userData = {
          'name': _user?.displayName ?? 'Utilisateur',
          'email': _user?.email ?? '',
          'phone': '',
          'addresses': [],
          'favoriteItems': [],
        };
      }
    } catch (e) {
      _userData = {
        'name': _user?.displayName ?? 'Utilisateur',
        'email': _user?.email ?? '',
        'phone': '',
        'addresses': [],
        'favoriteItems': [],
      };
    }
  }
  
  // Sauvegarder les données utilisateur dans SharedPreferences
  Future<void> _saveUserData() async {
    if (_user == null || _userData == null) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_${_user!.uid}', json.encode(_userData));
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde des données: $e');
    }
  }
  
  // Connexion avec Google 
  Future<bool> signInWithGoogle() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      
      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      // Se connecter à Firebase 
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      _user = userCredential.user;
      
     
      await _loadUserData();
      
      // Si c'est un nouvel utilisateur, créer les données
      if (_userData == null || _userData!.isEmpty) {
        _userData = {
          'name': _user?.displayName ?? 'Utilisateur',
          'email': _user?.email ?? '',
          'phone': '',
          'createdAt': DateTime.now().toIso8601String(),
          'addresses': [],
          'favoriteItems': [],
        };
        await _saveUserData();
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
      
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      switch (e.code) {
        case 'account-exists-with-different-credential':
          _errorMessage = 'Un compte existe déjà avec cet email';
          break;
        case 'invalid-credential':
          _errorMessage = 'Identifiants invalides';
          break;
        case 'operation-not-allowed':
          _errorMessage = 'Connexion Google désactivée';
          break;
        case 'user-disabled':
          _errorMessage = 'Ce compte a été désactivé';
          break;
        default:
          _errorMessage = 'Erreur: ${e.message}';
      }
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Erreur de connexion avec Google';
      debugPrint('Erreur Google Sign-In: $e');
      notifyListeners();
      return false;
    }
  }
  
  // Inscription avec email et mot de passe
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      // Créer l'utilisateur dans Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      
      await userCredential.user?.updateDisplayName(name);
      
      // Sauvegarder les infos en mémoire locale
      _userData = {
        'name': name,
        'email': email,
        'phone': phone,
        'createdAt': DateTime.now().toIso8601String(),
        'addresses': [],
        'favoriteItems': [],
      };
      
      _user = userCredential.user;
      
      // Sauvegarder dans SharedPreferences
      await _saveUserData();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      switch (e.code) {
        case 'weak-password':
          _errorMessage = 'Le mot de passe est trop faible';
          break;
        case 'email-already-in-use':
          _errorMessage = 'Cet email est déjà utilisé';
          break;
        case 'invalid-email':
          _errorMessage = 'Email invalide';
          break;
        default:
          _errorMessage = 'Erreur: ${e.message}';
      }
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Une erreur est survenue';
      notifyListeners();
      return false;
    }
  }
  
  // Connexion avec email et mot de passe
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      _user = userCredential.user;
      
      
      await _loadUserData();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      switch (e.code) {
        case 'user-not-found':
          _errorMessage = 'Aucun utilisateur trouvé';
          break;
        case 'wrong-password':
          _errorMessage = 'Mot de passe incorrect';
          break;
        case 'invalid-email':
          _errorMessage = 'Email invalide';
          break;
        case 'user-disabled':
          _errorMessage = 'Ce compte a été désactivé';
          break;
        case 'invalid-credential':
          _errorMessage = 'Email ou mot de passe incorrect';
          break;
        default:
          _errorMessage = 'Erreur: ${e.message}';
      }
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Une erreur est survenue';
      notifyListeners();
      return false;
    }
  }
  
  
  Future<bool> resetPassword(String email) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      await _auth.sendPasswordResetEmail(email: email);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      switch (e.code) {
        case 'user-not-found':
          _errorMessage = 'Aucun utilisateur trouvé';
          break;
        case 'invalid-email':
          _errorMessage = 'Email invalide';
          break;
        default:
          _errorMessage = 'Erreur: ${e.message}';
      }
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Une erreur est survenue';
      notifyListeners();
      return false;
    }
  }
  
  // Déconnexion
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(), 
      ]);
      _user = null;
      _userData = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors de la déconnexion';
      notifyListeners();
    }
  }
  
  // Récupérer les données utilisateur
  Future<Map<String, dynamic>?> getUserData() async {
    if (_user == null) return null;
    
    if (_userData == null) {
      await _loadUserData();
    }
    
    return _userData;
  }
  
  
  Future<bool> updateUserProfile({
    String? name,
    String? phone,
  }) async {
    if (_user == null) return false;
    
    try {
      if (name != null) {
        await _user!.updateDisplayName(name);
        _userData?['name'] = name;
      }
      
      if (phone != null) {
        _userData?['phone'] = phone;
      }
      
      // Sauvegarder les modifications
      await _saveUserData();
      
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de la mise à jour';
      notifyListeners();
      return false;
    }
  }
  
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
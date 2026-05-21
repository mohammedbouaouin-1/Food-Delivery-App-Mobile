import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_profile.dart';
import '../models/address.dart';
import '../utils/validators.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<User?>? _authSubscription;

  UserProfile? _userProfile;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  UserProfile get userProfile => _userProfile ?? const UserProfile();

  AuthProvider() {
    _authSubscription = _auth.authStateChanges().listen((User? user) {
      _user = user;
      if (user != null) {
        _loadUserData();
      } else {
        _userProfile = null;
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
        _userProfile = UserProfile.fromJson(json.decode(userDataString));
      } else {
        _userProfile = UserProfile(
          name: _user?.displayName ?? 'Utilisateur',
          email: _user?.email ?? '',
          phone: '',
          addresses: const [],
          favoriteItems: const [],
        );
      }
    } catch (e) {
      _userProfile = UserProfile(
        name: _user?.displayName ?? 'Utilisateur',
        email: _user?.email ?? '',
        phone: '',
        addresses: const [],
        favoriteItems: const [],
      );
    }
  }

  // Sauvegarder les données utilisateur dans SharedPreferences
  Future<void> _saveUserData() async {
    if (_user == null || _userProfile == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_${_user!.uid}', json.encode(_userProfile!.toJson()));
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
      if (_userProfile == null) {
        _userProfile = UserProfile(
          name: _user?.displayName ?? 'Utilisateur',
          email: _user?.email ?? '',
          phone: '',
          addresses: const [],
          favoriteItems: const [],
        );
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
    // Form validation
    final emailError = Validators.validateEmail(email);
    if (emailError != null) {
      _errorMessage = emailError;
      notifyListeners();
      return false;
    }
    final passError = Validators.validatePassword(password);
    if (passError != null) {
      _errorMessage = passError;
      notifyListeners();
      return false;
    }
    final nameError = Validators.validateName(name);
    if (nameError != null) {
      _errorMessage = nameError;
      notifyListeners();
      return false;
    }
    final phoneError = Validators.validatePhone(phone);
    if (phoneError != null) {
      _errorMessage = phoneError;
      notifyListeners();
      return false;
    }

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

      _userProfile = UserProfile(
        name: name,
        email: email,
        phone: phone,
        addresses: const [],
        favoriteItems: const [],
      );

      _user = userCredential.user;

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
      _userProfile = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors de la déconnexion';
      notifyListeners();
    }
  }

  // Récupérer les données utilisateur
  Future<Map<String, dynamic>?> getUserData() async {
    if (_user == null) return null;

    if (_userProfile == null) {
      await _loadUserData();
    }

    return _userProfile?.toJson();
  }

  Future<bool> updateUserProfile({
    String? name,
    String? phone,
  }) async {
    if (_user == null) return false;

    try {
      if (name != null) {
        await _user?.updateDisplayName(name);
      }

      _userProfile = _userProfile?.copyWith(
        name: name ?? _userProfile?.name,
        phone: phone ?? _userProfile?.phone,
      );

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

  /// Sauvegarder les adresses de livraison
  Future<bool> saveAddresses(List<Map<String, String>> addresses) async {
    if (_user == null) return false;
    try {
      final List<Address> typedAddresses = addresses.map((addr) {
        return Address(
          id: addr['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
          label: addr['label'] ?? '',
          address: addr['address'] ?? '',
          city: addr['city'] ?? '',
          isDefault: addr['isDefault'] == 'true',
        );
      }).toList();

      _userProfile = _userProfile?.copyWith(addresses: typedAddresses);
      await _saveUserData();
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
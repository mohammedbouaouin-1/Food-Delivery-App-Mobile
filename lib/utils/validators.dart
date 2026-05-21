class Validators {
  static final RegExp _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  static final RegExp _phoneRegex = RegExp(r'^0[5-7]\d{8}$');

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Veuillez saisir votre adresse email';
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return 'Veuillez saisir une adresse email valide';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Veuillez saisir votre numéro de téléphone';
    }
    if (!_phoneRegex.hasMatch(value.trim())) {
      return 'Le numéro de téléphone doit être au format valide (ex: 0612345678)';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez saisir votre mot de passe';
    }
    if (value.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Veuillez saisir votre nom';
    }
    if (value.trim().length < 2) {
      return 'Le nom doit contenir au moins 2 caractères';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Le champ $fieldName est obligatoire';
    }
    return null;
  }

  // Password strength: returns a score between 0.0 and 1.0
  static double passwordStrength(String password) {
    if (password.isEmpty) return 0.0;
    double strength = 0.0;

    // Length contribution
    if (password.length >= 6) strength += 0.2;
    if (password.length >= 10) strength += 0.2;

    // Characters contribution
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.2;
    if (password.contains(RegExp(r'[a-z]'))) strength += 0.1;
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.2;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.1;

    return strength;
  }
}

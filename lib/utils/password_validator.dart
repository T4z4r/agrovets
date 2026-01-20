import '../../l10n/app_localizations.dart';

class PasswordValidator {
  static String? validate(String password, AppLocalizations localizations) {
    if (password.isEmpty) {
      return localizations.passwordRequired;
    }

    if (password.length < 8) {
      return localizations.passwordMustBeAtLeast8Characters;
    }

    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return localizations.passwordMustContainUppercase;
    }

    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return localizations.passwordMustContainLowercase;
    }

    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return localizations.passwordMustContainNumber;
    }

    if (!RegExp(r'[!@#$%^&*(),.?":|<>]').hasMatch(password)) {
      return localizations.passwordMustContainSpecial;
    }

    return null; // Valid
  }

  static List<String> getRequirements(AppLocalizations localizations) {
    return [
      localizations.passwordRequirementLength,
      localizations.passwordRequirementUppercase,
      localizations.passwordRequirementLowercase,
      localizations.passwordRequirementNumber,
      localizations.passwordRequirementSpecial,
    ];
  }

  static Map<String, bool> checkRequirements(String password) {
    return {
      'length': password.length >= 8,
      'uppercase': RegExp(r'[A-Z]').hasMatch(password),
      'lowercase': RegExp(r'[a-z]').hasMatch(password),
      'number': RegExp(r'[0-9]').hasMatch(password),
      'special': RegExp(r'[!@#$%^&*(),.?":|<>]').hasMatch(password),
    };
  }
}
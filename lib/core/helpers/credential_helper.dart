import 'dart:math';

// ===========================================================
// AKS MediCare Pro
// Credential Helper
//
// Username suggestion, temporary password generation, and
// strong-password validation used by Employee Account
// Management and the forced first-login password change.
// ===========================================================

class CredentialHelper {
  CredentialHelper._();

  static final Random _random = Random.secure();

  /// Suggests a username from a full name, e.g. "Amit Verma" -> "amit.verma".
  /// Appends digits if needed to dodge an obvious collision — the
  /// caller still checks uniqueness against the database before saving.
  static String suggestUsername(String fullName, {int? disambiguator}) {
    final parts = fullName
        .trim()
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();

    final base = parts.isEmpty ? 'user' : parts.join('.');
    final cleaned = base.replaceAll(RegExp(r'[^a-z0-9.]'), '');

    if (disambiguator == null) return cleaned;
    return '$cleaned$disambiguator';
  }

  /// Generates a temporary password that satisfies [validateStrength]:
  /// at least one uppercase, one lowercase, one digit, one symbol.
  static String generateTemporaryPassword({int length = 10}) {
    const upper = 'ABCDEFGHJKLMNPQRSTUVWXYZ'; // no I/O to avoid confusion
    const lower = 'abcdefghijkmnopqrstuvwxyz'; // no l
    const digits = '23456789'; // no 0/1
    const symbols = '!@#\$%&*';

    final required = [
      upper[_random.nextInt(upper.length)],
      lower[_random.nextInt(lower.length)],
      digits[_random.nextInt(digits.length)],
      symbols[_random.nextInt(symbols.length)],
    ];

    const all = upper + lower + digits + symbols;
    final remainingLength = (length - required.length).clamp(0, length);

    final rest = List.generate(remainingLength, (_) => all[_random.nextInt(all.length)]);

    final chars = [...required, ...rest]..shuffle(_random);
    return chars.join();
  }

  /// Returns null if [password] meets the strength policy, otherwise
  /// a human-readable reason it was rejected.
  static String? validateStrength(String password) {
    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Password must include at least one uppercase letter';
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Password must include at least one lowercase letter';
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password must include at least one number';
    }
    if (!password.contains(RegExp(r'[!@#\$%&*(),.?":{}|<>_\-]'))) {
      return 'Password must include at least one special character';
    }
    return null;
  }
}

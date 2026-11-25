import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Store reviewers can't make purchases, and Google asks for a way to reach everything in the
/// app, paid features included. A store build can carry the fingerprint (SHA-256) of an access
/// code: typing that code on the Aloft Pro screen switches Pro on for this install. The code
/// itself is never in the app or in git, only its fingerprint, from
/// `--dart-define=ALOFT_REVIEW_CODE_SHA256=...` in `dart_defines.release.json`.
///
/// A build with a different fingerprint no longer honours an old code, so changing the code in
/// the next release switches earlier uses of it off.
const reviewCodeFingerprint = String.fromEnvironment('ALOFT_REVIEW_CODE_SHA256');

/// Where "this install used the access code" is remembered.
abstract class ReviewAccessStore {
  Future<String?> read();
  Future<void> write(String fingerprint);
}

/// The phone's secure storage, beside the database key.
class SecureReviewAccessStore implements ReviewAccessStore {
  const SecureReviewAccessStore();
  static const _storage = FlutterSecureStorage(iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock));
  static const _key = 'aloft_review_access';

  @override
  Future<String?> read() async {
    try {
      return await _storage.read(key: _key);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> write(String fingerprint) => _storage.write(key: _key, value: fingerprint);
}

/// Kept only while the app runs: tests, and builds with no access code.
class MemoryReviewAccessStore implements ReviewAccessStore {
  String? _value;
  @override
  Future<String?> read() async => _value;
  @override
  Future<void> write(String fingerprint) async => _value = fingerprint;
}

class ReviewAccess {
  ReviewAccess({required String fingerprint, required this.store}) : fingerprint = fingerprint.trim().toLowerCase();

  /// Lower-case hex SHA-256 of the code this build accepts. Empty: no code is accepted and the
  /// Pro screen never mentions one.
  final String fingerprint;
  final ReviewAccessStore store;

  bool get offered => fingerprint.isNotEmpty;

  static String fingerprintOf(String code) => sha256.convert(utf8.encode(code.trim())).toString();

  /// Whether this install has already used the code this build accepts.
  Future<bool> granted() async => offered && await store.read() == fingerprint;

  /// True, and remembered, when [code] is the one this build accepts.
  Future<bool> redeem(String code) async {
    if (!offered || fingerprintOf(code) != fingerprint) return false;
    await store.write(fingerprint);
    return true;
  }
}

/// Set in main(). Off (no code accepted) unless the build was given a fingerprint.
final reviewAccessProvider = Provider<ReviewAccess>(
  (ref) => ReviewAccess(fingerprint: '', store: MemoryReviewAccessStore()),
);

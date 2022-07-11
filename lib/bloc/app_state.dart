import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show immutable;

import 'package:blocwithfirebaseexample/auth/auth_error.dart';

@immutable
abstract class AppState {
  final bool isLoading;
  final AuthError? authError;

  const AppState({
    required this.isLoading,
    this.authError,
  });
}

@immutable
class AppStateLoggedIn extends AppState {
  final User user;
  final Iterable<Reference> images;

  const AppStateLoggedIn({
    required this.user,
    required this.images,
    required bool isLoading,
    AuthError? authError,
  }) : super(isLoading: isLoading, authError: authError);

  @override
  String toString() => 'AppStateLoggedIn, images.length = ${images.length}';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AppStateLoggedIn &&
        isLoading == other.isLoading &&
        user.uid == other.user.uid &&
        images.length == other.images.length;
  }

  @override
  int get hashCode => user.hashCode ^ images.hashCode;
}

@immutable
class AppStateLoggedOut extends AppState {
  const AppStateLoggedOut({
    required bool isLoading,
    AuthError? authError,
  }) : super(
          isLoading: isLoading,
          authError: authError,
        );

  @override
  String toString() =>
      'AppStateLoggedOut, isLoading = $isLoading, authError = $authError';
}

@immutable
class AppStateIsInRegistrationView extends AppState {
  const AppStateIsInRegistrationView({
    required bool isLoading,
    AuthError? authError,
  }) : super(
          isLoading: isLoading,
          authError: authError,
        );
}

extension GetUser on AppState {
  User? get user {
    final cls = this;
    if (cls is AppStateLoggedIn) {
      return cls.user;
    } else {
      return null;
    }
  }
}

extension GetImages on AppState {
  Iterable<Reference>? get images {
    final cls = this;
    if (cls is AppStateLoggedIn) {
      return cls.images;
    } else {
      return null;
    }
  }
}

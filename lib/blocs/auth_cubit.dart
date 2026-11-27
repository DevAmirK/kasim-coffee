import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/auth_store.dart';
import '../models/user.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => const [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthSuccess extends AuthState {
  const AuthSuccess(this.user);

  final User user;
  String get username => user.name;
  String get email => user.email;

  @override
  List<Object?> get props => [username, email, user.coffeeLevel];
}

class AuthError extends AuthState {
  const AuthError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthInitial());

  static const student = User(
    name: 'Student',
    email: 'student@narxoz.kz',
    password: '123456',
    coffeeLevel: 'Beginner',
  );

  static const demo = User(
    name: 'Test User',
    email: 'test@example.com',
    password: 'test123',
    coffeeLevel: 'Beginner',
  );

  Future<void> login(
    String email,
    String password, {
    User? registeredUser,
  }) async {
    if (state is AuthLoading) return;
    emit(const AuthLoading());
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (isClosed) return;

    final normalizedEmail = email.trim();
    final candidates = [
      student,
      if (kDebugMode) demo,
      registeredUser ?? AuthStore.registeredUser,
    ];
    for (final user in candidates) {
      if (user != null && user.email == normalizedEmail) {
        if (user.password != password) break;
        try {
          await AuthStore.saveSession(user);
        } catch (_) {
          if (!isClosed) {
            emit(const AuthError('Could not save sign-in. Please try again.'));
          }
          return;
        }
        if (!isClosed) emit(AuthSuccess(user));
        return;
      }
    }
    emit(const AuthError('Wrong email or password'));
  }
}

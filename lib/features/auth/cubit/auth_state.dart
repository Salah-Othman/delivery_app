import 'package:equatable/equatable.dart';

import '../../../models/user_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthCodeSent extends AuthState {
  final String verificationId;
  final String phone;
  final int? resendToken;

  const AuthCodeSent({
    required this.verificationId,
    required this.phone,
    this.resendToken,
  });

  @override
  List<Object?> get props => [verificationId, phone, resendToken];
}

class AuthVerified extends AuthState {
  final UserModel user;

  const AuthVerified({required this.user});

  @override
  List<Object?> get props => [user];
}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

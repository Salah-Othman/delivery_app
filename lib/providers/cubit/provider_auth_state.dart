import 'package:equatable/equatable.dart';

import '../../models/provider_model.dart';

abstract class ProviderAuthState extends Equatable {
  const ProviderAuthState();

  @override
  List<Object?> get props => [];
}

class ProviderAuthInitial extends ProviderAuthState {
  const ProviderAuthInitial();
}

class ProviderAuthLoading extends ProviderAuthState {
  const ProviderAuthLoading();
}

class ProviderAuthVerified extends ProviderAuthState {
  final ProviderModel provider;

  const ProviderAuthVerified({required this.provider});

  @override
  List<Object?> get props => [provider];
}

class ProviderUnregistered extends ProviderAuthState {
  const ProviderUnregistered();
}

class ProviderAuthError extends ProviderAuthState {
  final String message;

  const ProviderAuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

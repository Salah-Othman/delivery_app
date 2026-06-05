import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/routes.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthCodeSent) {
          Navigator.pushNamed(context, AppRoutes.otp, arguments: state.phone);
        } else if (state is AuthError) {
          _showSnackBar(context, state.message);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                const SizedBox(height: 80),
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    Icons.handshake_rounded,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'إيد واحدة',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'كل حاجة في مكان واحد',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                TextFormField(
                  controller: _phoneController,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.phone,
                  maxLength: 11,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'برجاء إدخال رقم الموبايل';
                    if (v.trim().length < 11) return 'رقم غير صحيح (يجب أن يكون 11 رقم)';
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: '01001234567',
                    counterText: '',
                    prefixIcon: const Icon(Icons.phone_android_rounded),
                  ),
                ),
                const SizedBox(height: 24),
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    final loading = state is AuthLoading;
                    return FilledButton(
                      onPressed: loading
                          ? null
                          : () {
                              if (!_formKey.currentState!.validate()) return;
                              final phone = _phoneController.text.trim();
                              context.read<AuthCubit>().signInWithPhone('+2$phone');
                            },
                      child: loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('تسجيل الدخول برقم الموبايل'),
                    );
                  },
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(child: Divider(color: theme.colorScheme.outlineVariant)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'أو',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: theme.colorScheme.outlineVariant)),
                  ],
                ),
                const SizedBox(height: 24),
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    final loading = state is AuthLoading;
                    return OutlinedButton.icon(
                      onPressed: loading
                          ? null
                          : () => context.read<AuthCubit>().signInWithGoogle(),
                      icon: Image.asset(
                        'assets/google_logo.png',
                        height: 20,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.g_mobiledata_rounded,
                          size: 28,
                        ),
                      ),
                      label: const Text('تسجيل الدخول بواسطة Google'),
                    );
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
}

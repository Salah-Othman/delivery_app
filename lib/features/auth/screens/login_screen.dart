import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error_utils.dart';
import '../../../core/routes.dart';
import '../../../providers/cubit/provider_auth_cubit.dart';
import '../../../providers/cubit/provider_auth_state.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

enum _LoginRole { customer, provider }
enum _AuthMode { signIn, signUp }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  _LoginRole _selectedRole = _LoginRole.customer;
  _AuthMode _authMode = _AuthMode.signIn;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthError && _selectedRole == _LoginRole.customer) {
              showErrorSnackBar(context, state.message);
            } else if (state is AuthVerified && _selectedRole == _LoginRole.customer) {
              Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (_) => false);
            }
          },
        ),
        BlocListener<ProviderAuthCubit, ProviderAuthState>(
          listener: (context, state) {
            if (state is ProviderAuthVerified) {
              Navigator.pushNamedAndRemoveUntil(context, AppRoutes.providerHome, (_) => false);
            } else if (state is ProviderUnregistered) {
              _showUnregisteredDialog(context);
            } else if (state is ProviderAuthError) {
              showErrorSnackBar(context, state.message);
            }
          },
        ),
      ],
      child: Scaffold(
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                const SizedBox(height: 60),
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
                const SizedBox(height: 32),
                SegmentedButton<_LoginRole>(
                  segments: const [
                    ButtonSegment(
                      value: _LoginRole.customer,
                      label: Text('عميل'),
                      icon: Icon(Icons.person_outline),
                    ),
                    ButtonSegment(
                      value: _LoginRole.provider,
                      label: Text('مقدم خدمة'),
                      icon: Icon(Icons.handyman_outlined),
                    ),
                  ],
                  selected: {_selectedRole},
                  onSelectionChanged: (v) {
                    setState(() {
                      _selectedRole = v.first;
                      _clearFields();
                    });
                  },
                  style: ButtonStyle(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _AuthModeToggle(
                        label: 'تسجيل دخول',
                        selected: _authMode == _AuthMode.signIn,
                        onTap: () => setState(() => _authMode = _AuthMode.signIn),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _AuthModeToggle(
                        label: 'إنشاء حساب',
                        selected: _authMode == _AuthMode.signUp,
                        onTap: () => setState(() => _authMode = _AuthMode.signUp),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (_authMode == _AuthMode.signUp)
                  TextFormField(
                    controller: _nameController,
                    textDirection: TextDirection.rtl,
                    keyboardType: TextInputType.text,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'برجاء إدخال الاسم';
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'الاسم',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                if (_authMode == _AuthMode.signUp) const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  textDirection: TextDirection.ltr,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'برجاء إدخال البريد الإلكتروني';
                    if (!v.contains('@')) return 'بريد إلكتروني غير صحيح';
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'البريد الإلكتروني',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  textDirection: TextDirection.ltr,
                  obscureText: _obscurePassword,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'برجاء إدخال كلمة المرور';
                    if (v.length < 6) return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'كلمة المرور',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, customerState) {
                    final loading = _selectedRole == _LoginRole.customer
                        ? customerState is AuthLoading
                        : context.watch<ProviderAuthCubit>().state is ProviderAuthLoading;
                    return FilledButton(
                      onPressed: loading ? null : _onSubmit,
                      child: loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _authMode == _AuthMode.signIn
                                  ? 'تسجيل الدخول'
                                  : 'إنشاء حساب',
                            ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (_selectedRole == _LoginRole.customer) {
      if (_authMode == _AuthMode.signIn) {
        context.read<AuthCubit>().signIn(email, password);
      } else {
        final name = _nameController.text.trim();
        context.read<AuthCubit>().signUp(email, password, name);
      }
    } else {
      if (_authMode != _AuthMode.signIn) {
        showErrorSnackBar(context, 'مقدمي الخدمة يتم تسجيلهم بواسطة الإدارة');
        return;
      }
      context.read<ProviderAuthCubit>().signIn(email, password);
    }
  }

  void _clearFields() {
    _emailController.clear();
    _passwordController.clear();
    _nameController.clear();
    _authMode = _AuthMode.signIn;
  }

  void _showUnregisteredDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('غير مسجل'),
        content: const Text(
          'هذا البريد الإلكتروني غير مسجل كمقدم خدمة في التطبيق. '
          'يرجى التواصل مع الإدارة لتسجيلك كمقدم خدمة.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<ProviderAuthCubit>().reset();
            },
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }
}

class _AuthModeToggle extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _AuthModeToggle({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).colorScheme.primaryContainer
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

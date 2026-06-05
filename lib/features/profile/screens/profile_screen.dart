import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/routes.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../auth/cubit/auth_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = context.watch<AuthCubit>().state;
    final user = authState is AuthVerified ? authState.user : null;
    final phone = user?.phone;

    return Scaffold(
      appBar: AppBar(title: const Text('حسابي')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user?.name ?? 'مستخدم',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (phone != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      phone,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _ProfileMenuItem(
            icon: Icons.receipt_long_outlined,
            label: 'طلباتي',
            onTap: () => Navigator.pushNamed(context, AppRoutes.orderHistory),
          ),
          _ProfileMenuItem(
            icon: Icons.location_on_outlined,
            label: 'العناوين',
          ),
          _ProfileMenuItem(
            icon: Icons.payment_outlined,
            label: 'طرق الدفع',
          ),
          _ProfileMenuItem(
            icon: Icons.favorite_outline,
            label: 'المفضلة',
          ),
          _ProfileMenuItem(
            icon: Icons.headset_mic_outlined,
            label: 'خدمة العملاء',
          ),
          _ProfileMenuItem(
            icon: Icons.settings_outlined,
            label: 'الإعدادات',
          ),
          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: () {
              context.read<AuthCubit>().signOut();
              Navigator.pushNamedAndRemoveUntil(
                  context, AppRoutes.login, (_) => false);
            },
            icon: const Icon(Icons.logout_rounded),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
              side: BorderSide(color: theme.colorScheme.error),
            ),
            label: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        trailing: const Icon(Icons.chevron_left),
        onTap: onTap,
      ),
    );
  }
}

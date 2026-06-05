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
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  user?.phone ?? '',
                  style:
                      TextStyle(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildMenuItem(theme, Icons.receipt_long_outlined, 'طلباتي', () {
            Navigator.pushNamed(context, AppRoutes.orderHistory);
          }),
          _buildMenuItem(
              theme, Icons.location_on_outlined, 'العناوين', () {}),
          _buildMenuItem(
              theme, Icons.payment_outlined, 'طرق الدفع', () {}),
          _buildMenuItem(
              theme, Icons.favorite_outline, 'المفضلة', () {}),
          _buildMenuItem(
              theme, Icons.headset_mic_outlined, 'خدمة العملاء', () {}),
          _buildMenuItem(
              theme, Icons.settings_outlined, 'الإعدادات', () {}),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
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
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
      ThemeData theme, IconData icon, String label, VoidCallback onTap) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        trailing: const Icon(Icons.chevron_left),
        onTap: onTap,
      ),
    );
  }
}

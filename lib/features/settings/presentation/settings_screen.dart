import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_time_formatter.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../admin/presentation/admin_screen.dart';
import '../../auth/data/auth_repository.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    final currentThemeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.navProfile),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Card
          if (user != null)
            AppCard(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: user.isAdmin ? AppColors.partner1 : AppColors.partner2,
                    child: Text(
                      user.name.isNotEmpty ? user.name[0] : 'U',
                      style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user.email,
                          style: const TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: user.isAdmin ? AppColors.partner1.withAlpha(25) : AppColors.partner2.withAlpha(25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            user.role.displayNameArabic,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: user.isAdmin ? AppColors.partner1 : AppColors.partner2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),

          // Working Setup Details
          if (user != null) ...[
            const Text(
              'بيانات الالتزام الخاصة بك:',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSettingRow(
                    'الساعات اليومية المطلوبة:',
                    DateTimeFormatter.formatMinutesToArabic(user.requiredDailyMinutes),
                  ),
                  const Divider(height: 16),
                  _buildSettingRow(
                    'أيام العمل الأسبوعية:',
                    '${user.workingDaysPerWeek} أيام',
                  ),
                  const Divider(height: 16),
                  _buildSettingRow(
                    'سقف النقاط اليومي:',
                    user.dailyPointsCap != null ? '${user.dailyPointsCap} نقطة' : 'بدون حد (افتراضي)',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Theme Settings
          const Text(
            'المظهر والتخصيص:',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.palette_outlined, size: 22, color: AppColors.primaryLight),
                    SizedBox(width: 12),
                    Text('وضع العرض (Theme)', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                DropdownButton<ThemeMode>(
                  value: currentThemeMode,
                  underline: const SizedBox.shrink(),
                  items: const [
                    DropdownMenuItem(value: ThemeMode.system, child: Text('تلقائي النظام')),
                    DropdownMenuItem(value: ThemeMode.light, child: Text('الوضع النهاري')),
                    DropdownMenuItem(value: ThemeMode.dark, child: Text('الوضع الليلي')),
                  ],
                  onChanged: (mode) {
                    if (mode != null) {
                      ref.read(themeModeProvider.notifier).state = mode;
                    }
                  },
                ),
              ],
            ),
          ),
          // Admin Dashboard Button (If Admin)
          if (user?.isAdmin ?? false) ...[
            const SizedBox(height: 10),
            AppButton(
              text: 'لوحة تحكم المدير وسجل التدقيق',
              icon: Icons.admin_panel_settings_rounded,
              backgroundColor: AppColors.primary,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AdminScreen()),
                );
              },
            ),
          ],
          const SizedBox(height: 20),

          // Logout Button
          AppButton(
            text: AppStrings.logout,
            icon: Icons.logout_rounded,
            backgroundColor: AppColors.danger,
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text(AppStrings.logout),
                  content: const Text(AppStrings.logoutConfirm),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text(AppStrings.cancel),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text(AppStrings.logout, style: TextStyle(color: AppColors.danger)),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await ref.read(authRepositoryProvider).signOut();
              }
            },
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSettingRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

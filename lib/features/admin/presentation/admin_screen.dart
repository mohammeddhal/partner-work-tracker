import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_time_formatter.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/offline_banner.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/domain/user_model.dart';
import 'widgets/audit_logs_tab.dart';
import 'widgets/edit_partner_dialog.dart';
import 'widgets/manual_session_dialog.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.adminDashboard),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryLight,
          labelColor: AppColors.primaryLight,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: AppStrings.partnersManagement),
            Tab(text: AppStrings.auditLogsTitle),
          ],
        ),
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 1. Partners Management Tab
                const _PartnersManagementTab(),

                // 2. Audit Logs Tab
                const AuditLogsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PartnersManagementTab extends ConsumerWidget {
  const _PartnersManagementTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(allUsersProvider);

    return usersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('خطأ: $e')),
      data: (users) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Action button to add manual session
            AppButton(
              text: AppStrings.addManualSession,
              icon: Icons.add_alarm_rounded,
              backgroundColor: AppColors.primaryLight,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const ManualSessionDialog(),
                );
              },
            ),
            const SizedBox(height: 20),

            const Text(
              'قائمة الشركاء وإعدادات الالتزام:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            ...users.map((user) => _buildPartnerCard(context, ref, user)),
          ],
        );
      },
    );
  }

  Widget _buildPartnerCard(BuildContext context, WidgetRef ref, UserModel user) {
    final reqFormatted = DateTimeFormatter.formatMinutesToArabic(user.requiredDailyMinutes);

    return AppCard(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: user.isAdmin ? AppColors.partner1 : AppColors.partner2,
                    child: Text(
                      user.name.isNotEmpty ? user.name[0] : 'U',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        user.email,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.settings_rounded, color: AppColors.primaryLight),
                tooltip: AppStrings.editPartnerSettings,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => EditPartnerDialog(user: user),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoColumn('الساعات المطلوبة:', reqFormatted),
              _buildInfoColumn('أيام العمل:', '${user.workingDaysPerWeek} أيام / أسبوعياً'),
              _buildInfoColumn('الدور:', user.role.displayNameArabic),
            ],
          ),
          if (user.dailyPointsCap != null) ...[
            const SizedBox(height: 8),
            Text(
              'سقف النقاط اليومي: ${user.dailyPointsCap} نقطة',
              style: const TextStyle(fontSize: 11, color: Colors.amber, fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

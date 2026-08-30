import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../expenses/presentation/expenses_screen.dart';
import '../../history/presentation/history_screen.dart';
import '../../reports/presentation/reports_screen.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../tasks/presentation/tasks_screen.dart';
import '../../tracker/presentation/home_screen.dart';

final selectedNavIndexProvider = StateProvider<int>((ref) => 0);

class MainNavScreen extends ConsumerWidget {
  const MainNavScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedNavIndexProvider);

    final List<Widget> screens = const [
      HomeScreen(),
      HistoryScreen(),
      TasksScreen(),
      ExpensesScreen(),
      ReportsScreen(),
      SettingsScreen(),
    ];

    final List<BottomNavigationBarItem> navItems = const [
      BottomNavigationBarItem(
        icon: Icon(Icons.timer_outlined),
        activeIcon: Icon(Icons.timer_rounded),
        label: AppStrings.navHome,
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.history_edu_outlined),
        activeIcon: Icon(Icons.history_edu_rounded),
        label: 'السجل والتدقيق',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.task_alt_outlined),
        activeIcon: Icon(Icons.task_alt_rounded),
        label: 'المهام',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.receipt_long_outlined),
        activeIcon: Icon(Icons.receipt_long_rounded),
        label: 'المشتريات',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.bar_chart_outlined),
        activeIcon: Icon(Icons.bar_chart_rounded),
        label: 'التقارير',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.manage_accounts_outlined),
        activeIcon: Icon(Icons.manage_accounts_rounded),
        label: 'الحساب',
      ),
    ];

    final safeIndex = selectedIndex >= screens.length ? 0 : selectedIndex;

    return Scaffold(
      body: IndexedStack(
        index: safeIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: safeIndex,
        onTap: (index) {
          ref.read(selectedNavIndexProvider.notifier).state = index;
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryLight,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: navItems,
      ),
    );
  }
}

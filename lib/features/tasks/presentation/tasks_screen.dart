import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/offline_banner.dart';
import '../../auth/data/auth_repository.dart';
import '../data/task_repository.dart';
import 'widgets/add_task_dialog.dart';
import 'widgets/task_list_item.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(allTasksProvider);
    final currentUser = ref.watch(currentUserProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('المهام والتكليفات'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryLight,
          labelColor: AppColors.primaryLight,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'الكل'),
            Tab(text: 'مهامي'),
            Tab(text: 'متأخرة ⚠️'),
            Tab(text: 'مكتملة ✓'),
          ],
        ),
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: tasksAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('خطأ في تحميل المهام: $e')),
              data: (tasks) {
                final myTasks = tasks.where((t) => t.assignedToId == currentUser?.id).toList();
                final overdueTasks = tasks.where((t) => t.isOverdue).toList();
                final completedTasks = tasks.where((t) => t.isCompleted).toList();
                final activeTasks = tasks.where((t) => !t.isCompleted).toList();

                return Column(
                  children: [
                    // Overview stats strip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      color: Theme.of(context).cardColor,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatCounter('الجارية', activeTasks.length.toString(), AppColors.primaryLight),
                          Container(height: 24, width: 1, color: Colors.grey.shade300),
                          _buildStatCounter('المتأخرة', overdueTasks.length.toString(), AppColors.danger),
                          Container(height: 24, width: 1, color: Colors.grey.shade300),
                          _buildStatCounter('المكتملة', completedTasks.length.toString(), AppColors.accentDark),
                        ],
                      ),
                    ),
                    const Divider(height: 1),

                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // 1. All Tasks
                          _buildTasksList(tasks, 'لا توجد مهام مسجلة حالياً.'),

                          // 2. My Tasks
                          _buildTasksList(myTasks, 'لا توجد مهام مسندة إليك حالياً.'),

                          // 3. Overdue Tasks
                          _buildTasksList(overdueTasks, 'رائع! لا توجد أي مهام متأخرة حالياً 🎉'),

                          // 4. Completed Tasks
                          _buildTasksList(completedTasks, 'لا توجد مهام مكتملة حتى الآن.'),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_task_rounded, color: Colors.white),
        label: const Text('مهمة جديدة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const AddTaskDialog(),
          );
        },
      ),
    );
  }

  Widget _buildStatCounter(String label, String count, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        Text(
          count,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildTasksList(List<dynamic> tasks, String emptyMessage) {
    if (tasks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.task_alt_rounded, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text(
                emptyMessage,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskListItem(task: task);
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../widgets/attendance_section.dart';
import '../../widgets/task_card.dart';
import '../../widgets/create_task_dialog.dart';
import '../../widgets/profile_image.dart';
import '../login/login_page.dart';
import '../profile/profile_page.dart';
import '../task_list/task_list_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Fetch tasks when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchTasks();
    });
  }

  void _fetchTasks() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final attendanceProvider = Provider.of<AttendanceProvider>(
      context,
      listen: false,
    );

    if (authProvider.isLoggedIn && authProvider.userProfile != null) {
      final employeeId = authProvider.userProfile!.employeeId;
      taskProvider.setEmployeeId(employeeId);
      attendanceProvider.setEmployeeId(employeeId);
      taskProvider.fetchTasks();
      attendanceProvider.fetchAttendance();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleLogout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final attendanceProvider = Provider.of<AttendanceProvider>(
      context,
      listen: false,
    );

    await authProvider.logout();

    // Clear session-specific mock data
    taskProvider.clearSession();
    attendanceProvider.clearSession();

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, TaskProvider>(
      builder: (context, authProvider, taskProvider, child) {
        final user = authProvider.loginUser;
        final profile = authProvider.userProfile;

        // Use profile data if available, otherwise use login user data
        final displayName = profile?.name ?? user?.name ?? 'User';
        final displayId = profile?.employeeId ?? user?.id ?? 'ID';

        return Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            backgroundColor: const Color(0xFF0d4f9d),
            elevation: 0,
            toolbarHeight: 80,
            title: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
              child: Row(
                children: [
                  CustomProfileImage(
                    imageUrl: profile?.profileImage,
                    size: 55,
                    iconSize: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          displayName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          displayId,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                onPressed: _handleLogout,
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
                tooltip: 'Logout',
              ),
            ],
          ),
          body: SingleChildScrollView(
            controller: _scrollController,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Attendance Section
                  const AttendanceSection(),
                  const SizedBox(height: 16),
                  // Daily Task List Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            child: const Icon(
                              Icons.fact_check,
                              size: 30,
                              color: Color(0xFF0d4f9d),
                            ),
                          ),
                          const Text(
                            'Daily Task List',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0d4f9d),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => const CreateTaskDialog(),
                            );
                          },
                          icon: const Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          tooltip: 'Add Task',
                        ),
                      ),
                    ],
                  ),

                  // Task Cards - from API or loading state
                  if (taskProvider.isLoading && taskProvider.tasks.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (taskProvider.tasks.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text('No tasks found'),
                      ),
                    )
                  else
                    ...taskProvider.tasks
                        .take(3)
                        .map(
                          (task) => TaskCard(
                            key: ValueKey(task.id),
                            taskId: task.id,
                            time: task.timeSlot,
                            projectName: task.description,
                            initialStatus: task.status == 'Complete'
                                ? 'Completed'
                                : task.status,
                            onEdit: () {
                              showDialog(
                                context: context,
                                builder: (context) => CreateTaskDialog(
                                  isEditing: true,
                                  taskId: task.id,
                                  initialTimeSlot: task.timeSlot,
                                  initialStatus: task.status == 'Complete'
                                      ? 'Completed'
                                      : task.status,
                                  initialDescription: task.description,
                                ),
                              );
                            },
                          ),
                        ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          bottomNavigationBar: taskProvider.tasks.isNotEmpty
              ? ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.grey.shade100.withValues(alpha: 0.8),
                            Colors.grey.shade400.withValues(alpha: 0.9),
                          ],
                        ),
                        border: Border(
                          top: BorderSide(
                            color: Colors.grey.withValues(alpha: 0.2),
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const TaskListPage(),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'View Full Task',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.black,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }
}

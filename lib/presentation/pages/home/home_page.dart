import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/rendering.dart';
import '../../widgets/attendance_section.dart';
import '../../widgets/task_card.dart';
import '../../widgets/create_task_dialog.dart';
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
  bool _isButtonVisible = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (!_isButtonVisible) {
        setState(() {
          _isButtonVisible = true;
        });
      }
    } else if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (_isButtonVisible) {
        setState(() {
          _isButtonVisible = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              Container(
                width: 55,
                height: 55,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: const Icon(
                  Icons.person,
                  size: 32,
                  color: Color(0xFF0d4f9d),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Kaniz Fatima',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'L3T2077',
                      style: TextStyle(
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
            onPressed: () {
              // Navigate to Login Page and remove all previous routes
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            color: Colors.grey[100],
            child: SingleChildScrollView(
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
                                Icons.checklist_rounded,
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

                    // Task Cards
                    TaskCard(
                      time: '10:30 - 12:00',
                      projectName: 'Project X Research',
                      initialStatus: 'Completed',
                      onEdit: () {
                        showDialog(
                          context: context,
                          builder: (context) => const CreateTaskDialog(
                            isEditing: true,
                            initialTimeSlot: '10:30 - 12:00',
                            initialStatus: 'Completed',
                            initialDescription: 'Project X Research',
                          ),
                        );
                      },
                    ),
                    TaskCard(
                      time: '02:00 - 04:30',
                      projectName: 'Client Meeting Preparation',
                      initialStatus: 'Completed',
                      onEdit: () {
                        showDialog(
                          context: context,
                          builder: (context) => const CreateTaskDialog(
                            isEditing: true,
                            initialTimeSlot: '02:00 - 04:30',
                            initialStatus: 'Completed',
                            initialDescription: 'Client Meeting Preparation',
                          ),
                        );
                      },
                    ),
                    TaskCard(
                      time: '04:30 - 06:00',
                      projectName: 'Daily Progress Report',
                      initialStatus: 'In Progress',
                      onEdit: () {
                        showDialog(
                          context: context,
                          builder: (context) => const CreateTaskDialog(
                            isEditing: true,
                            initialTimeSlot: '04:30 - 06:00',
                            initialStatus: 'In Progress',
                            initialDescription: 'Daily Progress Report',
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 25),
                  ],
                ),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            left: 0,
            right: 0,
            bottom: _isButtonVisible ? 0 : -100,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.0),
                        Colors.grey.shade400.withValues(alpha: 0.9),
                      ],
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
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'View full task',
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
          ),
        ],
      ),
    );
  }
}

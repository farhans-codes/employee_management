import 'package:flutter/material.dart';
import '../../widgets/attendance_section.dart';
import '../../widgets/task_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0d4f9d),
        elevation: 0,
        toolbarHeight: 80,
        title: Row(
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
                  SizedBox(height: 2),
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
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Implement logout
            },
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Container(
        color: Colors.grey[100],
        child: SingleChildScrollView(
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
                        onPressed: () {},
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
                    // TODO: Implement edit
                  },
                ),
                TaskCard(
                  time: '02:00 - 04:30',
                  projectName: 'Client Meeting Preparation',
                  initialStatus: 'Completed',
                  onEdit: () {
                    // TODO: Implement edit
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

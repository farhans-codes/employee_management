import 'package:flutter/material.dart';
import '../../widgets/create_task_dialog.dart';

class TaskListPage extends StatelessWidget {
  const TaskListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mocked data for at least 3 days
    final List<Map<String, dynamic>> tasks = [
      {
        'day': 'Saturday',
        'time': '09:39 AM - 11:00 AM',
        'status': 'Complete',
        'description':
            'here the task description will be written and the card will expand as the description length and this is it yah',
      },
      {
        'day': 'Saturday',
        'time': '09:39 AM - 11:00 AM',
        'status': 'Complete',
        'description':
            'here the task description will be written and the card will expand as the description length and this is it yah',
      },
      {
        'day': 'Saturday',
        'time': '09:39 AM - 11:00 AM',
        'status': 'Complete',
        'description':
            'here the task description will be written and the card will expand as the description length and this is it yah',
      },
      {
        'day': 'Sunday',
        'time': '10:00 AM - 12:00 PM',
        'status': 'In Progress',
        'description':
            'Working on the employee management system UI components and ensuring responsiveness.',
      },
      {
        'day': 'Monday',
        'time': '02:00 PM - 04:00 PM',
        'status': 'Next',
        'description': 'Daily standup meeting and progress report submission.',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF0d4f9d),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Task List',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return TaskListCard(
            day: task['day'],
            time: task['time'],
            status: task['status'],
            description: task['description'],
          );
        },
      ),
    );
  }
}

class TaskListCard extends StatelessWidget {
  final String day;
  final String time;
  final String status;
  final String description;

  const TaskListCard({
    super.key,
    required this.day,
    required this.time,
    required this.status,
    required this.description,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Complete':
      case 'Completed':
        return Colors.green[700]!;
      case 'In Progress':
        return Colors.blue[700]!;
      case 'Next':
        return Colors.orange[700]!;
      case 'Blocking':
        return Colors.red[700]!;
      default:
        return Colors.black87;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                day,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                status,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _getStatusColor(status),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            time,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            description,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[800],
              height: 1.5,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.bottomRight,
            child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => CreateTaskDialog(
                    isEditing: true,
                    initialTimeSlot: time,
                    initialStatus: status == 'Complete' ? 'Completed' : status,
                    initialDescription: description,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                child: const Icon(
                  Icons.edit_rounded,
                  size: 22,
                  color: Color(0xFF0d4f9d),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class TaskCard extends StatefulWidget {
  final String time;
  final String projectName;
  final String initialStatus;
  final VoidCallback onEdit;

  const TaskCard({
    super.key,
    required this.time,
    required this.projectName,
    required this.initialStatus,
    required this.onEdit,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  late String currentStatus;

  @override
  void initState() {
    super.initState();
    currentStatus = widget.initialStatus;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return Colors.green;
      case 'In Progress':
        return Colors.blue;
      case 'Next':
        return Colors.orange;
      case 'Blocking':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusBgColor(String status) {
    return _getStatusColor(status).withOpacity(0.1);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            child: const Icon(
              Icons.assignment_outlined,
              color: Color(0xFF0d4f9d),
              size: 30,
            ),
          ),
          const SizedBox(width: 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.time,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0d4f9d),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.projectName,
                  style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                ),
              ],
            ),
          ),
          // Interactive Status Dropdown
          PopupMenuButton<String>(
            padding: EdgeInsets.zero,
            onSelected: (String value) {
              setState(() {
                currentStatus = value;
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              _buildPopupItem('Completed'),
              _buildPopupItem('In Progress'),
              _buildPopupItem('Next'),
              _buildPopupItem('Blocking'),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              decoration: BoxDecoration(
                color: _getStatusBgColor(currentStatus),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    currentStatus,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(currentStatus),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_drop_down,
                    color: _getStatusColor(currentStatus),
                    size: 14,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: widget.onEdit,
            child: Container(
              padding: const EdgeInsets.all(8),
              child: const Icon(
                Icons.edit_outlined,
                size: 20,
                color: Color(0xFF0d4f9d),
              ),
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildPopupItem(String value) {
    return PopupMenuItem<String>(
      value: value,
      height: 35,
      child: Text(
        value,
        style: TextStyle(
          fontSize: 13,
          color: _getStatusColor(value),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

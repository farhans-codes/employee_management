import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class CreateTaskDialog extends StatefulWidget {
  final bool isEditing;
  final String? initialTimeSlot;
  final String? initialStatus;
  final String? initialDescription;
  final String? initialRemarks;

  const CreateTaskDialog({
    super.key,
    this.isEditing = false,
    this.initialTimeSlot,
    this.initialStatus,
    this.initialDescription,
    this.initialRemarks,
  });

  @override
  State<CreateTaskDialog> createState() => _CreateTaskDialogState();
}

class _CreateTaskDialogState extends State<CreateTaskDialog> {
  String? selectedTimeSlot;
  String? selectedStatus;
  late TextEditingController descriptionController;
  late TextEditingController remarksController;

  final List<String> timeSlots = [
    '09:00 - 10:30',
    '10:30 - 12:00',
    '12:00 - 01:30',
    '02:00 - 03:30',
    '03:30 - 05:00',
    '05:00 - 06:30',
  ];
  final List<String> statuses = [
    'Completed',
    'In Progress',
    'Next',
    'Blocking',
  ];

  @override
  void initState() {
    super.initState();
    selectedTimeSlot = widget.initialTimeSlot;
    selectedStatus = widget.initialStatus;
    descriptionController = TextEditingController(
      text: widget.initialDescription,
    );
    remarksController = TextEditingController(text: widget.initialRemarks);
  }

  @override
  void dispose() {
    descriptionController.dispose();
    remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isEditing ? 'Edit task' : 'Create new task',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.black,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    label: 'Time Slot*',
                    value: selectedTimeSlot,
                    items: timeSlots,
                    hint: 'Select Slot',
                    onChanged: (val) => setState(() => selectedTimeSlot = val),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDropdown(
                    label: 'Status*',
                    value: selectedStatus,
                    items: statuses,
                    hint: 'Select Status',
                    onChanged: (val) => setState(() => selectedStatus = val),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildTextField(
              label: 'Task Description*',
              hint: 'Enter task description',
              controller: descriptionController,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              label: 'Remarks',
              hint: 'Enter any remarks',
              controller: remarksController,
            ),
            const SizedBox(height: 32),
            Center(
              child: Container(
                width: 180,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'done',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required String hint,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary, width: 1.5),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: Text(
                hint,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
              ),
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.primary,
              ),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
            filled: true,
            fillColor: AppColors.background,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 2.0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

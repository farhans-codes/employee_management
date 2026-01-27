import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/task_provider.dart';
import '../../../data/models/task_model.dart';

class CreateTaskDialog extends StatefulWidget {
  final bool isEditing;
  final int? taskId;
  final String? initialTimeSlot;
  final String? initialStatus;
  final String? initialDescription;
  final String? initialRemarks;

  const CreateTaskDialog({
    super.key,
    this.isEditing = false,
    this.taskId,
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
  bool isProcessing = false;

  final List<String> timeSlots = [
    '09:00 AM - 10:30 AM',
    '09:39 AM - 11:00 AM',
    '10:30 AM - 12:00 PM',
    '12:00 PM - 01:30 PM',
    '02:00 PM - 03:30 PM',
    '03:30 PM - 05:00 PM',
    '05:00 PM - 06:30 PM',
  ];
  final List<String> statuses = [
    'Completed', // Standardized to match mock and UI mapping
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

  Future<void> _handleSave() async {
    final description = descriptionController.text.trim();
    if (selectedTimeSlot == null ||
        selectedStatus == null ||
        description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields (*)')),
      );
      return;
    }

    setState(() => isProcessing = true);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    try {
      debugPrint('Starting save operation. isEditing: ${widget.isEditing}');
      bool success = false;
      if (widget.isEditing && widget.taskId != null) {
        debugPrint('Updating existing task: ${widget.taskId}');
        success = await taskProvider.updateTask(
          widget.taskId!,
          status: selectedStatus,
          description: description,
        );
      } else {
        debugPrint('Creating new task');
        final task = TaskModel(
          id: 0,
          dayName: '',
          date: '',
          timeSlot: selectedTimeSlot!,
          status: selectedStatus!,
          description: description,
        );
        success = await taskProvider.createTask(task);
      }

      debugPrint('Operation success: $success');

      if (mounted) {
        if (success) {
          debugPrint('Success: Popping dialog');
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.isEditing ? 'Task updated' : 'Task created'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          debugPrint('Failure: ${taskProvider.errorMessage}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(taskProvider.errorMessage ?? 'Operation failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Exception in _handleSave: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isProcessing = false);
        debugPrint('isProcessing set to false');
      }
    }
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
              widget.isEditing ? 'Edit Task' : 'Create New Task',
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
                  flex: 1,
                  child: _buildDropdown(
                    label: 'Time Slot*',
                    value: selectedTimeSlot,
                    items: timeSlots,
                    hint: 'Select Slot',
                    onChanged: isProcessing
                        ? null
                        : (val) => setState(() => selectedTimeSlot = val),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: _buildDropdown(
                    label: 'Status*',
                    value: selectedStatus,
                    items: statuses,
                    hint: 'Select Status',
                    onChanged: isProcessing
                        ? null
                        : (val) => setState(() => selectedStatus = val),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildTextField(
              label: 'Task Description*',
              hint: 'Enter task description',
              controller: descriptionController,
              maxLines: 4,
              enabled: !isProcessing,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              label: 'Remarks',
              hint: 'Enter any remarks',
              controller: remarksController,
              maxLines: 2,
              enabled: !isProcessing,
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
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: isProcessing ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 0,
                  ),
                  child: isProcessing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Done',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
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
    required Function(String?)? onChanged,
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
                style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
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
    int maxLines = 1,
    bool enabled = true,
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
          maxLines: maxLines,
          enabled: enabled,
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
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

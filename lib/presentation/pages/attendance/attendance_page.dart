import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/attendance_provider.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  void _fetchData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final attendanceProvider = Provider.of<AttendanceProvider>(
      context,
      listen: false,
    );
    if (authProvider.token != null) {
      attendanceProvider.fetchAttendance(
        authProvider.token!,
        month: _selectedDate.month,
        year: _selectedDate.year,
      );
    }
  }

  void _previousMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1);
    });
    _fetchData();
  }

  void _nextMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1);
    });
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    final String monthYearStr = DateFormat('MMMM yyyy').format(_selectedDate);

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
          'Attendance',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Consumer<AttendanceProvider>(
        builder: (context, attendanceProvider, child) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 160,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!, width: 1),
                      ),
                      child: Center(
                        child: Text(
                          monthYearStr,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _previousMonth,
                          icon: const Icon(
                            Icons.chevron_left_rounded,
                            size: 30,
                          ),
                          color: const Color(0xFF0d4f9d),
                        ),
                        IconButton(
                          onPressed: _nextMonth,
                          icon: const Icon(
                            Icons.chevron_right_rounded,
                            size: 30,
                          ),
                          color: const Color(0xFF0d4f9d),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                          child: Row(
                            children: [
                              _buildTableHeader('Date', flex: 2),
                              _buildTableHeader('Day', flex: 2),
                              _buildTableHeader('In Time', flex: 2),
                              _buildTableHeader('Out Time', flex: 2),
                              _buildTableHeader('Type', flex: 2),
                            ],
                          ),
                        ),
                        const Divider(height: 1, thickness: 0.5),
                        Expanded(
                          child: attendanceProvider.isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : attendanceProvider.attendances.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No attendance data for this month',
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  itemCount:
                                      attendanceProvider.attendances.length,
                                  itemBuilder: (context, index) {
                                    final log =
                                        attendanceProvider.attendances[index];
                                    return _buildTableRow(
                                      log.date,
                                      log.dayName,
                                      log.inTime,
                                      log.outTime,
                                      log.workType,
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTableHeader(String title, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xFF0d4f9d),
        ),
      ),
    );
  }

  Widget _buildTableRow(
    String date,
    String day,
    String inTime,
    String outTime,
    String workType,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              date,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              day,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              inTime,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              outTime,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              workType,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: workType == 'Field'
                    ? Colors.blue[700]
                    : workType == 'WFH'
                    ? Colors.purple[700]
                    : workType == 'Tour'
                    ? Colors.orange[800]
                    : Colors.black87,
                fontWeight: workType != '-'
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

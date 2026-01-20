import 'package:flutter/material.dart';

class AttendanceSection extends StatefulWidget {
  const AttendanceSection({super.key});

  @override
  State<AttendanceSection> createState() => _AttendanceSectionState();
}

class _AttendanceSectionState extends State<AttendanceSection> {
  String selectedTab = 'WFH';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title OUTSIDE the card
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              child: const Icon(
                Icons.access_time_rounded,
                size: 30,
                color: Color(0xFF0d4f9d),
              ),
            ),
            const Text(
              'Attendance',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
          ],
        ),

        // Card with attendance content
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Modern Tabs - NO GRADIENT
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    _buildTab('WFH'),
                    _buildTab('Field'),
                    _buildTab('Tour'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // In/Out Buttons - NO GRADIENT
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      'Check In',
                      Icons.login_rounded,
                      const Color(0xFF4CAF50),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      'Check Out',
                      Icons.logout_rounded,
                      const Color(0xFFEF5350),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Attendance Table Header
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    _buildTableHeader('Date', flex: 2),
                    _buildTableHeader('Day', flex: 2),
                    _buildTableHeader('In Time', flex: 2),
                    _buildTableHeader('Out Time', flex: 2),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Rows
              ...List.generate(
                5,
                (index) =>
                    _buildTableRow('19-10-26', 'Sun', '09:00 AM', '06:30 PM'),
              ),

              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {},
                  icon: const Text(
                    'View Full Month',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0d4f9d),
                    ),
                  ),
                  label: const Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: Color(0xFF0d4f9d),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTab(String title) {
    final isSelected = selectedTab == title;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = title),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF0d4f9d) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTableHeader(String title, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        title,
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
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(date, style: const TextStyle(fontSize: 13)),
          ),
          Expanded(
            flex: 2,
            child: Text(day, style: const TextStyle(fontSize: 13)),
          ),
          Expanded(
            flex: 2,
            child: Text(inTime, style: const TextStyle(fontSize: 13)),
          ),
          Expanded(
            flex: 2,
            child: Text(outTime, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

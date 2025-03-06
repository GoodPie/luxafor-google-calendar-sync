import 'package:flutter/material.dart';

class StatusCard extends StatelessWidget {
  final bool isInMeeting;
  final DateTime? lastChecked;

  const StatusCard({
    Key? key,
    required this.isInMeeting,
    this.lastChecked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Status',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isInMeeting ? Colors.red : Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 16),
                Text(
                  isInMeeting ? 'In a meeting' : 'Available',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            if (lastChecked != null) ...[
              SizedBox(height: 8),
              Text(
                'Last checked: ${_formatDateTime(lastChecked!)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }
}
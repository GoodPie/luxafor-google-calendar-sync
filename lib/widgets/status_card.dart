import 'package:flutter/material.dart';

class StatusCard extends StatefulWidget {
  final bool isInMeeting;
  final String? meetingTitle;
  final DateTime? lastChecked;
  final bool statusOverride;
  final VoidCallback onOverrideToggle;
  final bool manualBusy;
  final DateTime? manualBusyUntil;
  final Function(int) onSetManualBusy;

  const StatusCard({
    Key? key,
    required this.isInMeeting,
    this.meetingTitle,
    this.lastChecked,
    required this.statusOverride,
    required this.onOverrideToggle,
    required this.manualBusy,
    this.manualBusyUntil,
    required this.onSetManualBusy,
  }) : super(key: key);

  @override
  State<StatusCard> createState() => _StatusCardState();
}

class _StatusCardState extends State<StatusCard> {
  // Preset durations in minutes for quick selection
  final List<int> _quickDurations = [15, 30, 60];

  @override
  Widget build(BuildContext context) {
    // Determine the effective status
    // Priority: manual busy > status override > calendar event
    bool effectiveStatus;
    if (widget.manualBusy) {
      effectiveStatus = true; // Manual busy takes highest priority
    } else if (widget.statusOverride) {
      effectiveStatus = false; // Override to available is second priority
    } else {
      effectiveStatus = widget.isInMeeting; // Calendar status is third priority
    }
    
    // Calculate remaining time for manual busy status
    String? remainingTime;
    if (widget.manualBusy && widget.manualBusyUntil != null) {
      final now = DateTime.now();
      final difference = widget.manualBusyUntil!.difference(now);
      
      if (difference.inSeconds > 0) {
        if (difference.inHours > 0) {
          remainingTime = '${difference.inHours}h ${difference.inMinutes.remainder(60)}m';
        } else {
          remainingTime = '${difference.inMinutes}m ${difference.inSeconds.remainder(60)}s';
        }
      }
    }
    
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
            
            // Status indicator
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: effectiveStatus ? Colors.red : Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 16),
                Text(
                  effectiveStatus ? 'Busy' : 'Available',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Spacer(),
                // Override toggle
                Row(
                  children: [
                    Text('Show as available: '),
                    Switch(
                      value: widget.statusOverride,
                      onChanged: (_) => widget.onOverrideToggle(),
                    ),
                  ],
                ),
              ],
            ),
            
            // Quick busy buttons
            SizedBox(height: 12),
            Text(
              'Mark as busy for:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 8),
            Row(
              children: [
                ..._quickDurations.map((minutes) => 
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ElevatedButton(
                      onPressed: () => widget.onSetManualBusy(minutes),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('$minutes min'),
                    ),
                  )
                ),
                // Clear button - only show when manual busy is active
                if (widget.manualBusy)
                  TextButton(
                    onPressed: () => widget.onSetManualBusy(0), // 0 clears the manual busy status
                    child: Text('Clear'),
                  ),
              ],
            ),
            
            // Show manual busy countdown if active
            if (widget.manualBusy && remainingTime != null) ...[
              SizedBox(height: 8),
              Text(
                'Busy for $remainingTime more',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            
            // Show meeting title if in a meeting
            if (widget.isInMeeting && widget.meetingTitle != null) ...[
              SizedBox(height: 12),
              Text(
                'Current meeting: ${widget.meetingTitle}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ],
            
            // Show override notice if applicable
            if (widget.isInMeeting && widget.statusOverride) ...[
              SizedBox(height: 8),
              Text(
                'Status override active: Showing as available',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            
            if (widget.lastChecked != null) ...[
              SizedBox(height: 12),
              Text(
                'Last checked: ${_formatDateTime(widget.lastChecked!)}',
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
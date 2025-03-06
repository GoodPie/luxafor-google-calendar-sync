import 'package:flutter/material.dart';

class SyncControlCard extends StatefulWidget {
  final bool isAuthenticated;
  final bool hasLuxaforId;
  final bool isSyncRunning;
  final int syncInterval;
  final Function() onStartSync;
  final Function() onStopSync;
  final Function(int) onChangeSyncInterval;

  const SyncControlCard({
    Key? key,
    required this.isAuthenticated,
    required this.hasLuxaforId,
    required this.isSyncRunning,
    required this.syncInterval,
    required this.onStartSync,
    required this.onStopSync,
    required this.onChangeSyncInterval,
  }) : super(key: key);

  @override
  _SyncControlCardState createState() => _SyncControlCardState();
}

class _SyncControlCardState extends State<SyncControlCard> {
  late int _intervalValue;

  @override
  void initState() {
    super.initState();
    _intervalValue = widget.syncInterval;
  }

  @override
  void didUpdateWidget(SyncControlCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.syncInterval != widget.syncInterval) {
      setState(() {
        _intervalValue = widget.syncInterval;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canRun = widget.isAuthenticated && widget.hasLuxaforId;
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sync Control',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            
            // Check interval slider
            Text(
              'Check interval: $_intervalValue seconds',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Slider(
              value: _intervalValue.toDouble(),
              min: 10,
              max: 300,
              divisions: 29,
              label: '$_intervalValue seconds',
              onChanged: (double value) {
                setState(() {
                  _intervalValue = value.toInt();
                });
              },
              onChangeEnd: (double value) {
                widget.onChangeSyncInterval(value.toInt());
              },
            ),
            
            SizedBox(height: 16),
            
            // Sync toggle
            Row(
              children: [
                Icon(
                  widget.isSyncRunning ? Icons.sync : Icons.sync_disabled,
                  color: widget.isSyncRunning ? Colors.green : Colors.grey,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Calendar Sync',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Switch(
                  value: widget.isSyncRunning,
                  onChanged: canRun
                      ? (value) {
                          if (value) {
                            widget.onStartSync();
                          } else {
                            widget.onStopSync();
                          }
                        }
                      : null,
                ),
              ],
            ),
            
            SizedBox(height: 8),
            
            // Status message
            Text(
              !canRun
                  ? 'Please configure Google Calendar and Luxafor User ID to enable sync.'
                  : widget.isSyncRunning
                      ? 'Sync is running. Your Luxafor flag will change based on your calendar.'
                      : 'Sync is stopped. Your Luxafor flag will not be updated.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: !canRun
                        ? Colors.orange
                        : widget.isSyncRunning
                            ? Colors.green
                            : Colors.grey,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
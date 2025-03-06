import 'package:flutter/material.dart';

class SettingsCard extends StatefulWidget {
  final bool isAuthenticated;
  final String? luxaforUserId;
  final Function() onAuthenticate;
  final Function(String) onSetLuxaforUserId;

  const SettingsCard({
    Key? key,
    required this.isAuthenticated,
    this.luxaforUserId,
    required this.onAuthenticate,
    required this.onSetLuxaforUserId,
  }) : super(key: key);

  @override
  _SettingsCardState createState() => _SettingsCardState();
}

class _SettingsCardState extends State<SettingsCard> {
  late TextEditingController _controller;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.luxaforUserId);
  }

  @override
  void didUpdateWidget(SettingsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.luxaforUserId != widget.luxaforUserId && !_isEditing) {
      _controller.text = widget.luxaforUserId ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _saveUserId() {
    setState(() {
      _isEditing = false;
    });
    widget.onSetLuxaforUserId(_controller.text);
  }

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
              'Settings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            
            // Google Authentication
            Row(
              children: [
                Icon(
                  widget.isAuthenticated ? Icons.check_circle : Icons.error,
                  color: widget.isAuthenticated ? Colors.green : Colors.orange,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Google Calendar',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                ElevatedButton(
                  onPressed: widget.onAuthenticate,
                  child: Text(widget.isAuthenticated ? 'Re-authenticate' : 'Sign In'),
                ),
              ],
            ),
            
            SizedBox(height: 24),
            
            // Luxafor User ID
            Row(
              children: [
                Icon(
                  (widget.luxaforUserId != null && widget.luxaforUserId!.isNotEmpty)
                      ? Icons.check_circle
                      : Icons.error,
                  color: (widget.luxaforUserId != null && widget.luxaforUserId!.isNotEmpty)
                      ? Colors.green
                      : Colors.orange,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Luxafor User ID',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            if (_isEditing) ...[
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Luxafor User ID',
                  helperText: 'Found in the Luxafor app under Webhook tab',
                ),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _controller.text = widget.luxaforUserId ?? '';
                        _isEditing = false;
                      });
                    },
                    child: Text('Cancel'),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _saveUserId,
                    child: Text('Save'),
                  ),
                ],
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.luxaforUserId != null && widget.luxaforUserId!.isNotEmpty
                          ? '••••••••' // Hide the actual ID for security
                          : 'Not set',
                      style: TextStyle(
                        fontStyle: widget.luxaforUserId != null && widget.luxaforUserId!.isNotEmpty
                            ? FontStyle.normal
                            : FontStyle.italic,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      setState(() {
                        _isEditing = true;
                      });
                    },
                    tooltip: 'Edit',
                  ),
                ],
              ),
            ],
            
            SizedBox(height: 8),
            Text(
              'To find your Luxafor User ID, open the Luxafor app and go to the Webhook tab.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
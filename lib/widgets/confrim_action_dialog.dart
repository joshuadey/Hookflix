import 'package:flutter/material.dart';

class ConfirmActionDialog extends StatelessWidget {
  final String title;
  final String subtitle;

  ConfirmActionDialog({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(subtitle),
      actions: <Widget>[
        ElevatedButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop(false); // Returning false when cancelled
          },
        ),
        ElevatedButton(
          child: Text('Confirm'),
          onPressed: () {
            Navigator.of(context).pop(true); // Returning true when confirmed
          },
        ),
      ],
    );
  }
}

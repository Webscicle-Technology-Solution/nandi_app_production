import 'package:flutter/material.dart';

// Reusable error dialog widget
class ErrorDialog extends StatelessWidget {
  final String errorMessage;

  const ErrorDialog({Key? key, required this.errorMessage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Error'),
      content: Text(errorMessage), // Display error message
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('OK'),
        ),
      ],
    );
  }
}

// Function to show the error dialog
void showErrorDialog(BuildContext context, String errorMessage,) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return ErrorDialog(errorMessage: errorMessage); // Use the custom error dialog
    },
  );
}

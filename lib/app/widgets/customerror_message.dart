import 'package:flutter/material.dart';
import 'dart:async';

import 'package:nandiott_flutter/utils/Device_size.dart'; // Required for Timer

// Reusable error dialog widget
class ErrorText extends StatefulWidget {
  final String errorMessage;

  const ErrorText({Key? key, required this.errorMessage}) : super(key: key);

  @override
  State<ErrorText> createState() => _ErrorTextState();
}

bool _errorState = true;

class _ErrorTextState extends State<ErrorText> {
  // late Timer _timer; // Timer variable to control the delay

  @override
  void initState() {
    super.initState();

    // Timer to hide the error message after 3 seconds
    // _timer = Timer(Duration(seconds: 5), () {
    //   // Disposing or removing the widget after 3 seconds
    //   if (mounted) {
    //     setState(() {
    //       // You can use any logic to hide or remove the widget here
    //       _errorState= false;
    //     });
    //   }
    // });
  }

  @override
  void dispose() {
    // _timer.cancel(); // Don't forget to cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _errorState ? 
    
    Text(
      textAlign: TextAlign.center,
      widget.errorMessage,
      style: TextStyle(color: Colors.red,fontSize: AppSizes.getstatusFontSize(context)),
    ):Container() ;
  }
}

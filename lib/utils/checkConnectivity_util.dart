import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nandiott_flutter/app/widgets/custombottombar.dart';

class ConnectivityUtils {
  static bool _isDialogVisible = false;

  static Future<void> showNoConnectionDialog(
    BuildContext context,


  ) async {
    if (_isDialogVisible) return;

    _isDialogVisible = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text("No Internet Connection"),
        content: Text("You are offline. Please check your connection."),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(); // Close the dialog
              await Future.delayed(Duration(milliseconds: 300));

              final resultList = await Connectivity().checkConnectivity();
              final result = resultList.isNotEmpty ? resultList.first : ConnectivityResult.none;

              if (result == ConnectivityResult.none) {
                _isDialogVisible = false;
                showNoConnectionDialog(context);
              } else {
                _isDialogVisible = false;

                // Reload the page using navigator
                // Navigator.of(context).pushAndRemoveUntil(
                //   MaterialPageRoute(builder: (_) => pageToReload),
                //   (route) => false,
                // );
              }
            },
            child: Text("Retry"),
          ),
        
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();

              _isDialogVisible = false;
            },
            child: Text("Cancel"),
          ),

        ],
      ),
    ).then((_) {
      _isDialogVisible = false;
    });
  }
}

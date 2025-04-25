import 'package:flutter/material.dart';
import 'package:nandiott_flutter/utils/Device_size.dart';
import 'package:nandiott_flutter/utils/appstyle.dart';

class PasswordWidget extends StatefulWidget {
  final TextEditingController controller; // Accept the controller as a parameter

  const PasswordWidget({super.key, required this.controller}); // Required parameter

  @override
  State<PasswordWidget> createState() => _PasswordWidgetState();
}

class _PasswordWidgetState extends State<PasswordWidget> {
  // State variable to track visibility of the password
  bool _isPasswordVisible = false;

  // Validator (optional, can be customized)
  String? validator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password cannot be empty';
    }
    return null;
  }

  // Function to handle changes in the text field
  void onChanged(String value) {
    // Handle any necessary actions when the text changes
  }

  @override
  Widget build(BuildContext context) {
        final deviceType = AppSizes.getDeviceType(context);
    final isTVDevice = deviceType == DeviceType.tv;

        final double fontSize = isTVDevice ? 20.0 : 14.0;
    final double iconSize = isTVDevice ? 30.0 : 24.0;
    final double borderRadius = isTVDevice ? 12.0 : 8.0;

    return SizedBox(
      width: isTVDevice ? 800 : null,
      child: TextFormField(
        autofocus: false,
        controller: widget.controller, // Use the passed controller
        obscureText: !_isPasswordVisible, // Toggle visibility here
        validator: validator,
        style: const TextStyle(color: Colors.black),
        onChanged: onChanged,
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.lock,
            color: AppStyles.textblack,
            size: iconSize,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible
                  ? Icons.visibility_off // Eye off icon
                  : Icons.visibility, // Eye on icon
              color: AppStyles.textblack,
              size: iconSize,
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible; // Toggle password visibility
              });
            },
          ),
          contentPadding: EdgeInsets.symmetric(
            vertical: isTVDevice ? 20 : 12,
            horizontal: isTVDevice ? 16 : 12,
          ),
          hintText: 'Password',
                    hintStyle: TextStyle(fontSize: fontSize),

          filled: true,
          fillColor: AppStyles.whiteColor,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: const BorderSide(color: AppStyles.unselectedTextColor, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: const BorderSide(color: AppStyles.primaryColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: const BorderSide(color: AppStyles.errorColor),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: const BorderSide(color: AppStyles.errorColor),
          ),
        ),
      ),
    );
  }
}

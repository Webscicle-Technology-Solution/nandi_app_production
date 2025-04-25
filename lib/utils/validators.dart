// lib/utils/validators.dart

String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Email is required';
  }
  // Simple regex for email validation
  final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  if (!emailRegExp.hasMatch(value)) {
    return 'Enter a valid email address';
  }
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Password is required';
  }
  if (value.length < 5) {
    return 'Password must be at least 5 characters long';
  }
  return null;
}

String? validateConfirmPassword(String? confirmPassword, String newPassword) {
  if (confirmPassword == null || confirmPassword.isEmpty) {
    return 'Please confirm your password';
  }
  if (confirmPassword != newPassword) {
    return 'Passwords do not match';
  }
  return null;
}

String? validateOtp(String? value) {
  if (value == null || value.isEmpty) {
    return 'OTP is required';
  }
  if (value.length != 6) {
    return 'OTP should contain 6 characters';
  }
  return null;
}

String? validatePhone(String? value) {
  if (value == null || value.isEmpty) {
    return 'Phone number is required';
  }
  
  // Check if the input contains only digits and is exactly 10 characters long
  final RegExp phoneRegExp = RegExp(r'^[0-9]{10}$');
  if (!phoneRegExp.hasMatch(value)) {
    return 'Invalid phone number';
  }

  return null; // If validation passes
}

String? validateRequired(String? value) {
  if (value == null || value.isEmpty) {
    return 'This field is required';
  }
  if (value.length < 3) {
    return 'Minimum length is 3 characters';
  }
  return null;
}
String? validateUrl(String? value) {
  // If the value is null or empty, it's valid (no URL required)
  if (value == null || value.isEmpty) {
    return null;  // No error if the value is empty or null
  } 

  // Regular expression to check if the value is a valid URL
  String pattern = r'^(https?|ftp)://[^\s/$.?#].[^\s]*$';
  RegExp regExp = RegExp(pattern);

  // If the URL doesn't match the regular expression, return an error message
  if (!regExp.hasMatch(value)) {
    return 'Please enter a valid URL';
  }

  return null;  // No error if the value is a valid URL
}
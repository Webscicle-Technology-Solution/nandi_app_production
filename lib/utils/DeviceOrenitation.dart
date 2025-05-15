// OrientationManager.dart - Centralized orientation management

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:nandiott_flutter/utils/Device_size.dart';

class OrientationManager {
  // Private constructor to prevent instantiation
  OrientationManager._();
  
  // Track whether we're in video mode to know what to restore to
  static bool _wasInPortraitMode = true;
  
  // Set default app orientation based on device type
  static void setDefaultOrientation(BuildContext context) {
    final deviceType = AppSizes.getDeviceType(context);
    
    if (deviceType == DeviceType.mobile) {
      _wasInPortraitMode = true;
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    } else {
      _wasInPortraitMode = false;
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
      ]);
    }
  }
  
  // Set video player orientation
  static void setVideoPlayerOrientation(BuildContext context, bool fullScreen) {
    // Store current mode before changing
    _wasInPortraitMode = AppSizes.getDeviceType(context) == DeviceType.mobile;
    
    if (fullScreen) {
      // When in fullscreen, always use landscape
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
      ]);
    } else if (AppSizes.getDeviceType(context) == DeviceType.mobile) {
      // Keep portrait for non-fullscreen on mobile
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    } else {
      // Allow all orientations for TV
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
      ]);
    }
  }
  
  // Restore previous orientation
  static void restorePreviousOrientation(BuildContext context) {
    if (_wasInPortraitMode) {
      forcePortrait();
    } else {
      // Allow all orientations (TV mode)
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
      ]);
    }
  }
  
  // Force landscape mode (for video playback)
  static void forceLandscape() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }
  
  // Force portrait mode (for mobile navigation)
  static void forcePortrait() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }
}
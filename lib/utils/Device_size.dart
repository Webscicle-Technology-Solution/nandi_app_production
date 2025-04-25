import 'package:flutter/material.dart';

class DeviceType {
  static const mobile = 'mobile';
  static const tv = 'tv';
}

class AppSizes {
  static String getDeviceType(BuildContext context) {
    // MediaQuery can help detect if we're on a TV
    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;

    // Check if running on Android TV
    // This is a simplified check - you might want to use a plugin like 'device_info_plus'
    // for more accurate detection
    bool isTV = size.width > 1200 ||
        Theme.of(context).platform == TargetPlatform.android &&
            size.width / size.height > 1.5;

    return isTV ? DeviceType.tv : DeviceType.mobile;
  }

  //title size
  static double getTitleFontSize(BuildContext context) {
    final deviceType = getDeviceType(context);
    return deviceType == DeviceType.tv ? 18.0 : 18.0;
  }

  // Film card sizes
  static double getFilmCardWidth(BuildContext context) {
    final deviceType = getDeviceType(context);
    return deviceType == DeviceType.tv ? 140.0 : 110.0;
  }

  //get carsoul height
  static double getbannerHeight(BuildContext context) {
    final deviceType = getDeviceType(context);
    return deviceType == DeviceType.tv ? 400.0 : 210.0;
  }

  static double getbannerWidth(BuildContext context) {
    final deviceType = getDeviceType(context);
    return deviceType == DeviceType.tv ? 140.0 : 110.0;
  }

  static double getFilmCardHeight(BuildContext context) {
    final deviceType = getDeviceType(context);
    return deviceType == DeviceType.tv ? 190.0 : 150.0;
  }

  // Icon sizes
  static double getIconSize(BuildContext context) {
    final deviceType = getDeviceType(context);
    return deviceType == DeviceType.tv ? 30.0 : 28.0;
  }

  static double getPlayIconSize(BuildContext context) {
    final deviceType = getDeviceType(context);
    return deviceType == DeviceType.tv ? 60.0 : 30.0;
  }

  // Text sizes
  static double getFilmCardFontSize(BuildContext context) {
    final deviceType = getDeviceType(context);
    return deviceType == DeviceType.tv ? 13.0 : 11.0;
  }

  // Progress bar size
  static double getProgressBarHeight(BuildContext context) {
    final deviceType = getDeviceType(context);
    return deviceType == DeviceType.tv ? 10.0 : 5.0;
  }

  // Margin and padding
  static double getCardMargin(BuildContext context) {
    final deviceType = getDeviceType(context);
    return deviceType == DeviceType.tv ? 12.0 : 5.0;
  }

  static EdgeInsets getPadding(BuildContext context) {
    final deviceType = getDeviceType(context);
    return deviceType == DeviceType.tv
        ? EdgeInsets.all(8.0)
        : EdgeInsets.all(2.0);
  }

  static double getFeaturedFilmCardHeight(BuildContext context) {
    final deviceType = getDeviceType(context);
    return deviceType == DeviceType.tv ? 500.0 : 230;
  }

  static double getCardHeight(BuildContext context) {
    final deviceType = getDeviceType(context);
    return deviceType == DeviceType.tv ? 180.0 : 100.0;
  }

  static double getImageWidth(BuildContext context) {
    final deviceType = getDeviceType(context);
    return deviceType == DeviceType.tv ? 240.0 : 135.0;
  }

  static double getImageHeight(BuildContext context) {
    final deviceType = getDeviceType(context);
    return deviceType == DeviceType.tv ? 150.0 : 85.0;
  }

  static double getContenetPadding(BuildContext context) {
    final deviceType = getDeviceType(context);
    return deviceType == DeviceType.tv ? 16.0 : 8.0;
  }

  static double getstatusFontSize(BuildContext context) {
    final deviceType = getDeviceType(context);
    return deviceType == DeviceType.tv ? 16.0 : 12.0;
  }

  static double getButtonWidth(BuildContext context) {
    final deviceType = getDeviceType(context);
    return deviceType == DeviceType.tv ? 300.0 : 180;
  }

  static double getButtonFont(BuildContext context) {
    final deviceType = getDeviceType(context);
    return deviceType == DeviceType.tv ? 28 : 20;
  }
}

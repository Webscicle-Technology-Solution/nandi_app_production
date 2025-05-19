
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Keys for SharedPreferences
const String streamQualityKey = 'stream_quality';
const String downloadQualityKey = 'download_quality';

// Enum for quality options
enum QualityType { dataSaver, mediumQuality, highQuality }

// Extension to convert enum to string
extension QualityTypeExtension on QualityType {
  String get value {
    switch (this) {
      case QualityType.dataSaver:
        return 'Data Saver';
      case QualityType.mediumQuality:
        return 'Medium Quality';
      case QualityType.highQuality:
        return 'High Quality';
    }
  }
  
  static QualityType fromString(String value) {
    switch (value) {
      case 'Data Saver':
        return QualityType.dataSaver;
      case 'Medium Quality':
        return QualityType.mediumQuality;
      case 'High Quality':
        return QualityType.highQuality;
      default:
        return QualityType.mediumQuality;
    }
  }
}

// Provider for Stream Quality
final streamQualityProvider = StateNotifierProvider<QualityNotifier, QualityType>(
  (ref) => QualityNotifier(QualityType.mediumQuality, streamQualityKey),
);

// Provider for Download Quality
final downloadQualityProvider = StateNotifierProvider<QualityNotifier, QualityType>(
  (ref) => QualityNotifier(QualityType.mediumQuality, downloadQualityKey),
);

// StateNotifier to manage quality settings
class QualityNotifier extends StateNotifier<QualityType> {
  final String preferenceKey;

  QualityNotifier(QualityType initialState, this.preferenceKey)
      : super(initialState) {
    _loadFromPreferences();
  }

  Future<void> _loadFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final savedQuality = prefs.getString(preferenceKey);
    if (savedQuality != null) {
      state = QualityTypeExtension.fromString(savedQuality);
    } else {
      await _saveQualityToPreferences(state); // Save default if not found
    }
  }

  Future<void> updateQuality(QualityType quality) async {
    state = quality;
    await _saveQualityToPreferences(quality);
  }

  Future<void> _saveQualityToPreferences(QualityType quality) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(preferenceKey, quality.value);

    int resolution;
    switch (quality) {
      case QualityType.dataSaver:
        resolution = 480;
        break;
      case QualityType.mediumQuality:
        resolution = 720;
        break;
      case QualityType.highQuality:
        resolution = 1080;
        break;
      }

    await prefs.setInt(streamQualityKey, resolution);
    await prefs.setInt(downloadQualityKey, resolution);
  }
}

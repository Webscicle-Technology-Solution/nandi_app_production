import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider to track the currently expanded card data
final expandedCardProvider = StateProvider<Map<String, dynamic>>((ref) => {});
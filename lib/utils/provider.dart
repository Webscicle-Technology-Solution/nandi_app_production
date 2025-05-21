import 'dart:io';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

final remoteConfigProvider = Provider<FirebaseRemoteConfig>((ref) {
  final config = FirebaseRemoteConfig.instance;
  return config;
});

final updateCheckProvider = FutureProvider<String?>((ref) async {
  final config = ref.read(remoteConfigProvider);

  await config.setConfigSettings(RemoteConfigSettings(
    fetchTimeout: const Duration(seconds: 5),
    minimumFetchInterval: const Duration(seconds: 0), // Always fetch fresh for testing
  ));
  await config.fetchAndActivate();

  final minVersionCode = config.getInt('min_required_version');
  final androidUrl = config.getString('update_url_android');
  final iosUrl = config.getString('update_url_ios');
 
  final packageInfo = await PackageInfo.fromPlatform();
  final currentVersionCode = int.parse(packageInfo.buildNumber);

  if (currentVersionCode < minVersionCode) {
    return Platform.isAndroid ? androidUrl : iosUrl;
  }

  return null;
});

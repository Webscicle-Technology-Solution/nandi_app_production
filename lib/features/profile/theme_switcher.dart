import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nandiott_flutter/app/theme/theme_provider.dart';
class ThemeSwitcherPage extends ConsumerWidget {
  const ThemeSwitcherPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeNotifier = ref.watch(themeProvider.notifier);

    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ListTile(
            title: const Text('Light Theme',),
            leading: Radio<AppTheme>(
              value: AppTheme.light,
              groupValue: ref.watch(themeProvider),
              onChanged: (value) {
                themeNotifier.setLightTheme();
              },
              activeColor: const Color(0xFFE99C05),
            ),
          ),
          ListTile(
            title: const Text('Dark Theme',),
            leading: Radio<AppTheme>(
              value: AppTheme.dark,
              groupValue: ref.watch(themeProvider),
              onChanged: (value) {
                themeNotifier.setDarkTheme();
              },
              activeColor: const Color(0xFFE99C05),
            ),
          ),
          ListTile(
            title: const Text('System Theme'),
            leading: Radio<AppTheme>(
              value: AppTheme.system,
              groupValue: ref.watch(themeProvider),
              onChanged: (value) {
                themeNotifier.setSystemTheme();
              },
              activeColor: const Color(0xFFE99C05),
            ),
          ),
        ],
      );
  }
}

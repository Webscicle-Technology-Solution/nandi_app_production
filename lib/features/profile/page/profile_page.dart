import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:nandiott_flutter/features/auth/page/loginpage_tv.dart';
import 'package:nandiott_flutter/features/profile/page/account_settings_page.dart';
import 'package:nandiott_flutter/features/profile/page/help-support_page.dart';
import 'package:nandiott_flutter/features/profile/page/quality_switcher_page.dart';
import 'package:nandiott_flutter/features/profile/page/theme_switcher.dart';
import 'package:nandiott_flutter/features/profile/page/watchHistory_page.dart';
import 'package:nandiott_flutter/features/profile/widget/wishlist_widget.dart';
import 'package:nandiott_flutter/features/profile/widget/yellowBorder_container_widget.dart';
import 'package:nandiott_flutter/features/auth/providers/checkauth_provider.dart';
import 'package:nandiott_flutter/features/profile/provider/favourite_provider.dart';
import 'package:nandiott_flutter/features/rental_download/provider/rental_provider.dart';
import 'package:nandiott_flutter/services/auth_service.dart';
import 'package:nandiott_flutter/utils/Device_size.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    ref.invalidate(authUserProvider);
    ref.refresh(authUserProvider);
    ref.refresh(rentalProvider);
  }

  @override
  void initState() {
    ref.refresh(authUserProvider);
    ref.refresh(rentalProvider);
    // TODO: implement initState
    super.initState();
  }
    final bool isIos = Platform.isIOS;

  @override
  Widget build(BuildContext context) {
    ref.watch(rentalProvider);
    final isdark = Theme.of(context).brightness == Brightness.dark;

    final authUser = ref.watch(authUserProvider);
    final authService = AuthService(); // Assuming you have an instance
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                'My Wishlist',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),
            WishlistWidget(),
            const SizedBox(height: 30),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                'Theme',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),
            const ThemeSwitcherPage(),
            const SizedBox(height: 20),
            const YellowborderContainer(
              title: 'Watch History',
              page: WatchHistoryPage(),
            ),
            const YellowborderContainer(
              title: 'Account Settings',
              page: AccountSettingsPage(),
            ),
             YellowborderContainer(
              title: isIos? 'Stream Quality':'Stream & Download Quality',
              page: QualitySwitcherPage(isIos),
            ),
            const YellowborderContainer(
              title: 'Help & Support',
              page: HelpSupportPage(),
            ),
            authUser.when(
              data: (authUser) {
                if (authUser != null) {
                  return YellowborderContainer(
                    title: 'Logout',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 8,
                            backgroundColor: Colors.transparent,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: isdark
                                    ? const LinearGradient(
                                        colors: [
                                          Color.fromARGB(255, 39, 39, 39),
                                          Color.fromARGB(255, 33, 33, 33)
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : const LinearGradient(
                                        colors: [
                                          Color.fromARGB(255, 255, 255, 255),
                                          Color.fromARGB(255, 255, 255, 255)
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.logout,
                                      size: 50,
                                      color: Color.fromARGB(255, 227, 175, 33),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Confirm Logout',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: isdark
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Are you sure you want to logout?',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: const Color.fromARGB(
                                            255, 255, 74, 74),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        // Cancel Button with Focus Indicator and Remote Key Handling
                                        FocusableActionDetector(
                                          autofocus:
                                              true, // First button gets initial focus
                                          actions: <Type, Action<Intent>>{
                                            ActivateIntent:
                                                CallbackAction<ActivateIntent>(
                                              onInvoke: (intent) {
                                                Navigator.of(context).pop();
                                                return null;
                                              },
                                            ),
                                          },
                                          onShowFocusHighlight: (focused) {
                                            // Additional logic if needed when focus changes
                                          },
                                          child: Builder(
                                            builder: (context) {
                                              final bool hasFocus =
                                                  Focus.of(context).hasFocus;
                                              final bool isTv =
                                                  AppSizes.getDeviceType(
                                                          context) ==
                                                      DeviceType.tv;

                                              return InkWell(
                                                onTap: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: AnimatedContainer(
                                                  duration: const Duration(
                                                      milliseconds: 200),
                                                  decoration: BoxDecoration(
                                                    color: hasFocus && isTv
                                                        ? isdark
                                                            ? Colors.white
                                                            : Colors.black
                                                        : Colors.transparent,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 24,
                                                      vertical: 14),
                                                  child: Text(
                                                    'Cancel',
                                                    style: TextStyle(
                                                      color: Colors.amber,
                                                      fontWeight: hasFocus &&
                                                              isTv
                                                          ? FontWeight.bold
                                                          : FontWeight.normal,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),

                                        // Logout Button with Focus Indicator and Remote Key Handling
                                        FocusableActionDetector(
                                          actions: <Type, Action<Intent>>{
                                            ActivateIntent:
                                                CallbackAction<ActivateIntent>(
                                              onInvoke: (intent) async {
                                                Navigator.of(context).pop();
                                                await Future.delayed(
                                                    const Duration(
                                                        milliseconds: 300));
                                                try {
                                                  await authService.logout();
                                                } catch (e) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                        content: Text(
                                                            'Logout failed: $e')),
                                                  );
                                                }
                                                return null;
                                              },
                                            ),
                                          },
                                          onShowFocusHighlight: (focused) {
                                            // Additional logic if needed when focus changes
                                          },
                                          child: Builder(
                                            builder: (context) {
                                              final bool hasFocus =
                                                  Focus.of(context).hasFocus;

                                              return InkWell(
                                                onTap: () async {
                                                  Navigator.of(context).pop();

                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              const LoginScreen()));

                                                  await Future.delayed(
                                                      const Duration(
                                                          milliseconds: 300));
                                                  try {
                                                    await authService.logout();

                                                    ref.invalidate(
                                                        authUserProvider);
                                                  } catch (e) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                          content: Text(
                                                              'Logout failed: $e')),
                                                    );
                                                  }
                                                },
                                                child: AnimatedContainer(
                                                  duration: const Duration(
                                                      milliseconds: 200),
                                                  decoration: BoxDecoration(
                                                    color: hasFocus
                                                        ? isdark
                                                            ? Colors.white
                                                            : Colors.black
                                                        : Colors.transparent,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 24,
                                                      vertical: 14),
                                                  child: Text(
                                                    'Logout',
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                      fontWeight: hasFocus
                                                          ? FontWeight.bold
                                                          : FontWeight.normal,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                } else {
                  return YellowborderContainer(
                    title: "Login",
                    onPressed: () async {
                      final result = await Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()));
                      if (result == true) {
                        ref.invalidate(authUserProvider);
                        ref.invalidate(favoritesProvider);
                      }
                    },
                  ); // No user
                }
              },
              loading: () => const CircularProgressIndicator(), // or SizedBox()
              error: (e, _) => Text("Error: $e"),
            ),
            YellowborderContainer(
              title: 'Privacy Policy',
              onPressed: () async {
                Uri url = Uri.parse(
                    "https://movie.nandipictures.com/privacy-policy/");
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.inAppBrowserView);
                } else {
                  throw 'Could not launch $url';
                }
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

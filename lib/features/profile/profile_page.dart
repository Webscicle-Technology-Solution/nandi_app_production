import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';  // Import Riverpod
import 'package:nandiott_flutter/app/theme/theme_provider.dart';
import 'package:nandiott_flutter/app/widgets/customappbar.dart';
import 'package:nandiott_flutter/features/auth/loginpage_tv.dart';
import 'package:nandiott_flutter/features/profile/account_settings/account_settings_page.dart';
import 'package:nandiott_flutter/features/profile/help-support_page.dart';
import 'package:nandiott_flutter/features/profile/quality_switcher_page.dart';
import 'package:nandiott_flutter/features/profile/theme_switcher.dart';
import 'package:nandiott_flutter/features/profile/watchHistory/watchHistory_page.dart';
import 'package:nandiott_flutter/features/profile/wishlist_widget.dart';
import 'package:nandiott_flutter/features/profile/yellowBorder_container.dart';
import 'package:nandiott_flutter/providers/checkauth_provider.dart';
import 'package:nandiott_flutter/providers/favourite_provider.dart';
import 'package:nandiott_flutter/services/auth_service.dart';
import 'package:nandiott_flutter/utils/Device_size.dart';

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
  }

  @override
  Widget build(BuildContext context) {

    final isdark = Theme.of(context).brightness == Brightness.dark;

      final authUser=ref.watch(authUserProvider);
print("authuser in logout ui is ${authUser}");
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
            YellowborderContainer(
              title: 'Watch History',
              page: const WatchHistoryPage(),
            ),
            YellowborderContainer(
              title: 'Account Settings',
              page: const AccountSettingsPage(),
            ),
            YellowborderContainer(
              title: 'Stream & Download Quality ',
              page: const QualitySwitcherPage(),
            ),
            YellowborderContainer(
              title: 'Help & Support',
              page: const HelpSupportPage(),
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
          gradient: isdark? LinearGradient(
            colors: [const Color.fromARGB(255, 39, 39, 39), const Color.fromARGB(255, 33, 33, 33)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ):LinearGradient(
            colors: [const Color.fromARGB(255, 255, 255, 255), const Color.fromARGB(255, 255, 255, 255)],
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
              Icon(
                Icons.logout,
                size: 50,
                color: const Color.fromARGB(255, 227, 175, 33),
              ),
              const SizedBox(height: 16),
              Text(
                'Confirm Logout',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isdark?Colors.white:Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to logout?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: const Color.fromARGB(255, 255, 74, 74),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Cancel Button with Focus Indicator and Remote Key Handling
                  FocusableActionDetector(
                    autofocus: true, // First button gets initial focus
                    actions: <Type, Action<Intent>>{
                      ActivateIntent: CallbackAction<ActivateIntent>(
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
                        final bool hasFocus = Focus.of(context).hasFocus;
                        final bool isTv = AppSizes.getDeviceType(context) == DeviceType.tv;
                        
                        return InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: hasFocus && isTv ? isdark? Colors.white:Colors.black:Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24, 
                              vertical: 14
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: Colors.amber,
                                fontWeight: hasFocus && isTv? FontWeight.bold : FontWeight.normal,
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
                      ActivateIntent: CallbackAction<ActivateIntent>(
                        onInvoke: (intent) async {
                          Navigator.of(context).pop();
                          await Future.delayed(const Duration(milliseconds: 300));
                          try {
                            await authService.logout();
                            
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Logout failed: $e')),
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
                        final bool hasFocus = Focus.of(context).hasFocus;
                        
                        return InkWell(
                          onTap: () async {
                            Navigator.of(context).pop();
                            
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginScreen())
                            );
                            
                            await Future.delayed(const Duration(milliseconds: 300));
                            try {
                              await authService.logout();
                              
                              ref.invalidate(authUserProvider);
                              
                         
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Logout failed: $e')),
                              );
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: hasFocus? isdark ? Colors.white:Colors.black:Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24, 
                              vertical: 14
                            ),
                            child: Text(
                              'Logout',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: hasFocus ? FontWeight.bold : FontWeight.normal,
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
      return  YellowborderContainer(title: "Login",onPressed: () async{
        final result = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LoginScreen()));
        if(result == true){
          ref.invalidate(authUserProvider);
          ref.invalidate(favoritesProvider);
          
        }
      },); // No user
    }
  },
  loading: () => const CircularProgressIndicator(), // or SizedBox()
  error: (e, _) => Text("Error: $e"),
),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

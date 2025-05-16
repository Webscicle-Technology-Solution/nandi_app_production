import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nandiott_flutter/app/widgets/custombottombar.dart';
import 'package:nandiott_flutter/features/auth/loginpage_tv.dart';
import 'package:nandiott_flutter/features/profile/watchHistory/watchHistory_provider.dart';
import 'package:nandiott_flutter/providers/checkauth_provider.dart';
import 'package:nandiott_flutter/providers/favourite_provider.dart';
import 'package:nandiott_flutter/providers/subscription_provider.dart';
import 'package:nandiott_flutter/services/auth_service.dart';

class DeleteAccountButton extends ConsumerWidget {
  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton.icon(
      onPressed: () async {
        // Show first confirmation dialog
        bool? confirmDelete = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Theme.of(context).primaryColorLight,
              title: Icon(
                Icons.delete_forever,
                color: Colors.redAccent,
                size: 40.0,
              ),
              titlePadding: EdgeInsets.all(20),
              content: Text(
                "Are you sure you want to delete your account? This action cannot be undone.",
                style: TextStyle(
                  color: Theme.of(context).primaryColorDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(false); // User cancels
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.redAccent,
                  ),
                  child: Text("Cancel"),
                ),
                SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(true); // User confirms
                    Navigator.of(context).pop(true); // User confirms
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.amber[700],
                  ),
                  child: Text("Confirm"),
                ),
              ],
            );
          },
        );

        // If user confirms the deletion
        if (confirmDelete == true) {
          // Show second dialog for temporary deactivation message
          bool? tempConfirm = await showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: Theme.of(context).primaryColorLight,
                title: Icon(
                  Icons.info_outline,
                  color: Colors.blueAccent,
                  size: 40.0,
                ),
                titlePadding: EdgeInsets.all(20),
                // content: Text(
                //   "Your account has been temporarily deactivated. If you log in within the next 7 days, you'll be able to recover it. After 7 days, it will be permanently deleted.",
                // style: TextStyle(
                //   color: Theme.of(context).primaryColorDark,
                //   fontSize: 16,
                //   fontWeight: FontWeight.w600,
                // ),
                // ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your account will be scheduled for deletion. During the next 7 days:',
                      style: TextStyle(
                        color: Theme.of(context).primaryColorDark,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• Your account will be deactivated and hidden',
                      style: TextStyle(
                        color: Theme.of(context).primaryColorDark,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '• You can cancel deletion by logging back in',
                      style: TextStyle(
                        color: Theme.of(context).primaryColorDark,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '• After 7 days, your account and all data will be permanently deleted',
                      style: TextStyle(
                        color: Theme.of(context).primaryColorDark,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(true); // User presses "Okay"
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.amber[700],
                    ),
                    child: Text("Okay"),
                  ),
                ],
              );
            },
          );

          if (tempConfirm == true) {
            try {
              // Important: Navigate FIRST before invalidating the token or logging out
              // This prevents the "invalid refresh token" issue

              final navigator = Navigator.of(context);

              // Navigate to the login screen or bottom navigation
              final result = await navigator.push(
                MaterialPageRoute(builder: (context) => LoginScreen()),
                // (route) => false, // Remove all previous routes
              );
              if (result == true) {
                ref.invalidate(authUserProvider);
                ref.invalidate(subscriptionProvider(
                  SubscriptionDetailParameter(userId: ""),
                ));
                ref.invalidate(favoritesProvider);
                ref.invalidate(favoritesWithDetailsProvider);
                ref.invalidate(watchHistoryProvider);
              } else {
                ref.invalidate(authUserProvider);
                ref.invalidate(subscriptionProvider(
                  SubscriptionDetailParameter(userId: ""),
                ));
                ref.invalidate(favoritesProvider);
                ref.invalidate(favoritesWithDetailsProvider);
                ref.invalidate(watchHistoryProvider);
              }

              // AFTER navigation is triggered, handle logout and provider invalidation
              // Adding a slight delay to ensure navigation happens first
              Future.delayed(Duration(milliseconds: 100), () {
                // Here you would call your backend to mark the account for deletion
                // await authService.deleteAccountTemporarily();

                // Log out the user
                authService.logout().then((_) {
                  // Invalidate the auth provider to reflect logged out state
                  ref.invalidate(authUserProvider);
                }).catchError((e) {
                  print("Logout error (handled silently): $e");
                  // We don't show an error here since the user is already navigated away
                });
              });
            } catch (e) {
              // This will only catch navigation errors, not logout errors
              print("Navigation error: $e");
            }
          }
        }
      },
      icon: Icon(Icons.delete),
      label: Text("Delete Account"),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.redAccent),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

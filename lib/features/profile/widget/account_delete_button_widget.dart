import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nandiott_flutter/app/widgets/custombottombar.dart';
import 'package:nandiott_flutter/features/profile/provider/watchHistory_provider.dart';
import 'package:nandiott_flutter/features/auth/providers/checkauth_provider.dart';
import 'package:nandiott_flutter/features/profile/provider/favourite_provider.dart';
import 'package:nandiott_flutter/features/subscription_payment/provider/subscription_provider.dart';
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
            ref.read(selectedIndexProvider.notifier).state =
                0; // index 0 for Home Page
            try {
              // Important: Navigate FIRST before invalidating the token or logging out
              // This prevents the "invalid refresh token" issue
              Navigator.of(context).pop();

              final navigator = Navigator.of(context);
              navigator.pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const ResponsiveNavigation()),
                (route) => false,
              );

              // AFTER navigation is triggered, handle logout and provider invalidation
              // Adding a slight delay to ensure navigation happens first
              Future.delayed(Duration(milliseconds: 100), () {
                // Here you would call your backend to mark the account for deletion
                // await authService.deleteAccountTemporarily();

                // Log out the user
                authService.logout().then((_) {
                  ref.invalidate(authUserProvider);
                  ref.invalidate(subscriptionProvider(
                    SubscriptionDetailParameter(userId: ""),
                  ));
                  ref.invalidate(favoritesProvider);
                  ref.invalidate(favoritesWithDetailsProvider);
                  ref.invalidate(watchHistoryProvider);
                }).catchError((e) {
                  // We don't show an error here since the user is already navigated away
                });
              });
            } catch (e) {
              // This will only catch navigation errors, not logout errors
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

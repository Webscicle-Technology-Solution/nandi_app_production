import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nandiott_flutter/app/widgets/customappbar.dart';
import 'package:nandiott_flutter/features/auth/page/loginpage_tv.dart';
import 'package:nandiott_flutter/features/profile/widget/account_delete_button_widget.dart';
import 'package:nandiott_flutter/features/profile/provider/watchHistory_provider.dart';
import 'package:nandiott_flutter/features/subscription_payment/page/subscriptionplan_page.dart';
import 'package:nandiott_flutter/features/auth/providers/checkauth_provider.dart';
import 'package:nandiott_flutter/features/profile/provider/favourite_provider.dart';
import 'package:nandiott_flutter/features/subscription_payment/provider/subscription_provider.dart';
import 'package:nandiott_flutter/utils/Device_size.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountSettingsPage extends ConsumerStatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  ConsumerState<AccountSettingsPage> createState() =>
      _AccountSettingsPageState();
}

class _AccountSettingsPageState extends ConsumerState<AccountSettingsPage> {
  final bool isIos = Platform.isIOS;
  bool isButtonFocused = false;
  bool isUpgradePlanFocused = false;
  bool isDeleteAccountFocused = false;

  // For TV remote navigation

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // loginFocusNode.dispose();
    super.dispose();
  }

  Widget _buildMobileLayout(
      dynamic user, AsyncValue<dynamic> subscriptionAsyncValue) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Center(
              // child: CustomProfilePic(
              //   imagepath: "assets/images/profile.jpeg",
              //   onTap: () {},
              // ),
              child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                image: DecorationImage(
                    image: AssetImage("assets/images/profile.jpeg"))),
          )),
          const SizedBox(height: 30),
          const Text("Name:", style: TextStyle(fontSize: 16)),
          const SizedBox(height: 5),
          Row(
            children: [
              const SizedBox(width: 30),
              Expanded(
                child: Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          const Text("Email:", style: TextStyle(fontSize: 16)),
          const SizedBox(height: 5),
          Row(
            children: [
              const SizedBox(width: 30),
              Expanded(
                child: Text(
                  user.email,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          const Text("Phone:", style: TextStyle(fontSize: 16)),
          const SizedBox(height: 5),
          Row(
            children: [
              const SizedBox(width: 30),
              Expanded(
                child: Text(
                  user.phone,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          isIos
              ? SizedBox.shrink()
              : Text("Subscription Plan:", style: TextStyle(fontSize: 16)),
          isIos ? SizedBox.shrink() : const SizedBox(height: 5),
          isIos
              ? SizedBox.shrink()
              : subscriptionAsyncValue.when(
                  data: (subscription) {
                    return Row(
                      children: [
                        const SizedBox(width: 30),
                        Expanded(
                          child: Text(
                            subscription?.subscriptionType.name ??
                                'No subscription found',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // iOS-specific behavior: Show Popup for iOS users
                        if (isIos)
                          TextButton(
                            onPressed: () {
                              // Show a dialog instead of modal
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text("Subscription Unavailable"),
                                  content: Text(
                                    "In-app subscriptions are not available on iOS.\nPlease visit our website to subscribe.",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        const url =
                                            'https://nandipictures.in/app'; // Replace with your real link
                                        if (await canLaunchUrl(
                                            Uri.parse(url))) {
                                          await launchUrl(Uri.parse(url),
                                              mode: LaunchMode
                                                  .externalApplication);
                                        } else {
                                          // Show error if URL can't be launched
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    "Could not launch website")),
                                          );
                                        }
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("Go to Website"),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: Text(
                              "Upgrade Plan",
                              style: TextStyle(
                                color: Colors.amber,
                                fontSize: AppSizes.getstatusFontSize(context),
                              ),
                            ),
                          ),
                        // For non-iOS users, show Upgrade button to change plan
                        if (!isIos &&
                            subscription?.subscriptionType.name != "Gold")
                          TextButton(
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) => SubscriptionPlanModal(
                                  userId: user.id,
                                  movieId: "",
                                ),
                              );
                            },
                            child: Text(
                              "Upgrade Plan",
                              style: TextStyle(
                                color: Colors.amber,
                                fontSize: AppSizes.getstatusFontSize(context),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) {
                    return const Text('Failed to load subscription data');
                  },
                ),
          const SizedBox(height: 60),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [DeleteAccountButton()],
          ),
          const SizedBox(height: 30)
        ],
      ),
    );
  }

  // TV layout - two-column design
  Widget _buildTvLayout(
      dynamic user, AsyncValue<dynamic> subscriptionAsyncValue) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column - Profile Image
        Expanded(
          flex: 1,
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.transparent,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(8.0),
                // child: CustomProfilePic(
                //   imagepath: "assets/images/film-thumb.jpg",
                //   onTap: () {},
                // ),
                child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                image: DecorationImage(
                    image: AssetImage("assets/images/profile.jpeg"))),
          )
              ),
              const SizedBox(height: 20),
              Text(
                user.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: subscriptionAsyncValue.when(
                  data: (subscription) => Text(
                    subscription?.subscriptionType.name ?? 'No Plan',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  loading: () => const Text(
                    'Loading...',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  error: (_, __) => const Text(
                    'No Plan',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Vertical Divider
        Container(
          width: 1,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          color: Colors.grey.withOpacity(0.3),
        ),

        // Right Column - User Details
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                "Account Information",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              _buildInfoRow("Name", user.name),
              const SizedBox(height: 20),
              _buildInfoRow("Email", user.email),
              const SizedBox(height: 20),
              _buildInfoRow("Phone", user.phone),
              const SizedBox(height: 20),
              subscriptionAsyncValue.when(
                data: (subscription) => _buildInfoRow("Subscription",
                    subscription?.subscriptionType.name ?? 'No subscription'),
                loading: () => _buildInfoRow("Subscription", "Loading..."),
                error: (_, __) =>
                    _buildInfoRow("Subscription", "Failed to load"),
              ),
              const SizedBox(height: 30),
              subscriptionAsyncValue.when(
                data: (subscription) {
                  if (subscription?.subscriptionType.name != "Gold") {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        decoration: BoxDecoration(
                          color: isUpgradePlanFocused
                              ? Colors.amber.withOpacity(0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: isUpgradePlanFocused
                                ? Colors.amber
                                : Colors.transparent,
                            width: 2.0,
                          ),
                        ),
                        child: TextButton(
                          onFocusChange: (value) {
                            setState(() {
                              isUpgradePlanFocused = value;
                            });
                          },
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => SubscriptionPlanModal(
                                userId: user.id,
                                movieId: "",
                              ),
                            );
                          },
                          child: Text(
                            "Upgrade Plan",
                            style: TextStyle(
                              color: Colors.amber,
                              fontSize: AppSizes.getstatusFontSize(context),
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            "$label:",
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final userAsyncValue = ref.watch(authUserProvider);
    final isTv = AppSizes.getDeviceType(context) == DeviceType.tv;

    return Scaffold(
      appBar: const CustomAppBar(
        showBackButton: true,
        title: 'Account Settings',
        showActionIcon: false,
      ),
      body: Padding(
        padding: EdgeInsets.all(isTv ? 50.0 : 20.0),
        child: userAsyncValue.when(
          data: (user) {
            if (user != null) {
              final subscriptionAsyncValue = ref.watch(
                subscriptionProvider(
                  SubscriptionDetailParameter(userId: user.id),
                ),
              );

              // Choose layout based on device type
              if (isTv) {
                // Option 1: Two-column layout for TV
                return _buildTvLayout(user, subscriptionAsyncValue);

                // Option 2: If you prefer scrollable layout for TV
                // return _buildScrollableTvLayout(user, subscriptionAsyncValue);
              } else {
                // Mobile layout - original UI
                return _buildMobileLayout(user, subscriptionAsyncValue);
              }
            } else {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "No user data found. Please log in.",
                      style: TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.amber, width: 2),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: ElevatedButton(
                        onFocusChange: (value) {
                          setState(() {
                            // loginFocusNode.hasFocus;
                            isButtonFocused = value;
                          });
                        },
                        onPressed: () async {
                          // Navigate to login
                          final loginResult = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginScreen()),
                          );

                          if (loginResult == true) {
                            ref.invalidate(authUserProvider);
                            ref.invalidate(subscriptionProvider(
                              SubscriptionDetailParameter(userId: ""),
                            ));
                                 ref.invalidate(favoritesProvider);
                            ref.invalidate(favoritesWithDetailsProvider);
                            ref.invalidate(watchHistoryProvider);
                          }else{
                            ref.invalidate(authUserProvider);
                            ref.invalidate(subscriptionProvider(
                              SubscriptionDetailParameter(userId: ""),
                            ));
                                 ref.invalidate(favoritesProvider);
                            ref.invalidate(favoritesWithDetailsProvider);
                            ref.invalidate(watchHistoryProvider);

                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                          backgroundColor: isButtonFocused && isTv
                              ? Colors.amber
                              : Theme.of(context)
                                  .primaryColorLight, // fallback default
                        ),
                        child: Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 16,
                            color: isButtonFocused && isTv
                                ? Colors.black
                                : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) {
            return const Center(
              child: Text("An error occurred while fetching user data."),
            );
          },
        ),
      ),
    );
  }
}

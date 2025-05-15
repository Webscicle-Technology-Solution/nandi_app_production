import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nandiott_flutter/app/widgets/customappbar.dart';
import 'package:nandiott_flutter/app/widgets/customprofilepic.dart';
import 'package:nandiott_flutter/features/auth/loginpage_tv.dart';
import 'package:nandiott_flutter/pages/subscriptionplan_page.dart';
import 'package:nandiott_flutter/providers/checkauth_provider.dart';
import 'package:nandiott_flutter/providers/subscription_provider.dart';
import 'package:nandiott_flutter/utils/Device_size.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountSettingsPage extends ConsumerStatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  ConsumerState<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends ConsumerState<AccountSettingsPage> {
  final ScrollController _scrollController = ScrollController();
  final FocusNode _containerFocusNode = FocusNode();
  final FocusNode profileFocusNode = FocusNode();
  final FocusNode upgradePlanFocusNode = FocusNode();
  final FocusNode loginFocusNode = FocusNode();

  final bool isIos = Platform.isIOS;



  
  // For TV remote navigation
  int _currentFocusIndex = 0;
  final List<FocusNode> _focusNodes = [];
  final double _scrollAmount = 100.0;

  @override
  void initState() {
    super.initState();
    _focusNodes.add(profileFocusNode);
    _focusNodes.add(upgradePlanFocusNode);
    
    // Set initial focus for TV
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isTv = AppSizes.getDeviceType(context) == DeviceType.tv;
      if (isTv) {
        FocusScope.of(context).requestFocus(_focusNodes[0]);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _containerFocusNode.dispose();
    for (var node in _focusNodes) {
      node.dispose();
    }
    loginFocusNode.dispose();
    super.dispose();
  }

  void _moveFocus(int direction) {
    setState(() {
      _currentFocusIndex = (_currentFocusIndex + direction) % _focusNodes.length;
      if (_currentFocusIndex < 0) _currentFocusIndex = _focusNodes.length - 1;
      FocusScope.of(context).requestFocus(_focusNodes[_currentFocusIndex]);
    });
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        _scrollController.animateTo(
          _scrollController.offset + _scrollAmount,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        _scrollController.animateTo(
          _scrollController.offset - _scrollAmount,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  // Mobile layout - original UI
  // Widget _buildMobileLayout(dynamic user, AsyncValue<dynamic> subscriptionAsyncValue) {
  //   return SingleChildScrollView(
  //     controller: _scrollController,
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         const SizedBox(height: 20),
  //         Center(
  //           child: CustomProfilePic(
  //             imagepath: "assets/images/film-thumb.jpg",
  //             onTap: () {},
  //           ),
  //         ),
  //         const SizedBox(height: 30),
  //         const Text("Name:", style: TextStyle(fontSize: 16)),
  //         const SizedBox(height: 5),
  //         Row(
  //           children: [
  //             const SizedBox(width: 30),
  //             Expanded(
  //               child: Text(
  //                 user.name,
  //                 style: const TextStyle(
  //                   fontSize: 16, 
  //                   fontWeight: FontWeight.bold
  //                 ),
  //                 overflow: TextOverflow.ellipsis,
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 25),
  //         const Text("Email:", style: TextStyle(fontSize: 16)),
  //         const SizedBox(height: 5),
  //         Row(
  //           children: [
  //             const SizedBox(width: 30),
  //             Expanded(
  //               child: Text(
  //                 user.email,
  //                 style: const TextStyle(
  //                   fontSize: 16, 
  //                   fontWeight: FontWeight.bold
  //                 ),
  //                 overflow: TextOverflow.ellipsis,
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 25),
  //         const Text("Phone:", style: TextStyle(fontSize: 16)),
  //         const SizedBox(height: 5),
  //         Row(
  //           children: [
  //             const SizedBox(width: 30),
  //             Expanded(
  //               child: Text(
  //                 user.phone,
  //                 style: const TextStyle(
  //                   fontSize: 16, 
  //                   fontWeight: FontWeight.bold
  //                 ),
  //                 overflow: TextOverflow.ellipsis,
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 25),
  //         const Text("Subscription Plan :",
  //             style: TextStyle(fontSize: 16)),
  //         const SizedBox(height: 5),
  //         subscriptionAsyncValue.when(
  //           data: (subscription) {
  //             return Row(
  //               children: [
  //                 const SizedBox(width: 30),
  //                 Expanded(
  //                   child: Text(
  //                     subscription?.subscriptionType.name ??
  //                         'No subscription found',
  //                     style: const TextStyle(
  //                       fontSize: 16, 
  //                       fontWeight: FontWeight.bold
  //                     ),
  //                     overflow: TextOverflow.ellipsis,
  //                   ),
  //                 ),
  //                 if (subscription?.subscriptionType.name != "Gold")
  //                   TextButton(
  //                     onPressed: () {
  //                       showModalBottomSheet(
  //                         context: context,
  //                         isScrollControlled: true,
  //                         backgroundColor: Colors.transparent,
  //                         builder: (_) => SubscriptionPlanModal(
  //                           userId: user.id,
  //                           movieId: "",
  //                         ),
  //                       );
  //                     },
  //                     child: Text(
  //                       "Upgrade Plan",
  //                       style: TextStyle(
  //                         color: Colors.amber,
  //                         fontSize: AppSizes.getstatusFontSize(context),
  //                       ),
  //                     ),
  //                   ),
  //               ],
  //             );
  //           },
  //           loading: () => const Center(child: CircularProgressIndicator()),
  //           error: (error, stack) {
  //             print("Error fetching subscription data: $error");
  //             return const Text('Failed to load subscription data');
  //           },
  //         ),
  //         const SizedBox(height: 50),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildMobileLayout(dynamic user, AsyncValue<dynamic> subscriptionAsyncValue) {
  return SingleChildScrollView(
    controller: _scrollController,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Center(
          child: CustomProfilePic(
            imagepath: "assets/images/film-thumb.jpg",
            onTap: () {},
          ),
        ),
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
        const Text("Subscription Plan:", style: TextStyle(fontSize: 16)),
        const SizedBox(height: 5),
        subscriptionAsyncValue.when(
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
                                const url = 'https://nandipictures.in/app'; // Replace with your real link
                                if (await canLaunchUrl(Uri.parse(url))) {
                                  await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                                } else {
                                  // Show error if URL can't be launched
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Could not launch website")),
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
                if (!isIos && subscription?.subscriptionType.name != "Gold")
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
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) {
            print("Error fetching subscription data: $error");
            return const Text('Failed to load subscription data');
          },
        ),
        const SizedBox(height: 50),
      ],
    ),
  );
}


  // TV layout - two-column design
  Widget _buildTvLayout(dynamic user, AsyncValue<dynamic> subscriptionAsyncValue) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column - Profile Image
        Expanded(
          flex: 1,
          child: Column(
            children: [
              Focus(
                focusNode: profileFocusNode,
                onFocusChange: (hasFocus) {
                  if (hasFocus) {
                    _currentFocusIndex = 0;
                  }
                },
                onKey: (node, event) {
                  if (event is RawKeyDownEvent) {
                    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
                      _moveFocus(1);
                      return KeyEventResult.handled;
                    }
                  }
                  return KeyEventResult.ignored;
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: profileFocusNode.hasFocus ? Colors.amber : Colors.transparent,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: CustomProfilePic(
                    imagepath: "assets/images/film-thumb.jpg",
                    onTap: () {},
                  ),
                ),
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
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                data: (subscription) => _buildInfoRow(
                  "Subscription", 
                  subscription?.subscriptionType.name ?? 'No subscription'
                ),
                loading: () => _buildInfoRow("Subscription", "Loading..."),
                error: (_, __) => _buildInfoRow("Subscription", "Failed to load"),
              ),
              const SizedBox(height: 30),
              subscriptionAsyncValue.when(
                data: (subscription) {
                  if (subscription?.subscriptionType.name != "Gold") {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Focus(
                        focusNode: upgradePlanFocusNode,
                        onFocusChange: (hasFocus) {
                          if (hasFocus) {
                            _currentFocusIndex = 1;
                          }
                        },
                        onKey: (node, event) {
                          if (event is RawKeyDownEvent) {
                            if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                              _moveFocus(-1);
                              return KeyEventResult.handled;
                            }
                          }
                          return KeyEventResult.ignored;
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: upgradePlanFocusNode.hasFocus ? Colors.amber.withOpacity(0.2) : Colors.transparent,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: upgradePlanFocusNode.hasFocus ? Colors.amber : Colors.transparent,
                              width: 2.0,
                            ),
                          ),
                          child: TextButton(
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

  // TV layout with keyboard navigation for scrolling
  Widget _buildScrollableTvLayout(dynamic user, AsyncValue<dynamic> subscriptionAsyncValue) {
    return RawKeyboardListener(
      focusNode: _containerFocusNode,
      autofocus: true,
      onKey: _handleKeyEvent,
      child: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: CustomProfilePic(
                    imagepath: "assets/images/film-thumb.jpg",
                    onTap: () {},
                  ),
                ),
                const SizedBox(height: 30),
                const Center(
                  child: Text(
                    "Use UP/DOWN arrow keys to scroll",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
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
                          fontWeight: FontWeight.bold
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
                          fontWeight: FontWeight.bold
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
                          fontWeight: FontWeight.bold
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                const Text("Subscription Plan :",
                    style: TextStyle(fontSize: 16)),
                const SizedBox(height: 5),
                subscriptionAsyncValue.when(
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
                              fontWeight: FontWeight.bold
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (subscription?.subscriptionType.name != "Gold")
                          Focus(
                            focusNode: upgradePlanFocusNode,
                            child: TextButton(
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
                      ],
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) {
                    print("Error fetching subscription data: $error");
                    return const Text('Failed to load subscription data');
                  },
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
          // Visual indicators for scrolling
          Positioned(
            top: 10,
            right: 10,
            child: Icon(
              Icons.keyboard_arrow_up,
              color: Colors.grey.withOpacity(0.7),
              size: 32,
            ),
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: Icon(
              Icons.keyboard_arrow_down,
              color: Colors.grey.withOpacity(0.7),
              size: 32,
            ),
          ),
        ],
      ),
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
                    Focus(
                      focusNode: loginFocusNode,
                      autofocus: isTv,
                      
                      child: Container(
                      decoration: BoxDecoration(
                        border: loginFocusNode.hasFocus && isTv
                            ? Border.all(color: Colors.amber, width: 3)
                            : null,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ElevatedButton(
                        onFocusChange: (value) {
                      setState(() {
                        loginFocusNode.hasFocus;
                      });
                    },
                    onPressed: () async {
                      // Navigate to login
                      final loginResult = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                  
                      if (loginResult == true) {
                        ref.invalidate(authUserProvider);
                            ref.invalidate(subscriptionProvider(
                              SubscriptionDetailParameter(userId: ""),
                            ));
                      }
                    },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                          backgroundColor: loginFocusNode.hasFocus
                              ? Colors.amber
                              : null,
                        ),
                        child: Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 16,
                            color: loginFocusNode.hasFocus
                                ? Colors.black
                                : null,
                          ),
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
            print("Error fetching user data: $error");
            return const Center(
              child: Text("An error occurred while fetching user data."),
            );
          },
        ),
      ),
    );
  }
}
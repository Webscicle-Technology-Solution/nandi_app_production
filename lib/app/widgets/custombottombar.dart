
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nandiott_flutter/app/widgets/customappbar.dart';
import 'package:nandiott_flutter/features/home/filter_container_widget.dart';
import 'package:nandiott_flutter/features/home/pages/home_page.dart';
import 'package:nandiott_flutter/features/home/pages/tv_home_page.dart';
import 'package:nandiott_flutter/features/profile/profile_page.dart';
import 'package:nandiott_flutter/features/rental_download/download_page.dart';
import 'package:nandiott_flutter/pages/rental_page.dart';
import 'package:nandiott_flutter/pages/search_page.dart';
import 'package:nandiott_flutter/pages/tv_searchPage.dart';
import 'package:nandiott_flutter/utils/Device_size.dart';

final selectedIndexProvider = StateProvider<int>((ref) => 0);
final isNavigationExpandedProvider = StateProvider<bool>((ref) => false);

// Add this provider to track whether we're at the left edge of content
final isAtContentLeftEdgeProvider = StateProvider<bool>((ref) => false);

class ResponsiveNavigation extends ConsumerStatefulWidget {
  const ResponsiveNavigation({Key? key}) : super(key: key);

  @override
  _ResponsiveNavigationState createState() => _ResponsiveNavigationState();
}

class _ResponsiveNavigationState extends ConsumerState<ResponsiveNavigation> {
  final FocusNode _navigationFocusNode = FocusNode();
  final GlobalKey _navigationKey = GlobalKey(debugLabel: 'navigationMenuKey');
  final GlobalKey _contentKey = GlobalKey(debugLabel: 'contentAreaKey');

  @override
  void initState() {
    super.initState();

    // Set up focus listener
    _navigationFocusNode.addListener(_onNavigationFocusChange);

    // Schedule a post-frame callback to set up directional focus
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupDirectionalFocus();
    });
  }

  void _onNavigationFocusChange() {
    // This only updates the UI when navigation gets/loses focus
    // but doesn't auto-expand
    setState(() {});
  }

  void _setupDirectionalFocus() {
    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;

    ServicesBinding.instance?.keyboard.addHandler((KeyEvent event) {
      if (event is! RawKeyDownEvent) return false;

      final currentFocus = FocusManager.instance.primaryFocus;

      // When exiting navigation menu, check if we're on MyRentalPage and user is null
      if (_isWithinNavigation(currentFocus) &&
          event.logicalKey == LogicalKeyboardKey.arrowRight) {
        // We're going from navigation to content
        final selectedIndex = ref.read(selectedIndexProvider);
        final screens =
            _getScreens(AppSizes.getDeviceType(context) == DeviceType.tv);

        // If we're going to MyRentalsPage, check after a slight delay
        if (screens[selectedIndex] is MyRentalPage) {
          // Let navigation handle the right arrow key, but also schedule a login button focus check
          Future.delayed(Duration(milliseconds: 100), () {
            // Find login_button focus node
            FocusNode? loginButton;
            FocusManager.instance.rootScope.descendants.forEach((node) {
              if (node.debugLabel == 'login_button') {
                loginButton = node;
              }
            });

            // If login button exists, focus it
            if (loginButton != null) {
              loginButton!.requestFocus();
            }
          });
        }
      }

      // Skip the rest of the navigation handler for login button
      if (currentFocus?.debugLabel == 'login_button') {
        if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
          return false; // Let normal focus handling work
        }
        return false; // Let the login button handle other keys
      }

      // If we're in the content area and press Left at the edge,
      // Special handling for MyRentalPage login button
      if (currentFocus?.debugLabel == 'login_button') {
        // Let the login button handle its own focus
        return false;
      }
      // // we should focus on the navigation menu
      // if (_isWithinContent(currentFocus) &&
      //     event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      //   // Check if we're at the left edge of content
      //   final RenderBox? renderBox =
      //       currentFocus?.context?.findRenderObject() as RenderBox?;
      //   if (renderBox != null) {
      //     final position = renderBox.localToGlobal(Offset.zero);
      //     // If close to the left edge, move focus to navigation
      //     if (position.dx < 150) {
      //       _navigationFocusNode.requestFocus();
      //       return true;
      //     }
      //   }
      // }
      if (_isWithinContent(currentFocus) && 
    event.logicalKey == LogicalKeyboardKey.arrowLeft &&
    ref.read(selectedIndexProvider) == 0) { // Only for Home page
  // Check if we're at the left edge of content
  final RenderBox? renderBox = currentFocus?.context?.findRenderObject() as RenderBox?;
  if (renderBox != null) {
    final position = renderBox.localToGlobal(Offset.zero);
    // If close to the left edge, move focus to navigation
    if (position.dx < 150) {
      _navigationFocusNode.requestFocus();
      return true;
    }
  }
  return false; // Let other handlers process the event
}

      // Handle filter items as before
      if (_isWithinFilterItems(currentFocus)) {
        // Your existing code for filter items
        return false;
      }

      // Don't interfere with any other events
      return false;
    });
  }

  bool _isWithinFilterItems(FocusNode? node) {
    if (node == null) return false;
    final context = node.context;
    if (context == null) return false;

    // Check if the focused widget is a FilterContainer
    return context.widget is FilterContainer;
  }

  // The rest of the helper methods remain the same...
  bool _isWithinNavigation(FocusNode? node) {
    // Same implementation as before
    if (node == null) return false;
    final BuildContext? context = node.context;
    if (context == null) return false;
    bool isInNavigation = false;
    context.visitAncestorElements((element) {
      if (element.widget.key == _navigationKey) {
        isInNavigation = true;
        return false; // Stop visiting
      }
      return true; // Continue visiting
    });
    return isInNavigation;
  }

  bool _isWithinContent(FocusNode? node) {
    // Same implementation as before
    if (node == null) return false;
    final BuildContext? context = node.context;
    if (context == null) return false;
    bool isInContent = false;
    context.visitAncestorElements((element) {
      if (element.widget.key == _contentKey) {
        isInContent = true;
        return false; // Stop visiting
      }
      return true; // Continue visiting
    });
    return isInContent;
  }

  @override
  void dispose() {
    _navigationFocusNode.removeListener(_onNavigationFocusChange);
    _navigationFocusNode.dispose();
    super.dispose();
  }

  // Screens corresponding to navigation items
  List<Widget> _getScreens(bool isTV) => [
        isTV? TVHomePage():HomePage(),
        isTV ? TVSearchPage() : DownloadsPage(),
        MyRentalPage(),
        ProfilePage(),
      ];

  // Navigation items based on device type
  List<NavigationItem> _getNavigationItems(bool isTV) => [
        NavigationItem(icon: Icons.home, label: 'Home'),
        isTV
            ? NavigationItem(icon: Icons.search, label: 'Search')
            : NavigationItem(icon: Icons.download, label: 'Downloads'),
        NavigationItem(
            icon: Icons.movie_creation_outlined, label: 'My Rentals'),
        NavigationItem(icon: Icons.person, label: 'Profile'),
      ];

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(selectedIndexProvider);
    final isNavigationExpanded = ref.watch(isNavigationExpandedProvider);
    final isTV = AppSizes.getDeviceType(context) == DeviceType.tv;
    final navigationItems = _getNavigationItems(isTV);

    // Create a focus node for the main content area
    final contentFocusNode = FocusNode(debugLabel: 'contentArea');

    void _onItemTapped(int index) {
      ref.read(selectedIndexProvider.notifier).state = index;
      // Close navigation after selection on TV
      if (isTV) {
        ref.read(isNavigationExpandedProvider.notifier).state = false;
        // Move focus to content area
        contentFocusNode.requestFocus();
      }
    }

    // Back button logic
    Future<bool> _onWillPop() async {
      if (isNavigationExpanded) {
        ref.read(isNavigationExpandedProvider.notifier).state = false;
        return false;
      }
      if (selectedIndex == 0) {
        return true;
      } else {
        ref.read(selectedIndexProvider.notifier).state = 0;
        return false;
      }
    }

    // In the build method of _ResponsiveNavigationState

    if (isTV) {
      // For TV layout
      return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          body: FocusTraversalGroup(
            // policy: DirectionalFocusTraversalPolicy(),
            child: Row(
              children: [
                // Navigation menu
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: isNavigationExpanded ? 250 : 60,
                  color: Theme.of(context)
                      .scaffoldBackgroundColor
                      .withOpacity(0.9),
                  child: isNavigationExpanded
                      ? _buildExpandedNavigation(context, selectedIndex,
                          _onItemTapped, navigationItems)
                      : _buildCollapsedNavigation(context),
                ),

                // Main content area with explicit traversal scope
                Expanded(
                  child: FocusTraversalGroup(
                    // policy: ,
                    child: Focus(
                      focusNode: contentFocusNode,
                      key: _contentKey,
                      child: _getScreens(isTV)[selectedIndex],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      // For mobile layout - unchanged
      return Scaffold(
        appBar: CustomAppBar(),
        body: _getScreens(isTV)[selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          iconSize: 28,
          currentIndex: selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          items: navigationItems
              .map((item) => BottomNavigationBarItem(
                    icon: Icon(item.icon),
                    label: item.label,
                  ))
              .toList(),
        ),
      );
    }
  }

  Widget _buildCollapsedNavigation(BuildContext context) {
    return Focus(
      focusNode: _navigationFocusNode,
      canRequestFocus: true,
      debugLabel: 'navigation_collapsed_button',
      onFocusChange: (hasFocus) {
        if (mounted) setState(() {});
      },
      onKey: (node, event) {
        // Only expand when OK/Enter/Select is pressed
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.select ||
              event.logicalKey == LogicalKeyboardKey.enter) {
            ref.read(isNavigationExpandedProvider.notifier).state = true;
            return KeyEventResult.handled;
          }

          // Allow right arrow to navigate back to login button when on MyRentalPage
          if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            final selectedIndex = ref.read(selectedIndexProvider);
            final screens =
                _getScreens(AppSizes.getDeviceType(context) == DeviceType.tv);

            if (screens[selectedIndex] is MyRentalPage) {
              // Try to find and focus the login button
              FocusNode? loginButton;
              FocusManager.instance.rootScope.descendants.forEach((node) {
                if (node.debugLabel == 'login_button') {
                  loginButton = node;
                }
              });

              if (loginButton != null) {
                loginButton!.requestFocus();
                return KeyEventResult.handled;
              }
            }
          }

          // Prevent loss of focus with other keys
          if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
              event.logicalKey == LogicalKeyboardKey.arrowUp ||
              event.logicalKey == LogicalKeyboardKey.arrowDown) {
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: InkWell(
onTap: () {
  ref.read(isNavigationExpandedProvider.notifier).state = true;
},
        child: Container(
          width: 60,
          color: _navigationFocusNode.hasFocus
              ? Theme.of(context).scaffoldBackgroundColor.withOpacity(1)
              : Theme.of(context).scaffoldBackgroundColor.withOpacity(0.9),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: _navigationFocusNode.hasFocus
                        ? Colors.amber
                        : Colors.grey.withOpacity(0.5),
                    width: _navigationFocusNode.hasFocus ? 3 : 1,
                  ),
                ),
                child: Icon(
                  Icons.menu,
                  color: _navigationFocusNode.hasFocus
                      ? Colors.amber
                      : Theme.of(context).primaryColorDark,
                  size: 30,
                ),
              ),
              SizedBox(height: 10),
              if (_navigationFocusNode.hasFocus)
                Column(
                  children: [
                    Icon(
                      Icons.keyboard_arrow_right,
                      color: Colors.amber,
                      size: 24,
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Press OK",
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedNavigation(BuildContext context, int selectedIndex,
      Function(int) onTap, List<NavigationItem> navigationItems) {
    // Expanded navigation remains mostly the same
    return FocusTraversalGroup(
      policy: WidgetOrderTraversalPolicy(),
      child: Container(
        key: _navigationKey, // Add key for identification
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Logo Area
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.play_circle_filled,
                      size: 40,
                      color: Colors.amber,
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Nandi OTT",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColorDark,
                      ),
                    ),
                  ],
                ),
              ),

              Divider(color: Colors.grey.withOpacity(0.3)),
              SizedBox(height: 20),

              // Navigation Items
              Expanded(
                child: ListView.builder(
                  itemCount: navigationItems.length,
                  itemBuilder: (context, index) {
                    final isSelected = index == selectedIndex;
                    final item = navigationItems[index];

                    return ExpandedNavItem(
                      icon: item.icon,
                      label: item.label,
                      isSelected: isSelected,
                      onTap: () => onTap(index),
                      // Auto-select the first item to help with focus
                      autofocus: isSelected,
                      // Handle right key navigation
                      onRightKey: () {
                        ref.read(isNavigationExpandedProvider.notifier).state =
                            false;
                      },
                    );
                  },
                ),
              ),

              // Close navigation hint
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Icon(Icons.keyboard_arrow_left,
                        color: Theme.of(context)
                            .primaryColorDark
                            .withOpacity(0.5)),
                    SizedBox(width: 10),
                    Text(
                      "Press BACK to exit menu",
                      style: TextStyle(
                        color:
                            Theme.of(context).primaryColorDark.withOpacity(0.5),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// New widget to detect when we're at the left edge of content
class ContentLeftEdgeDetector extends StatefulWidget {
  final Widget child;
  final Function(bool) onLeftEdgeReached;

  const ContentLeftEdgeDetector({
    Key? key,
    required this.child,
    required this.onLeftEdgeReached,
  }) : super(key: key);

  @override
  _ContentLeftEdgeDetectorState createState() =>
      _ContentLeftEdgeDetectorState();
}

class _ContentLeftEdgeDetectorState extends State<ContentLeftEdgeDetector> {
  bool _isAtLeftEdge = false;

  @override
  void initState() {
    super.initState();

    // Listen for focus changes in the app
    FocusManager.instance.addListener(_checkContentEdge);
  }

  @override
  void dispose() {
    FocusManager.instance.removeListener(_checkContentEdge);
    super.dispose();
  }

  // Check if the current focus is at the left edge of content
  void _checkContentEdge() {
    final node = FocusManager.instance.primaryFocus;
    if (node == null) return;

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      if (!mounted) return;

      bool isAtEdge = _isNodeAtLeftEdge(node);
      if (isAtEdge != _isAtLeftEdge) {
        setState(() {
          _isAtLeftEdge = isAtEdge;
        });
        widget.onLeftEdgeReached(isAtEdge);
      }
    });
  }

  // Helper to determine if a node is at the left edge of content
  bool _isNodeAtLeftEdge(FocusNode node) {
    // This is just a basic implementation - in a real TV app,
    // you would need to check if there are no more focusable elements
    // to the left of the current focused element

    // For simplicity, we'll simulate this behavior
    final context = node.context;
    if (context == null) return false;

    // Get position of current focused element
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return false;

    // Get position in global coordinates
    final position = renderBox.localToGlobal(Offset.zero);

    // Consider it at the left edge if it's less than 100px from the left
    return position.dx < 100;
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class ExpandedNavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onRightKey;
  final bool autofocus;

  const ExpandedNavItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.onRightKey,
    this.autofocus = false,
  }) : super(key: key);

  @override
  State<ExpandedNavItem> createState() => _ExpandedNavItemState();
}

class _ExpandedNavItemState extends State<ExpandedNavItem> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(debugLabel: 'nav_item_${widget.label}');

    if (widget.autofocus) {
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check if this is the Home item (or first item)
    final isFirstItem = widget.label == 'Home';
    // Check if this is the Profile item (or last item)
    final isLastItem = widget.label == 'Profile';

    return Focus(
      focusNode: _focusNode,
      onFocusChange: (hasFocus) {
        setState(() {});
      },
      onKey: (node, event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.select ||
              event.logicalKey == LogicalKeyboardKey.enter) {
            widget.onTap();
            return KeyEventResult.handled;
          }

          // Handle right key navigation
          if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            widget.onRightKey();
            return KeyEventResult.handled;
          }

          // Block left arrow key within navigation items
          if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            return KeyEventResult.handled;
          }

          // Block up arrow key if this is the Home/first item
          if (isFirstItem && event.logicalKey == LogicalKeyboardKey.arrowUp) {
            return KeyEventResult.handled;
          }

          // Block down arrow key if this is the Profile/last item
          if (isLastItem && event.logicalKey == LogicalKeyboardKey.arrowDown) {
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: InkWell(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: widget.isSelected
                ? Colors.amber.withOpacity(0.2)
                : _focusNode.hasFocus
                    ? Colors.grey.withOpacity(0.2)
                    : Colors.transparent,
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                size: 28,
                color: widget.isSelected || _focusNode.hasFocus
                    ? Colors.amber
                    : Theme.of(context).primaryColorDark.withOpacity(0.5),
              ),
              const SizedBox(width: 20),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight:
                      widget.isSelected ? FontWeight.bold : FontWeight.normal,
                  color: widget.isSelected || _focusNode.hasFocus
                      ? Colors.amber
                      : Theme.of(context).primaryColorDark,
                ),
              ),
              Spacer(),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: _focusNode.hasFocus ? Colors.amber : Colors.transparent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Navigation item model
class NavigationItem {
  final IconData icon;
  final String label;

  NavigationItem({required this.icon, required this.label});
}

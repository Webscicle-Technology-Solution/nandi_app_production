import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nandiott_flutter/app/widgets/customappbar.dart';
import 'package:nandiott_flutter/features/profile/provider/quailty_provider.dart';
import 'package:nandiott_flutter/utils/Device_size.dart';

class QualitySwitcherPage extends ConsumerStatefulWidget {
  final bool isIos;
  const QualitySwitcherPage(this.isIos, {Key? key}) : super(key: key);

  @override
  _QualitySwitcherPageState createState() => _QualitySwitcherPageState();
}

class _QualitySwitcherPageState extends ConsumerState<QualitySwitcherPage> {
  // FocusNodes for each quality option
  late List<FocusNode> _focusNodes;
  int _currentFocusIndex = 0;
  
  // Add a scroll controller to handle automatic scrolling
  late ScrollController _scrollController;
  
  // Keep track of option widgets to calculate positions for scrolling
  final List<GlobalKey> _optionKeys = List.generate(6, (_) => GlobalKey());

  @override
  void initState() {
    super.initState();
    // Initializing FocusNodes for each quality option
    _focusNodes = List.generate(6, (index) => FocusNode());
    _scrollController = ScrollController();
    
    // Request focus on the first item after the widget builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    // Disposing FocusNodes to avoid memory leaks
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  // This method handles scrolling to make the focused item visible
  void _scrollToFocusedItem() {
    // Ensure the build method has completed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      // Get the RenderBox of the currently focused option
      final RenderBox? renderBox = _optionKeys[_currentFocusIndex]
          .currentContext
          ?.findRenderObject() as RenderBox?;
          
      if (renderBox == null) return;
      
      // Get the position of the option widget within the ListView
      final position = renderBox.localToGlobal(Offset.zero);
      final size = renderBox.size;
      
      // Convert that position to the scroll view's coordinate system
      final ScrollPosition scrollPosition = _scrollController.position;
      final double viewportHeight = scrollPosition.viewportDimension;
      
      // Calculate if the item is partially or fully out of view
      final double topOfItem = position.dy;
      final double bottomOfItem = position.dy + size.height;
      
      // Get the viewport boundaries
      final double viewportTop = scrollPosition.pixels;
      final double viewportBottom = viewportTop + viewportHeight;
      
      // Ensure the item is visible
      if (topOfItem < viewportTop + 60) { // Add a small buffer (60px) at the top
        // Scroll up to show the item at the top with some padding
        _scrollController.animateTo(
          scrollPosition.pixels - (viewportTop - topOfItem + 60),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else if (bottomOfItem > viewportBottom - 60) { // Buffer at the bottom too
        // Scroll down to show the item at the bottom with some padding
        _scrollController.animateTo(
          scrollPosition.pixels + (bottomOfItem - viewportBottom + 60),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  KeyEventResult _handleKeyEvent(FocusNode node, RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        setState(() {
          _currentFocusIndex = (_currentFocusIndex + 1) % 6;
          _focusNodes[_currentFocusIndex].requestFocus();
          _scrollToFocusedItem();
        });
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        setState(() {
          _currentFocusIndex = (_currentFocusIndex - 1 + 6) % 6;
          _focusNodes[_currentFocusIndex].requestFocus();
          _scrollToFocusedItem();
        });
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.select ||
               event.logicalKey == LogicalKeyboardKey.enter) {
        _onSelectQuality();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  // Method to handle the selection of a quality
  void _onSelectQuality() {
    if (_currentFocusIndex < 3) {
      final selectedQuality = QualityType.values[_currentFocusIndex];
      ref.read(streamQualityProvider.notifier).updateQuality(selectedQuality);
    } else {
      final selectedQuality = QualityType.values[_currentFocusIndex - 3];
      ref.read(downloadQualityProvider.notifier).updateQuality(selectedQuality);
    }
  }

  @override
  Widget build(BuildContext context) {
    final streamQuality = ref.watch(streamQualityProvider);
    final downloadQuality = ref.watch(downloadQualityProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Quality Selector',
        showBackButton: true,
        showActionIcon: false,
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                'Stream Quality',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),
            // Stream Quality Options
            buildQualityOption(
              context,
              'Data Saver',
              streamQuality == QualityType.dataSaver,
              () => ref.read(streamQualityProvider.notifier).updateQuality(QualityType.dataSaver),
              0,
            ),
            buildQualityOption(
              context,
              'Medium Quality',
              streamQuality == QualityType.mediumQuality,
              () => ref.read(streamQualityProvider.notifier).updateQuality(QualityType.mediumQuality),
              1,
            ),
            buildQualityOption(
              context,
              'High Quality',
              streamQuality == QualityType.highQuality,
              () => ref.read(streamQualityProvider.notifier).updateQuality(QualityType.highQuality),
              2,
            ),
            const SizedBox(height: 20),
            if (!widget.isIos) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                'Download Quality',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),
            // Download Quality Options
            buildQualityOption(
              context,
              'Data Saver',
              downloadQuality == QualityType.dataSaver,
              () => ref.read(downloadQualityProvider.notifier).updateQuality(QualityType.dataSaver),
              3,
            ),
            buildQualityOption(
              context,
              'Medium Quality',
              downloadQuality == QualityType.mediumQuality,
              () => ref.read(downloadQualityProvider.notifier).updateQuality(QualityType.mediumQuality),
              4,
            ),
            buildQualityOption(
              context,
              'High Quality',
              downloadQuality == QualityType.highQuality,
              () => ref.read(downloadQualityProvider.notifier).updateQuality(QualityType.highQuality),
              5,
            ),
            ],
            // Add some bottom padding to ensure the last item can be properly scrolled to
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget buildQualityOption(
    BuildContext context,
    String title,
    bool isSelected,
    VoidCallback onChanged,
    int index,
  ) {
    final istv = AppSizes.getDeviceType(context) == DeviceType.tv;
    return Focus(
      focusNode: _focusNodes[index],
      onKey: _handleKeyEvent,
      child: Builder(
        builder: (context) {
          final hasFocus = Focus.of(context).hasFocus;
          return Container(
            key: _optionKeys[index],
            child: GestureDetector(
              onTap: onChanged,
              child: Container(
                decoration: istv? BoxDecoration(
                  color: hasFocus ? const Color(0xFFE99C05).withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: hasFocus
                      ? Border.all(color: const Color(0xFFE99C05), width: 2)
                      : null,
                ):null,
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: ListTile(
                  title: Text(
                    title,
                    style: TextStyle(
                      fontWeight: hasFocus&&istv ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  leading: Radio(
                    value: title,
                    groupValue: isSelected ? title : null,
                    onChanged: (_) => onChanged(),
                    activeColor: const Color(0xFFE99C05),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
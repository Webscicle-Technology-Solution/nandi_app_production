import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nandiott_flutter/utils/Device_size.dart';
import 'package:nandiott_flutter/utils/appstyle.dart';

class YellowborderContainer extends StatefulWidget {
  final String title;
  final Widget? page;
  final VoidCallback? onPressed;

  const YellowborderContainer({
    super.key,
    required this.title,
    this.page,
    this.onPressed,
  });

  @override
  _YellowborderContainerState createState() => _YellowborderContainerState();
}

class _YellowborderContainerState extends State<YellowborderContainer> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.page != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => widget.page!,
        ),
      );
    } else if (widget.onPressed != null) {
      widget.onPressed!();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No page assigned')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTV = AppSizes.getDeviceType(context) == DeviceType.tv;

    return FocusableActionDetector(
      focusNode: _focusNode,
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (intent) {
            _handleTap();
            return null;
          },
        ),
      },
      onShowFocusHighlight: (focused) {
        setState(() {}); // rebuild to show border/shadow changes
      },
      child: GestureDetector(
        onTap: _handleTap, // Also support mobile tap
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          padding: const EdgeInsets.all(10),
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            border: Border.all(
              color: AppStyles.primaryColor,
              width: _focusNode.hasFocus ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: _focusNode.hasFocus
                ? [
                    BoxShadow(
                      color: AppStyles.primaryColor.withOpacity(0.6),
                      blurRadius: 12,
                      spreadRadius: 2,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                      _focusNode.hasFocus ? FontWeight.bold : FontWeight.normal,
                  color:
                      _focusNode.hasFocus ? AppStyles.primaryColor : null,
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: _focusNode.hasFocus
                    ? AppStyles.primaryColor
                    : Theme.of(context).primaryColorDark,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


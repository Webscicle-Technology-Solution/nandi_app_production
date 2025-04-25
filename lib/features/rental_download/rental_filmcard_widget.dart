import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nandiott_flutter/utils/Device_size.dart';
import 'package:nandiott_flutter/utils/appstyle.dart';

class RentalFilmcardWidget extends ConsumerStatefulWidget {
  // Accepting parameters via constructor for dynamic data
  final String title;
  final String imageUrl;
  final num expireTime; // Expiry time can be int or double

  // Constructor to pass the data (title, image, expireTime)
  RentalFilmcardWidget({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.expireTime, // Now accept num
  });

  @override
  _RentalFilmcardWidgetState createState() => _RentalFilmcardWidgetState();
}

class _RentalFilmcardWidgetState extends ConsumerState<RentalFilmcardWidget> {
  // Focus Nodes for Play and Info icons
  late FocusNode _playFocusNode;
  late FocusNode _infoFocusNode;
  late FocusNode _mainFocusNode;

  @override
  void initState() {
    super.initState();
    _playFocusNode = FocusNode();
    _infoFocusNode = FocusNode();
    _mainFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _playFocusNode.dispose();
    _infoFocusNode.dispose();
    _mainFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTV = AppSizes.getDeviceType(context) == DeviceType.tv;

    return Focus(
      focusNode: _mainFocusNode,
      onFocusChange: (hasFocus) {
        setState(() {});
      },
      child: SizedBox(
        width: double.infinity,
        height: AppSizes.getCardHeight(context),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: _mainFocusNode.hasFocus
                ? Border.all(color: Colors.amber, width: 2) // Focus border color
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Film Image Container with Play Button
              Container(
                margin: EdgeInsets.symmetric(vertical: isTV ? 12.0 : 4.0, horizontal: isTV ? 16.0 : 0.0),
                width: AppSizes.getImageWidth(context),
                height: AppSizes.getImageHeight(context),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).primaryColorDark, width: 1),
                  image: DecorationImage(
                    image: NetworkImage(widget.imageUrl),
                    fit: BoxFit.cover, // Changed from fill to cover to preserve aspect ratio
                    opacity: 0.8,
                  ),
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Focus(
                  focusNode: _playFocusNode,
                  onFocusChange: (hasFocus) {
                    setState(() {});
                  },
                  child: IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.play_circle_outline,
                      color: _playFocusNode.hasFocus ? Colors.amber : Colors.white,
                      size: AppSizes.getIconSize(context),
                    ),
                  ),
                ),
              ),
              
              // Column with Title and Expiration Info
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 12.0, right: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Title Text with flexible space and ellipsis
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: AppSizes.getTitleFontSize(context),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      SizedBox(height: 10),
                      // Expiration Time Info
                      Text(
                        'Expiring : ${widget.expireTime.toString()} hrs',
                        style: TextStyle(
                          color: AppStyles.errorColor,
                          fontSize: AppSizes.getstatusFontSize(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Info Icon Visibility if expiration is 3 hours or less
              if (widget.expireTime <= 3)
                Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: Icon(
                    Icons.info,
                    color: _infoFocusNode.hasFocus ? Colors.amber : AppStyles.errorColor,
                    size: isTV ? 40 : 30, // Adjust size for TV screens
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

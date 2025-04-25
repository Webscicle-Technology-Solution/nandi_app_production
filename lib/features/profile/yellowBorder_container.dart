import 'package:flutter/material.dart';
import 'package:nandiott_flutter/utils/Device_size.dart';
import 'package:nandiott_flutter/utils/appstyle.dart';

class YellowborderContainer extends StatefulWidget {
  final String title;
  final Widget? page; // The widget to navigate to when tapped
  VoidCallback?  onPressed;

   YellowborderContainer({super.key, required this.title, this.page,this.onPressed});

  @override
  _YellowborderContainerState createState() => _YellowborderContainerState();
}

class _YellowborderContainerState extends State<YellowborderContainer> {
  late FocusNode _focusNode; // FocusNode for this container

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

  @override
  Widget build(BuildContext context) {
    final isTV = AppSizes.getDeviceType(context) == DeviceType.tv;

    return Focus(
      focusNode: _focusNode,
      onFocusChange: (hasFocus) {
        
        setState(() {

        }); // Rebuild on focus change
      },
      child: InkWell(
        onTap: () {
          if (widget.page != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => widget.page!,
              ),
            );
          } 
          
          else if(widget.onPressed!=null){
              widget.onPressed!(); // Trigger the onPressed action
          }
          
          
          else {
            // Handle null page (optional)
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('No page assigned')),
            );
          }
        },
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          padding: EdgeInsets.all(10),
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            border: _focusNode.hasFocus ? Border.all(
              color:  AppStyles.primaryColor, // Focus border color
              width: 2,
            ): Border.all(
              color:  AppStyles.primaryColor,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(10),
            // Add a slight scale effect when focused on TV
             boxShadow: _focusNode.hasFocus 
                ? [BoxShadow(color: AppStyles.primaryColor.withOpacity(0.5), blurRadius: 8, spreadRadius: 1)]
                : null,
          
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: _focusNode.hasFocus? FontWeight.bold : FontWeight.normal,
              color:  _focusNode.hasFocus? AppStyles.primaryColor  : null,
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: _focusNode.hasFocus ? AppStyles.primaryColor : Theme.of(context).primaryColorDark, // Focused icon color
              ),
            ],
          ),
        ),
      ),
    );
  }
}

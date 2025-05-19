import 'package:flutter/material.dart';
import 'package:nandiott_flutter/utils/appstyle.dart';

class IssueDropdown extends StatefulWidget {
  final ValueChanged<String> onChanged;

  // Constructor to pass the callback function when value is selected
  IssueDropdown({Key? key, required this.onChanged}) : super(key: key);

  @override
  _IssueDropdownState createState() => _IssueDropdownState();
}

class _IssueDropdownState extends State<IssueDropdown> {
  // Default value for the dropdown
  String selectedIssue = 'Other issue';

  // List of items in the dropdown
  final List<String> issues = [
    'Play back issue',
    'Streaming issue',
    'Download issue',
    'Payment issue',
    'Other issue'
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
      padding: EdgeInsets.only(left: 10, right: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColorLight, // Background color
        borderRadius: BorderRadius.circular(8), // Rounded corners for the border
        border: Border.all(
          color: AppStyles.primaryColor, // Border color
          width: 1, // Border width
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedIssue,
          onChanged: (String? newValue) {
            setState(() {
              selectedIssue = newValue!;
            });
            widget.onChanged(selectedIssue); // Call the callback when value changes
          },
          items: issues.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          isExpanded: true, // Optional, makes the dropdown span across the width
          icon: Icon(Icons.arrow_drop_down_circle_outlined),
          iconSize: 24,
          // Remove the default underline with DropdownButtonHideUnderline
        ),
      ),
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';

class CustomProfilePic extends StatelessWidget {
  final String? imagepath;
  final VoidCallback onTap;
  const CustomProfilePic({super.key,
  required this.imagepath,
  required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child:  CircleAvatar(
        radius: 50,
        backgroundImage:imagepath!=null?FileImage(File(imagepath!)):const AssetImage('assetName') as ImageProvider ,
        child: imagepath==null?const Icon(Icons.add_a_photo,size: 30,color: Colors.grey,):null,
      ),
    );
  }
}
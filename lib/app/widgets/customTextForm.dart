import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nandiott_flutter/utils/Device_size.dart';
import 'package:nandiott_flutter/utils/appstyle.dart';

class CustomTextFormField extends StatelessWidget {
  final bool isprefixicon;
 final bool issuffxicon;
  final bool isfillcolor;
  final String? initialValue;
  final String? labelText;
  final String? errorText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final IconData? prefixIcon;
  final IconButton? suffixIcon;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final String? hintText;
  final void Function(String value)? onChanged; // Keep this as it is.
  final int? minline;
  final int? maxline;
  final bool readOnly;
  final bool isOtp;
  final bool isBio;
  const CustomTextFormField(
      {this.initialValue,
      this.errorText,
      super.key,
      this.labelText,
      this.keyboardType = TextInputType.text,
      this.obscureText = false,
      this.validator,
      this.readOnly = false,
      this.prefixIcon,
      this.minline,
      this.maxline,
      this.suffixIcon,
      this.focusNode,
      this.hintText,
      this.onChanged, // This is correctly implemented.
      this.controller,
      this.isOtp = false,
      this.isBio = false,
      required this.isfillcolor,
      required this.isprefixicon,
      required this.issuffxicon});

  @override
  Widget build(BuildContext context) {
    final deviceType = AppSizes.getDeviceType(context);
    final isTVDevice = deviceType == DeviceType.tv;

        final double fontSize = isTVDevice ? 20.0 : 14.0;
    final double iconSize = isTVDevice ? 30.0 : 24.0;
    final double borderRadius = isTVDevice ? 12.0 : 8.0;
    return SizedBox(
      width: isTVDevice ? 800 : null,
      child: TextFormField(
        
        inputFormatters: isOtp
            ? [
                LengthLimitingTextInputFormatter(6),
                FilteringTextInputFormatter.digitsOnly,
              ]:null,
            // : isBio
            //     ? [LengthLimitingTextInputFormatter(50)]
            //     : null,
        
        autofocus: false,
        readOnly: readOnly,
        minLines: minline,
        maxLines: maxline,
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        style: GoogleFonts.poppins(color: Colors.black,fontSize: fontSize,),
        onChanged: onChanged, // Correctly using the onChanged parameter here.
        decoration: InputDecoration(
          
          errorText: errorText,
          contentPadding: EdgeInsets.symmetric(
            vertical: isTVDevice ? 20 : 12,
            horizontal: isTVDevice ? 16 : 12,
          ),
           prefixIcon: isprefixicon
              ? Icon(
                  prefixIcon,
                  color: AppStyles.textblack,
                  size: iconSize,
                )
              : null,
          suffixIcon: issuffxicon ? suffixIcon : null,
          labelText: labelText,
          hintText: hintText,
          hintStyle: TextStyle(fontSize: fontSize),
          // hintStyle: AppStyle.loadingText,
          filled: isfillcolor,
          fillColor: AppStyles.whiteColor,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: const BorderSide(color: AppStyles.unselectedTextColor, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: const BorderSide(color: AppStyles.primaryColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: const BorderSide(color: AppStyles.errorColor),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: const BorderSide(color: AppStyles.errorColor),
          ),
        ),
      ),
    );
  }
}
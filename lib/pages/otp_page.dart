// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:nandiott_flutter/app/widgets/customappbar.dart';
// import 'package:nandiott_flutter/app/widgets/custombottombar.dart';
// import 'package:nandiott_flutter/app/widgets/customerror_message.dart';
// import 'package:nandiott_flutter/features/auth/providers/auth_provider.dart';
// import 'package:nandiott_flutter/providers/otp_provider.dart';

// class OtpPage extends ConsumerStatefulWidget {
//   String email;
//   String name;
//   String phone;
//   String state;
//   String city;
//   String pincode;
//    OtpPage({super.key, required this.email,required this.name,required this.phone,required this.state,required this.city,required this.pincode});

//   @override
//   ConsumerState<ConsumerStatefulWidget> createState() => _OtpPageState();
// }

// class _OtpPageState extends ConsumerState<OtpPage> {
//   final _otpController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();
//   @override
//   Widget build(BuildContext context) {
// final authState = ref.watch(authProvider); // Watch the auth state

//      if (authState.successMessage != null) {


//       Future.delayed(Duration.zero, () {
//        ref.read(authProvider.notifier).state = AuthState(); // Reset state
//         Navigator.of(context).pushAndRemoveUntil(
//           MaterialPageRoute(
//             builder: (context) => ResponsiveNavigation(),
//           ),
//           (route) => false, // Remove all previous routes from the stack
//         );
// });
// }


//     return Scaffold(
//       appBar: CustomAppBar(
//         title: "Enter Otp",
//       showActionIcon: false,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//            const   Text(
//                 'Enter the OTP sent to your phone',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.amber,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               SizedBox(height: 30),
//               TextFormField(
//                 controller: _otpController,
//                 decoration: InputDecoration(
//                   labelText: 'OTP',
//                   hintText: 'Enter 6-digit OTP',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide(color: Colors.amber),
//                   ),
//                   prefixIcon: Icon(Icons.lock, color: Colors.amber),
//                 ),
//                 keyboardType: TextInputType.number,
//                 maxLength: 6,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter the OTP';
//                   } else if (value.length != 6) {
//                     return 'OTP must be 6 digits';
//                   }
//                   return null;
//                 },
//               ),
//               SizedBox(height: 20),
//               if (authState.errorMessage != null)
//                           Column(
//                             children: [
//                               const SizedBox(height: 20),
//                               ErrorText(errorMessage: authState.errorMessage!,),
//                             ],
//         ),
//               ElevatedButton(
//             onPressed: () {
//                                   if (_formKey.currentState!.validate()){
                            
//                                   ref.read(authProvider.notifier).registerUser(
//                                     widget.name,
//                                     widget.email,
//                                     widget.phone,
//                                     widget.state,
//                                     widget.city,
//                                     widget.pincode,
//                                     _otpController.text
//                                   );
//                                 }
//                 },
//                 style: ElevatedButton.styleFrom(
//                //   primary: Colors.blueAccent,
//                   minimumSize: Size(double.infinity, 50),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: const Text(
//                   'Submit',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             const  SizedBox(height: 20),
//               TextButton(
//                 onPressed: () {
//                   // Handle Resend OTP logic
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text('OTP Resent')),
//                   );
//                 },
//                 child: Text(
//                   'Resend OTP',
//                   style: TextStyle(
//                     color: Colors.amber,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );

//   }
// }



// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:nandiott_flutter/app/widgets/customappbar.dart';
// import 'package:nandiott_flutter/app/widgets/custombottombar.dart';
// import 'package:nandiott_flutter/app/widgets/customerror_message.dart';
// import 'package:nandiott_flutter/features/auth/providers/auth_provider.dart';
// import 'package:nandiott_flutter/providers/otp_provider.dart';
// import 'package:sms_autofill/sms_autofill.dart';

// class OtpPage extends ConsumerStatefulWidget {
//   String email;
//   String name;
//   String phone;
//   String state;
//   String city;
//   String pincode;

//   OtpPage({
//     super.key,
//     required this.email,
//     required this.name,
//     required this.phone,
//     required this.state,
//     required this.city,
//     required this.pincode,
//   });

//   @override
//   ConsumerState<ConsumerStatefulWidget> createState() => _OtpPageState();
// }

// class _OtpPageState extends ConsumerState<OtpPage> {
//   final _otpController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();

//   @override
//   void initState() {
//     super.initState();
//     getAppSignature();
//     SmsAutoFill().listenForCode();
//   }
// void getAppSignature() async {
//   String signature = await SmsAutoFill().getAppSignature;
//   print('App Signature: $signature');
// }
//   @override
//   void dispose() {
//     SmsAutoFill().unregisterListener();
//     _otpController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authState = ref.watch(authProvider);

//     if (authState.successMessage != null) {
//       Future.delayed(Duration.zero, () {
//         ref.read(authProvider.notifier).state = AuthState(); // Reset state
//         Navigator.of(context).pushAndRemoveUntil(
//           MaterialPageRoute(builder: (context) => ResponsiveNavigation()),
//           (route) => false,
//         );
//       });
//     }

//     return Scaffold(
//       appBar: CustomAppBar(
//         title: "Enter OTP",
//         showActionIcon: false,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Text(
//                 'Enter the OTP sent to your phone',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.amber,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 30),
//               PinFieldAutoFill(
//                 controller: _otpController,
//                 codeLength: 6,
//                 decoration: UnderlineDecoration(
//                   textStyle: TextStyle(fontSize: 20, color: Colors.black),
//                   colorBuilder: FixedColorBuilder(Colors.amber),
//                 ),
//                 onCodeChanged: (code) {
//                   if (code != null && code.length == 6) {
//                     // Optional: Auto-submit
//                     ref.read(authProvider.notifier).registerUser(
//                       widget.name,
//                       widget.email,
//                       widget.phone,
//                       widget.state,
//                       widget.city,
//                       widget.pincode,
//                       code,
//                     );
//                   }
//                 },
//               ),
//               const SizedBox(height: 20),
//               if (authState.errorMessage != null)
//                 Column(
//                   children: [
//                     const SizedBox(height: 20),
//                     ErrorText(errorMessage: authState.errorMessage!),
//                   ],
//                 ),
//               ElevatedButton(
//                 onPressed: () {
//                   if (_formKey.currentState!.validate()) {
//                     ref.read(authProvider.notifier).registerUser(
//                       widget.name,
//                       widget.email,
//                       widget.phone,
//                       widget.state,
//                       widget.city,
//                       widget.pincode,
//                       _otpController.text,
//                     );
//                   }
//                 },
//                 style: ElevatedButton.styleFrom(
//                   minimumSize: Size(double.infinity, 50),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: const Text(
//                   'Submit',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               TextButton(
//                 onPressed: () {
//                   // Resend OTP logic
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text('OTP Resent')),
//                   );
//                 },
//                 child: Text(
//                   'Resend OTP',
//                   style: TextStyle(
//                     color: Colors.amber,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }



import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nandiott_flutter/app/widgets/customappbar.dart';
import 'package:nandiott_flutter/app/widgets/custombottombar.dart';
import 'package:nandiott_flutter/app/widgets/customerror_message.dart';
import 'package:nandiott_flutter/features/auth/providers/auth_provider.dart';
import 'package:nandiott_flutter/features/auth/signup_page.dart';
import 'package:nandiott_flutter/providers/otp_provider.dart';
import 'package:nandiott_flutter/utils/checkConnectivity_util.dart';
import 'package:telephony/telephony.dart';

class OtpPage extends ConsumerStatefulWidget {
  final String email;
  final String name;
  final String phone;
  final String state;
  final String city;
  final String pincode;

  OtpPage({
    super.key,
    required this.email,
    required this.name,
    required this.phone,
    required this.state,
    required this.city,
    required this.pincode,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _OtpPageState();
}

class _OtpPageState extends ConsumerState<OtpPage> {
  bool isButtonDisabled=true;
  int secondsRemainig=60;
  Timer? timer;
  String? deviceToken;
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final Telephony telephony = Telephony.instance;
Future<void> getToken() async{
  String? token=await FirebaseMessaging.instance.getToken();
  if(token!=null){
setState(() {
  print("the device token is ${deviceToken}") ;
  deviceToken=token;
});
  }
}
  @override
  void initState() {
    startTimer();
    getToken();
    super.initState();
    _listenForSms();
  }

  // Listen for incoming SMS
  void _listenForSms() async {
    final bool? permissionsGranted = await telephony.requestPhoneAndSmsPermissions;
    if (permissionsGranted ?? false) {
      telephony.listenIncomingSms(
        onNewMessage: (SmsMessage message) {
          final body = message.body ?? '';
          final otpRegex = RegExp(r'\b\d{6}\b'); // Match 6-digit OTP
          final match = otpRegex.firstMatch(body);
          if (match != null) {
            final otp = match.group(0)!;
            setState(() {
              _otpController.text = otp;
              print("permission granted is $permissionsGranted and otp is $otp");
            });

            // Optionally auto-submit when OTP is detected
            ref.refresh(authProvider.notifier).registerUser(
              widget.name,
              widget.email,
              widget.phone,
              widget.state,
              widget.city,
              widget.pincode,
              otp,
              deviceToken!
            );
          }
        },
          listenInBackground: false, // 👈 This avoids the assertion error
      );
    } else {
      // Handle case where permissions are not granted
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('SMS permissions are required to auto-fill OTP')),
      );
    }
  }
//Resend opt timer setting
void startTimer(){
  setState(() {
    isButtonDisabled=true;
    secondsRemainig=60;
  });
  timer=Timer.periodic(Duration(seconds: 1), (timer){
if(secondsRemainig==0){
  timer.cancel();
  setState(() {
    isButtonDisabled=false;
  });
 
} else{
  setState(() {
      secondsRemainig--;

  });
}
  });
}
  @override
  void dispose() {
    //telephony.removeListener();  // Unregister SMS listener to avoid leaks
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    if (authState.successMessage != null) {
      Future.delayed(Duration.zero, () {
        ref.refresh(authProvider.notifier).state = AuthState();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => ResponsiveNavigation()),
          (route) => false,
        );
      });
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: "Enter OTP",
        showActionIcon: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Enter the OTP sent to your phone',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: _otpController,
                decoration: InputDecoration(
                  labelText: 'OTP',
                  hintText: 'Enter 6-digit OTP',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.amber),
                  ),
                  prefixIcon: Icon(Icons.lock, color: Colors.amber),
                ),
                keyboardType: TextInputType.number,
                maxLength: 6,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the OTP';
                  } else if (value.length != 6) {
                    return 'OTP must be 6 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              if (authState.errorMessage != null)
                Column(
                  children: [
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        ErrorText(errorMessage: authState.errorMessage!),
                        TextButton(onPressed: (){
                          Navigator.pop(context);
                        }, child: Text("Go Back",
                          style: TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                        
                        
                        ))
                      ],
                    ),
                    const SizedBox(height: 20),


                  ],
                ),
              ElevatedButton(
                onPressed: ()async {
                        final connectivityResults = await Connectivity().checkConnectivity();
final hasInternet = !connectivityResults.contains(ConnectivityResult.none);
    if (!hasInternet)
    ConnectivityUtils.showNoConnectionDialog(context);
    
                  if (_formKey.currentState!.validate()) {
                    ref.refresh(authProvider.notifier).registerUser(
                      widget.name,
                      widget.email,
                      widget.phone,
                      widget.state,
                      widget.city,
                      widget.pincode,
                      _otpController.text,
                      deviceToken!
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Submit',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: isButtonDisabled?null: () async {
                        final connectivityResults = await Connectivity().checkConnectivity();
final hasInternet = !connectivityResults.contains(ConnectivityResult.none);
    if (!hasInternet)
    ConnectivityUtils.showNoConnectionDialog(context);
                  startTimer();
                    final otpResponse = await ref.refresh(
                                            sentOtpProvider(OtpDetailParameter(
                                                    phone:phoneController.text
                                                       ))
                                                .future);

                                                           if (otpResponse ==
                                            'Otp sent successfully') {
                                                                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('OTP Resent')),
                  );
                                            }
                                            else{
      ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text('Unable to send Otp. Please try again later')));                               
                                            }


                },
                child: Text(
                  isButtonDisabled?'Resend in $secondsRemainig sec': 'Resend OTP ?',
                  style: TextStyle(
                    color: isButtonDisabled? Colors.grey : Colors.amber,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


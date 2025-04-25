// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:nandiott_flutter/app/widgets/customTextForm.dart';
// import 'package:nandiott_flutter/app/widgets/customerror_message.dart';
// import 'package:nandiott_flutter/features/auth/password_widget.dart';
// import 'package:nandiott_flutter/features/auth/providers/auth_provider.dart';
// import 'package:nandiott_flutter/features/auth/signup_page.dart';
// import 'package:nandiott_flutter/providers/checkauth_provider.dart';
// import 'package:nandiott_flutter/providers/detail_provider.dart';
// import 'package:nandiott_flutter/providers/payment_provider.dart';
// import 'package:nandiott_flutter/providers/rental_provider.dart';
// import 'package:nandiott_flutter/utils/Device_size.dart';
// import 'package:nandiott_flutter/utils/appstyle.dart';
// import 'package:nandiott_flutter/utils/validators.dart';
// import 'package:nandiott_flutter/features/auth/login_qr_page.dart';

// final TextEditingController emailController = TextEditingController();
// final TextEditingController passwordController = TextEditingController();

// // class LoginPage extends ConsumerWidget {
// //   LoginPage({super.key});

// //   static final GlobalKey<FormState> formKey = GlobalKey<FormState>();
// //   // final AuthService authService = AuthService();

// //   // var buttonFocus = FocusNode();

// //   @override
// //   Widget build(BuildContext context, WidgetRef ref) {
// //     ref.invalidate(authUserProvider);
// //     ref.invalidate(rentalProvider);
// //     ref.invalidate(rentPaymentProvider);
// //     ref.invalidate(subsciptionPaymentProvider);
// //     ref.invalidate(movieDetailProvider);
// //     final deviceType = AppSizes.getDeviceType(context);
// //     final isTVDevice = deviceType == DeviceType.tv;

// //     final double logoRadius = isTVDevice ? 50 : 45;
// //     final authState = ref.watch(authProvider); // Watch the auth state

// //     if (authState.successMessage != null) {
// //       Future.delayed(Duration.zero, () {
// //         ref.read(authProvider.notifier).state = AuthState(); // Reset state
// //         Navigator.of(context).pop(true);
// //       });
// //     }
// //     bool isFocused = false;

// //     return Scaffold(
// //       // backgroundColor: AppStyles.textblack,

// //       body: SingleChildScrollView(
// //         child: Center(
// //           child: ConstrainedBox(
// //     constraints: BoxConstraints(
// //       maxWidth: isTVDevice ? 800 : double.infinity, // max width on TV
// //     ),
// //             child: Column(
// //               mainAxisAlignment: MainAxisAlignment.start,
// //               crossAxisAlignment: CrossAxisAlignment.center,
// //               children: [
// //                 SizedBox(height: isTVDevice ? 80 : 50), // more top padding for TV
// //                 CircleAvatar(
// //                   backgroundColor: Colors.transparent,
// //                   radius: logoRadius,
// //                   child: Padding(
// //                     padding: const EdgeInsets.all(12.0),
// //                     child: Image.asset('assets/logo/main-logo.png'),
// //                   ),
// //                 ),
// //                 SizedBox(height: 12),
// //                 Text(
// //                   'NANDI Pictures',
// //                   style: TextStyle(
// //                     fontWeight: FontWeight.bold,
// //                     fontSize: AppSizes.getTitleFontSize(context),
// //                     // color: AppStyles.textwhite,
// //                   ),
// //                 ),
// //                 SizedBox(height: 12),
// //                 Text(
// //                   'Find your daily entertainment here',
// //                   style: TextStyle(
// //                     fontWeight: FontWeight.normal,
// //                     fontSize: AppSizes.getstatusFontSize(context),

// //                     // color: AppStyles.textwhite,
// //                   ),
// //                   textAlign: TextAlign.center,
// //                 ),
// //                 SizedBox(height: 15),
// //                 Padding(
// //                   padding: const EdgeInsets.all(20.0),
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.center,
// //                     children: [
// //                       SizedBox(height: 10),
// //                       Text(
// //                         'Login to your account',
// //                         style: TextStyle(
// //                           fontWeight: FontWeight.normal,
// //                           fontSize: AppSizes.getTitleFontSize(context),
// //                           color: AppStyles.primaryColor,
// //                         ),
// //                       ),
// //                       SizedBox(height: 25),
// //                       Form(
// //                           key: formKey,
// //                           child: Column(children: [
// //                             CustomTextFormField(
// //                               validator: validateEmail,
// //                               isfillcolor: true,
// //                               isprefixicon: true,
// //                               issuffxicon: false,
// //                               prefixIcon: Icons.email,
// //                               controller: emailController,
// //                               hintText: 'Email',
// //                               keyboardType: TextInputType.emailAddress,
// //                               obscureText: false,
// //                             ),
// //                             SizedBox(height: 25),
// //                             Focus(
// //                               focusNode: FocusNode(),
// //                               child: PasswordWidget(controller: passwordController)),
// //                             SizedBox(height: 25),
// //                             if (authState.errorMessage != null)
// //                               Column(
// //                                 children: [
// //                                   ErrorText(
// //                                     errorMessage: authState.errorMessage!,
// //                                   ),
// //                                   const SizedBox(height: 20),
// //                                 ],
// //                               ),
// //                             authState.isLoading
// //                                 ? const CircularProgressIndicator()
// //                                 : SizedBox(
// //                                     width: 180,
// //                                     child: ElevatedButton(
// //                                       style: ElevatedButton.styleFrom(
// //                                         backgroundColor: AppStyles.primaryColor,
// //                                         shape: RoundedRectangleBorder(
// //                                           borderRadius: BorderRadius.circular(10),
// //                                         ),
// //                                       ),
// //                                       onPressed: () {
// //                                         if (formKey.currentState!.validate()) {
// //                                           ref
// //                                               .read(authProvider.notifier)
// //                                               .loginUser(
// //                                                 emailController.text,
// //                                                 passwordController.text,
// //                                               );
// //                                         }
// //                                       },
// //                                       child: const Text(
// //                                         'Login',
// //                                         style: TextStyle(
// //                                           fontWeight: FontWeight.bold,
// //                                           fontSize: 20,
// //                                           color: Colors.white,
// //                                         ),
// //                                       ),
// //                                     ),
// //                                   ),
// //                           ])),
// //                       const SizedBox(height: 20),
// //                       if (isTVDevice)
// //                         // Show "Login with QR code" text for TV
// //                         InkWell(
// //                           onTap: () => {

// //                           },
// //                           child: Container(
// //                             padding: EdgeInsets.symmetric(
// //                                 vertical: 10.0, horizontal: 10),
// //                             decoration: BoxDecoration(
// //                               borderRadius: BorderRadius.circular(10),
// //                               border: Border.all(color: AppStyles.primaryColor),
// //                             ),
// //                             child: Text(
// //                               'Login with QR code',
// //                               style: TextStyle(
// //                                 fontSize: 22,
// //                                 fontWeight: FontWeight.w500,
// //                                 color: AppStyles.primaryColor,
// //                               ),
// //                             ),
// //                           ),
// //                         )
// //                       else
// //                         // Show "Create New account" button for mobile
// //                         Container(
// //                           margin:
// //                               EdgeInsets.symmetric(horizontal: 30, vertical: 10),
// //                           width: double.infinity,
// //                           height: 50,
// //                           child: TextButton(
// //                             onPressed: () {
// //                               Navigator.of(context).push(MaterialPageRoute(
// //                                 builder: (context) => SignupPage(),
// //                               ));
// //                             },
// //                             style: ElevatedButton.styleFrom(
// //                               backgroundColor: Colors.transparent,
// //                               side:
// //                                   const BorderSide(color: AppStyles.primaryColor),
// //                               shape: RoundedRectangleBorder(
// //                                 borderRadius: BorderRadius.circular(10),
// //                               ),
// //                             ),
// //                             child: Text(
// //                               'Create New account',
// //                               style: TextStyle(
// //                                   color: Theme.of(context).primaryColorDark),
// //                             ),
// //                           ),
// //                         ),
// //                     ],
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// class LoginPage extends ConsumerWidget {
//   LoginPage({super.key});

//   static final GlobalKey<FormState> formKey = GlobalKey<FormState>();

//   final FocusNode emailFocusNode = FocusNode();
//   final FocusNode passwordFocusNode = FocusNode();

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     ref.invalidate(authUserProvider);
//     ref.invalidate(rentalProvider);
//     ref.invalidate(rentPaymentProvider);
//     ref.invalidate(subsciptionPaymentProvider);
//     ref.invalidate(movieDetailProvider);

//     final deviceType = AppSizes.getDeviceType(context);
//     final isTVDevice = deviceType == DeviceType.tv;
//     final double logoRadius = isTVDevice ? 50 : 45;
//     final authState = ref.watch(authProvider);

//     if (authState.successMessage != null) {
//       Future.delayed(Duration.zero, () {
//         ref.read(authProvider.notifier).state = AuthState();
//         Navigator.of(context).pop(true);
//       });
//     }

//     return Scaffold(
//       body: Center(
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             maxWidth: isTVDevice ? 600 : double.infinity,
//           ),
//           child: SingleChildScrollView(
//             child: Padding(
//               padding: const EdgeInsets.all(20.0),
//               child: Column(
//                 mainAxisAlignment: isTVDevice
//                     ? MainAxisAlignment.center
//                     : MainAxisAlignment.start,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   SizedBox(height: isTVDevice ? 30 : 50),
//                   CircleAvatar(
//                     backgroundColor: Colors.transparent,
//                     radius: logoRadius,
//                     child: Padding(
//                       padding: const EdgeInsets.all(12.0),
//                       child: Image.asset('assets/logo/main-logo.png'),
//                     ),
//                   ),
//                   SizedBox(height: 12),
//                   Text(
//                     'NANDI Pictures',
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: AppSizes.getTitleFontSize(context),
//                     ),
//                   ),
//                   SizedBox(height: 12),
//                   Text(
//                     'Find your daily entertainment here',
//                     style: TextStyle(
//                       fontWeight: FontWeight.normal,
//                       fontSize: AppSizes.getstatusFontSize(context),
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   SizedBox(height: 15),
//                   Text(
//                     'Login to your account',
//                     style: TextStyle(
//                       fontWeight: FontWeight.normal,
//                       fontSize: AppSizes.getTitleFontSize(context),
//                       color: AppStyles.primaryColor,
//                     ),
//                   ),
//                   SizedBox(height: 25),
//                   Form(
//                     key: formKey,
//                     child: Column(
//                       children: [
//                         CustomTextFormField(
//                           validator: validateEmail,
//                           isfillcolor: true,
//                           isprefixicon: true,
//                           issuffxicon: false,
//                           prefixIcon: Icons.email,
//                           controller: emailController,
//                           focusNode: emailFocusNode,
//                           hintText: 'Email',
//                           keyboardType: TextInputType.emailAddress,
//                           obscureText: false,
//                         ),
//                         SizedBox(height: 25),
//                         PasswordWidget(controller: passwordController),
//                         SizedBox(height: 25),
//                         if (authState.errorMessage != null) ...[
//                           ErrorText(errorMessage: authState.errorMessage!),
//                           SizedBox(height: 20),
//                         ],
//                         SizedBox(height: 25),
//                             authState.isLoading
//                                 ? const CircularProgressIndicator()
//                                 : SizedBox(
//                                     width: 180,
//                                     child: ElevatedButton(
//                                       style: ElevatedButton.styleFrom(
//                                         backgroundColor: AppStyles.primaryColor,
//                                         shape: RoundedRectangleBorder(
//                                           borderRadius: BorderRadius.circular(10),
//                                         ),
//                                       ),
//                                       onPressed: () {
//                                         if (formKey.currentState!.validate()) {
//                                           ref
//                                               .read(authProvider.notifier)
//                                               .loginUser(
//                                                 emailController.text,
//                                                 passwordController.text,
//                                               );
//                                         }
//                                       },
//                                       child: const Text(
//                                         'Login',
//                                         style: TextStyle(
//                                           fontWeight: FontWeight.bold,
//                                           fontSize: 20,
//                                           color: Colors.white,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
                          
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   isTVDevice
//                       ? InkWell(
//                           onTap: () {
//                             // QR Login logic here
//                             Navigator.of(context).push(MaterialPageRoute(
//   builder: (_) => TVQRLoginPage(
//     pairingCode: "AB12-CD34",
//     qrLink: "https://nandipics.tv/login/AB12CD34",
//   ),
// ));
//                           },
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(
//                                 vertical: 10.0, horizontal: 10),
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(10),
//                               border: Border.all(color: AppStyles.primaryColor),
//                             ),
//                             child: Text(
//                               'Login with QR code',
//                               style: TextStyle(
//                                 fontSize: 22,
//                                 fontWeight: FontWeight.w500,
//                                 color: AppStyles.primaryColor,
//                               ),
//                             ),
//                           ),
//                         )
//                       : Container(
//                           margin: const EdgeInsets.symmetric(
//                               horizontal: 30, vertical: 10),
//                           width: double.infinity,
//                           height: 50,
//                           child: TextButton(
//                             onPressed: () {
//                               Navigator.of(context).push(
//                                 MaterialPageRoute(
//                                   builder: (context) => SignupPage(),
//                                 ),
//                               );
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.transparent,
//                               side: const BorderSide(
//                                   color: AppStyles.primaryColor),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                             ),
//                             child: Text(
//                               'Create New account',
//                               style: TextStyle(
//                                   color: Theme.of(context).primaryColorDark),
//                             ),
//                           ),
//                         ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

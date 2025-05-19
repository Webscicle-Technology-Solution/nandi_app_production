import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nandiott_flutter/features/auth/widget/customTextForm.dart';
import 'package:nandiott_flutter/features/auth/widget/customerror_message.dart';
import 'package:nandiott_flutter/features/auth/providers/auth_provider.dart';
import 'package:nandiott_flutter/features/auth/page/otp_page.dart';
import 'package:nandiott_flutter/features/auth/providers/otp_provider.dart';
import 'package:nandiott_flutter/utils/appstyle.dart';
import 'package:nandiott_flutter/utils/checkConnectivity_util.dart';
import 'package:nandiott_flutter/utils/validators.dart';

final TextEditingController nameController = TextEditingController();
final TextEditingController emailController = TextEditingController();
final TextEditingController phoneController = TextEditingController();
final TextEditingController stateController = TextEditingController();
final TextEditingController cityController = TextEditingController();
final TextEditingController pincodeController = TextEditingController();
final TextEditingController passwordController = TextEditingController();
final TextEditingController confirmPasswordController = TextEditingController();

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  // Define formKey inside the state class
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider); // Watch the auth state
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text('Welcome to NANDI Pictures',
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 20)),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Create New account',
                      style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 17,
                          color: AppStyles.primaryColor),
                    ),
                    const SizedBox(height: 25),
                    Form(
                      key: formKey, // Use formKey defined in _SignupPageState
                      child: Column(
                        children: [
                          CustomTextFormField(
                            validator: validateEmail,
                            isfillcolor: true,
                            isprefixicon: true,
                            issuffxicon: false,
                            prefixIcon: Icons.email,
                            controller: emailController,
                            hintText: 'Email',
                            keyboardType: TextInputType.emailAddress,
                            obscureText: false,
                          ),
                          const SizedBox(height: 25),
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextFormField(
                                  validator: validateRequired,
                                  isfillcolor: true,
                                  isprefixicon: true,
                                  issuffxicon: false,
                                  prefixIcon: Icons.person,
                                  controller: nameController,
                                  hintText: 'Name',
                                  keyboardType: TextInputType.text,
                                  obscureText: false,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: CustomTextFormField(
                                  validator: validatePhone,
                                  isfillcolor: true,
                                  isprefixicon: true,
                                  issuffxicon: false,
                                  prefixIcon: Icons.phone,
                                  controller: phoneController,
                                  hintText: 'Phone',
                                  keyboardType: TextInputType.phone,
                                  obscureText: false,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 25),
                          CustomTextFormField(
                            validator: validateRequired,
                            isfillcolor: true,
                            isprefixicon: true,
                            issuffxicon: false,
                            prefixIcon: Icons.location_on,
                            controller: stateController,
                            hintText: 'State',
                            keyboardType: TextInputType.text,
                            obscureText: false,
                          ),
                          const SizedBox(height: 25),
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextFormField(
                                  validator: validateRequired,
                                  isfillcolor: true,
                                  isprefixicon: true,
                                  issuffxicon: false,
                                  prefixIcon: Icons.apartment_rounded,
                                  controller: cityController,
                                  hintText: 'City',
                                  keyboardType: TextInputType.text,
                                  obscureText: false,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: CustomTextFormField(
                                  validator: validateRequired,
                                  isfillcolor: true,
                                  isprefixicon: true,
                                  issuffxicon: false,
                                  prefixIcon: Icons.numbers,
                                  controller: pincodeController,
                                  hintText: 'Zip Code',
                                  keyboardType: TextInputType.text,
                                  obscureText: false,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 25),
                          if (authState.errorMessage != null)
                            Column(
                              children: [
                                const SizedBox(height: 20),
                                ErrorText(
                                    errorMessage: authState.errorMessage!),
                              ],
                            ),
                          SizedBox(
                            width: 180,
                            child: authState.isLoading
                                ? const CircularProgressIndicator()
                                : ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppStyles.primaryColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: () async {
                                      final connectivityResults =
                                          await Connectivity()
                                              .checkConnectivity();
                                      final hasInternet = !connectivityResults
                                          .contains(ConnectivityResult.none);
                                      if (!hasInternet) {
                                        ConnectivityUtils
                                            .showNoConnectionDialog(context);
                                      }
                                      if (formKey.currentState!.validate()) {
                                        // Trigger the OTP provider directly using `ref.read` and not `ref.watch`
                                        final otpResponse = await ref.read(
                                            sentOtpProvider(OtpDetailParameter(
                                                    phone:
                                                        phoneController.text))
                                                .future);

                                        if (otpResponse ==
                                            'Otp sent successfully') {
                                          // Navigate only when OTP is sent successfully
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) => OtpPage(
                                                email: emailController.text,
                                                name: nameController.text,
                                                phone: phoneController.text,
                                                state: stateController.text,
                                                city: cityController.text,
                                                pincode: pincodeController.text,
                                              ),
                                            ),
                                          );
                                        } else {
                                          // Handle OTP failed case (optional)
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Failed to send OTP.${otpResponse}')),
                                          );
                                        }
                                      }
                                    },
                                    child: const Text(
                                      'SignUp',
                                      style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 20,
                                          color: Colors.white),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 35),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Already have an account? LogIn',
                        style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 16,
                            color: AppStyles.primaryColor),
                      ),
                    )
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

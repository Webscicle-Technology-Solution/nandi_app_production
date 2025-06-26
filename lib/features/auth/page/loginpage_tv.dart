import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nandiott_flutter/features/auth/page/signup_page.dart';
import 'package:nandiott_flutter/features/auth/providers/checkauth_provider.dart';
import 'package:nandiott_flutter/features/auth/providers/otp_provider.dart';
import 'package:nandiott_flutter/features/rental_download/provider/rental_provider.dart';
import 'package:nandiott_flutter/services/auth_service.dart';
import 'package:nandiott_flutter/utils/Device_size.dart';
import 'package:nandiott_flutter/utils/appstyle.dart';
import 'package:nandiott_flutter/utils/checkConnectivity_util.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart'; // Import UUID package
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final tvLoginUrl = dotenv.env['TV_LOGIN_URL'];

  final bool isIos = Platform.isIOS;

  late String deviceToken;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _isOtpSent = false;
  bool _isOtpVerified = false;
  int _focusedNumPadIndex = 0;
  final FocusNode _numPadFocusNode = FocusNode();
  final List<FocusNode> _numPadButtonNodes =
      List.generate(12, (_) => FocusNode());
  Timer? _otpTimer;
  int _otpTimeLeft = 60;
  bool _isLoading = false;

  // UUID related variables
  final Uuid _uuid = Uuid();
  late String _sessionUuid;
  Timer? _uuidRefreshTimer;
  final int _uuidRefreshInterval =
      300; // Refresh UUID every 5 minutes (300 seconds)
  int _uuidTimeLeft = 300;

  Future<void> getToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      setState(() {
        deviceToken = token;
      });
    }
  }

  Future<void> isqrLoginCompleted() async {
    final loginStatus = AuthService();

    while (true) {
      try {
        final response = await loginStatus.tvLoginStatus(code: _sessionUuid);

        if (response['success'] == true) {
          Navigator.of(context).pop(true);
          break; // Exit the loop
        }
      } catch (e) {
        // We ignore the error and just try again
      }

      await Future.delayed(Duration(seconds: 2));
    }
  }

  @override
  void initState() {
    super.initState();

    _numPadFocusNode.requestFocus();
    _generateNewUuid();
    _startUuidRefreshTimer();
    getToken();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Force focus to the numpad on TV
        if (AppSizes.getDeviceType(context) == DeviceType.tv) {
          FocusScope.of(context).requestFocus(_numPadFocusNode);

          // Also request focus on the first numpad button
          if (_numPadButtonNodes.isNotEmpty) {
            _numPadButtonNodes[0].requestFocus();
          }
        }
      }
    });
  }

  String? _deviceType;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_deviceType == null) {
      // Prevent re-running if dependencies change
      _deviceType = AppSizes.getDeviceType(context);
      if (_deviceType == DeviceType.tv) {
        isqrLoginCompleted();
      }
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _numPadFocusNode.dispose();
    for (var node in _numPadButtonNodes) {
      node.dispose();
    }
    _otpTimer?.cancel();
    _uuidRefreshTimer?.cancel();
    super.dispose();
  }

  // Generate a new UUID for the QR code
  void _generateNewUuid() {
    setState(() {
      _sessionUuid = _uuid.v4();
      _uuidTimeLeft = _uuidRefreshInterval;
    });
    // Here you would also send this UUID to your backend to associate it with this TV session
    // _registerUuidWithBackend();
  }

  // Start timer to refresh UUID periodically
  void _startUuidRefreshTimer() {
    _uuidRefreshTimer?.cancel();
    _uuidRefreshTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_uuidTimeLeft > 0) {
          _uuidTimeLeft--;
        } else {
          // Time to generate a new UUID
          _generateNewUuid();

          // Show a brief notification that QR was refreshed
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('QR Code automatically refreshed with new login code'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      });
    });
  }

  void _handleNumPadInput(String value) {
    if (_isOtpSent) {
      if (value == 'clear') {
        if (_otpController.text.isNotEmpty) {
          _otpController.text =
              _otpController.text.substring(0, _otpController.text.length - 1);
        }
      } else if (value == 'submit') {
        _verifyOtp();
      } else {
        if (_otpController.text.length < 6) {
          _otpController.text += value;

          // Auto submit when OTP is complete
          if (_otpController.text.length == 6) {
            _verifyOtp();
          }
        }
      }
    } else {
      if (value == 'clear') {
        if (_phoneController.text.isNotEmpty) {
          _phoneController.text = _phoneController.text
              .substring(0, _phoneController.text.length - 1);
        }
      } else if (value == 'submit') {
        _sendOtp();
      } else {
        if (_phoneController.text.length < 10) {
          _phoneController.text += value;
        }
      }
    }
  }

  void _sendOtp() async {
    final connectivityResults = await Connectivity().checkConnectivity();
    final hasInternet = !connectivityResults.contains(ConnectivityResult.none);
    if (!hasInternet) ConnectivityUtils.showNoConnectionDialog(context);
    if (_phoneController.text.length == 10) {
      setState(() {
        _isLoading = true;
      });

      // Using Riverpod provider to send OTP
      final parameter = OtpDetailParameter(phone: _phoneController.text);

      try {
        // This will trigger the API call
        await ref.refresh(sentOtpProviderLogin(parameter).future);

        setState(() {
          _isOtpSent = true;
          _startOtpTimer();
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP sent successfully!')),
        );
      } catch (error) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter a valid 10-digit phone number')),
      );
    }
  }

  void _startOtpTimer() {
    _otpTimeLeft = 60;
    _otpTimer?.cancel();
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_otpTimeLeft > 0) {
          _otpTimeLeft--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  void _resendOtp() async {
    final connectivityResults = await Connectivity().checkConnectivity();
    final hasInternet = !connectivityResults.contains(ConnectivityResult.none);
    if (!hasInternet) ConnectivityUtils.showNoConnectionDialog(context);
    setState(() {
      _isLoading = true;
    });

    // Using Riverpod provider to resend OTP
    final parameter = OtpDetailParameter(phone: _phoneController.text);

    try {
      await ref.refresh(sentOtpProviderLogin(parameter).future);

      _otpController.clear();
      _startOtpTimer();
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP resent successfully!')),
      );
    } catch (error) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  void _verifyOtp() async {
    final connectivityResults = await Connectivity().checkConnectivity();
    final hasInternet = !connectivityResults.contains(ConnectivityResult.none);
    if (!hasInternet) ConnectivityUtils.showNoConnectionDialog(context);
    if (_otpController.text.length == 6) {
      setState(() {
        _isLoading = true;
      });

      // Using Riverpod provider to verify OTP
      final parameter = VerifyOtpParameter(
          phone: _phoneController.text,
          otp: _otpController.text,
          deviceToken: deviceToken);

      try {
        final response =
            await ref.refresh(verifyOtpProviderLogin(parameter).future);

        setState(() {
          _isOtpVerified = true;
          _isLoading = false;
        });
        _otpTimer?.cancel();
        ref.refresh(authUserProvider);
        ref.refresh(rentalProvider);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login successful! Redirecting...')),
        );

        // In real app, you would navigate to home screen here
        // Add a delay for showing success message before navigating
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.of(context).pop(true);
        });
      } catch (error) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 6-digit OTP')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTv = AppSizes.getDeviceType(context) == DeviceType.tv;

    // Build the QR code data URL with the UUID
    final String qrData = '$tvLoginUrl/tvLogin?code=$_sessionUuid';

    return Scaffold(
      body: SingleChildScrollView(
        child: RawKeyboardListener(
          focusNode: _numPadFocusNode,
          onKey: (RawKeyEvent event) {
            if (event is RawKeyDownEvent) {
              if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                setState(() {
                  _focusedNumPadIndex = (_focusedNumPadIndex - 3) % 12;
                  if (_focusedNumPadIndex < 0) _focusedNumPadIndex += 12;
                });
              } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                setState(() {
                  _focusedNumPadIndex = (_focusedNumPadIndex + 3) % 12;
                });
              } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                setState(() {
                  _focusedNumPadIndex = (_focusedNumPadIndex - 1) % 12;
                  if (_focusedNumPadIndex < 0) _focusedNumPadIndex += 12;
                });
              } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
                setState(() {
                  _focusedNumPadIndex = (_focusedNumPadIndex + 1) % 12;
                });
              } else if (event.logicalKey == LogicalKeyboardKey.select ||
                  event.logicalKey == LogicalKeyboardKey.enter) {
                // Handle numpad selection
                if (_focusedNumPadIndex == 9) {
                  // Clear button
                  _handleNumPadInput('clear');
                } else if (_focusedNumPadIndex == 11) {
                  // Submit button
                  _handleNumPadInput('submit');
                } else if (_focusedNumPadIndex == 10) {
                  // Zero button
                  _handleNumPadInput('0');
                } else {
                  _handleNumPadInput('${_focusedNumPadIndex + 1}');
                }
              }
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left side with QR code section
              isTv
                  ? Expanded(
                      flex: 1,
                      child: Container(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Scan to login',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColorDark,
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Display the UUID code
                            Text(
                              'Code: ${_sessionUuid.substring(0, 8)}...',
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).primaryColorDark,
                              ),
                            ),
                            const SizedBox(height: 5),
                            // Show the countdown timer for UUID refresh
                            Text(
                              'Code refreshes in: ${(_uuidTimeLeft ~/ 60).toString().padLeft(2, '0')}:${(_uuidTimeLeft % 60).toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context)
                                    .primaryColorDark
                                    .withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColorDark,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: QrImageView(
                                  data: qrData,
                                  version: QrVersions.auto,
                                  size: 200,
                                  backgroundColor: Colors.white),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              '1. Open your Google Lens in Your Mobile',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColorDark),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '2. Scan the QR code',
                              style: TextStyle(
                                color: Theme.of(context).primaryColorDark,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '3. You will be redirected to the login page',
                              style: TextStyle(
                                color: Theme.of(context).primaryColorDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SizedBox.shrink(),

              Expanded(
                flex: 1,
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  padding: const EdgeInsets.all(24),
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        )
                      : _isOtpVerified
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 80,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Login Successful!',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColorDark,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Redirecting to home...',
                                    style: TextStyle(
                                        color:
                                            Theme.of(context).primaryColorDark),
                                  ),
                                ],
                              ),
                            )
                          : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  !isTv
                                      ? const SizedBox(
                                          height: 100,
                                        )
                                      : SizedBox.shrink(),
                                  _isOtpSent
                                      ? const SizedBox.shrink()
                                      : const Text(
                                          'Login with Phone',
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.amber,
                                          ),
                                        ),
                                  SizedBox(height: isTv ? 20 : 50),
                                  if (!_isOtpSent) ...[
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade900,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      child: Row(
                                        children: [
                                          const Text(
                                            '+91 ',
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Expanded(
                                            child: TextField(
                                              keyboardType: isTv
                                                  ? TextInputType.none
                                                  : TextInputType.phone,
                                              controller: _phoneController,
                                              style: const TextStyle(
                                                  color: Colors.white),
                                              readOnly: true,
                                              decoration: InputDecoration(
                                                border: InputBorder.none,
                                                hintText: 'Enter mobile number',
                                                hintStyle: TextStyle(
                                                    color: Colors.grey[200]),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 15,
                                    )
                                  ] else ...[
                                    Text(
                                      'OTP sent to +91 ${_phoneController.text}',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .primaryColorDark),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: List.generate(
                                        6,
                                        (index) => Container(
                                          width: 40,
                                          height: 48,
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade900,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            index < _otpController.text.length
                                                ? _otpController.text[index]
                                                : '',
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    _otpTimeLeft > 0
                                        ? Text(
                                            'Resend OTP in $_otpTimeLeft seconds',
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .primaryColorDark),
                                          )
                                        : TextButton(
                                            onPressed: _resendOtp,
                                            child: const Text('Resend OTP'),
                                          ),
                                  ],
                                  SizedBox(height: 10),
                                  // Custom Number Pad
                                  GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      childAspectRatio: 2,
                                      crossAxisSpacing: 18,
                                      mainAxisSpacing: 15,
                                    ),
                                    itemCount: 12,
                                    itemBuilder: (context, index) {
                                      String buttonText;
                                      IconData? icon;
                                      Color bgColor = Colors.grey.shade500;

                                      if (index < 9) {
                                        buttonText = '${index + 1}';
                                      } else if (index == 9) {
                                        buttonText = 'Clear';
                                        icon = Icons.backspace;
                                      } else if (index == 10) {
                                        buttonText = '0';
                                      } else {
                                        buttonText =
                                            _isOtpSent ? 'Verify' : 'Continue';
                                        bgColor = Colors.amber.shade600;
                                      }

                                      return Focus(
                                        focusNode: _numPadButtonNodes[index],
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: _focusedNumPadIndex == index
                                                ? Colors.amber.shade800
                                                : bgColor,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                _focusedNumPadIndex = index;
                                              });

                                              if (index == 9) {
                                                // Clear button
                                                _handleNumPadInput('clear');
                                              } else if (index == 11) {
                                                // Submit button
                                                _handleNumPadInput('submit');
                                              } else if (index == 10) {
                                                // Zero button
                                                _handleNumPadInput('0');
                                              } else {
                                                _handleNumPadInput(
                                                    '${index + 1}');
                                              }
                                            },
                                            child: Center(
                                              child: icon != null
                                                  ? Icon(
                                                      icon,
                                                      color: Colors.white,
                                                      size: 24,
                                                    )
                                                  : Text(
                                                      buttonText,
                                                      style: TextStyle(
                                                        fontSize: index == 11
                                                            ? 16
                                                            : 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  if (isTv == false && _isOtpSent == false)
                                    Container(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 30, vertical: 30),
                                            width: double.infinity,
                                            height: 50,
                                            child: TextButton(
                                              onPressed: isIos?() {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      AlertDialog(
                                                    title: const Text(
                                                        "Leaving the App"),
                                                    content: const Text(
                                                      "You are about to open an external website to create your account. "
                                                      "This website is not operated by Apple, and Apple is not responsible for the privacy or security of any data you submit there.",
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        child: const Text(
                                                            "Cancel"),
                                                        onPressed: () =>
                                                            Navigator.of(
                                                                    context)
                                                                .pop(),
                                                      ),
                                                      TextButton(
                                                        child: const Text(
                                                            "Continue"),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                          launchUrl(
                                                            Uri.parse(
                                                                "https://nandipictures.in/signup"),
                                                            mode: LaunchMode
                                                                .externalApplication,
                                                          );
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }:(){
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const SignupPage(),
                                            ),
                                          );
                                        },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.transparent,
                                                side: const BorderSide(
                                                    color:
                                                        AppStyles.primaryColor),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                              child: const Text(
                                                'Create New account',
                                                style: TextStyle(
                                                    color: Colors.amber),
                                              ),
                                            ),
                                          )
                                ],
                              ),
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

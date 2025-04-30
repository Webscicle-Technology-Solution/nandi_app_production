import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nandiott_flutter/app/widgets/custombottombar.dart';
import 'package:nandiott_flutter/features/auth/loginpage_tv.dart';
import 'package:nandiott_flutter/features/profile/account_settings/account_settings_page.dart';
import 'package:nandiott_flutter/features/profile/profile_page.dart';
import 'package:nandiott_flutter/pages/detail_page.dart';
import 'package:nandiott_flutter/providers/checkauth_provider.dart';
import 'package:nandiott_flutter/providers/payment_provider.dart';
import 'package:nandiott_flutter/providers/rental_provider.dart';
import 'package:nandiott_flutter/providers/subscription_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class RentalPaymentRedirectPage extends ConsumerStatefulWidget {
  final String movieId;
  final String redirectUrl;

  const RentalPaymentRedirectPage({
    super.key,
    required this.movieId,
    required this.redirectUrl,
  });

  @override
  ConsumerState<RentalPaymentRedirectPage> createState() => _RentalPaymentRedirectPageState();
}

class _RentalPaymentRedirectPageState extends ConsumerState<RentalPaymentRedirectPage> {
  bool _hasOpenedUrl = false;
String userId='';
  @override
  void initState() {
    super.initState();
    // Refresh auth and payment info
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.refresh(rentalProvider);
      ref.refresh(authUserProvider);
      ref.refresh(rentPaymentProvider(
        PaymentDetailParameter(movieId: widget.movieId, redirectUrl: widget.redirectUrl),
      ));
    });
  }
@override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
        ref.refresh(subscriptionProvider(
        SubscriptionDetailParameter(userId: userId)));
      ref.refresh(rentalProvider);
      ref.refresh(authUserProvider);
      ref.refresh(rentPaymentProvider(
        PaymentDetailParameter(movieId: widget.movieId, redirectUrl: widget.redirectUrl),
      ));
    
  }
  @override
  Widget build(BuildContext context) {
 ref.watch(rentalProvider);
    final authUser = ref.watch(authUserProvider);
    final paymentAsyncValue = ref.watch(
      rentPaymentProvider(PaymentDetailParameter(
        movieId: widget.movieId,
        redirectUrl: widget.redirectUrl,
      )),
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Rental Payment"),
      leading: IconButton(onPressed: (){
               //  Navigator.pop(context); // Go back to the previous screen
           // Optionally, use Future.delayed to give it a moment to update.
        Future.delayed(Duration(milliseconds: 1000), () {
          print("userid for redirect in rental is ${userId}>>");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MovieDetailPage(movieId: widget.movieId,mediaType: "Movie",userId:userId ,)),
          );
        });
      }, icon: Icon(Icons.arrow_back)),
      ),
      body: authUser.when(
        data: (user) {
          if (user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Please login", style: TextStyle(fontSize: 16, color: Colors.red)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) =>  LoginScreen()),
                      );
                    },
                    child: const Text("Login"),
                  ),
                ],
              ),
            );
          }else{setState(() {
            userId=user.id;
          });}

          return paymentAsyncValue.when(
            data: (paymentUrl) {
              if (paymentUrl != null && !_hasOpenedUrl) {
                _hasOpenedUrl = true;
                _openRedirectUrl(paymentUrl);
              }

              return const Center(child: Text("Redirecting to payment..."));
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text("Error: $error")),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text("Error: $error")),
      ),
    );
  }

  void _openRedirectUrl(String url) async {
    final uri = Uri.parse(url);
    print("🔗 Launching URL: $url");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.inAppBrowserView); // 🔁 Opens in app browser
    } else {
      print("❌ Could not launch $url");
    }
  }
}









class SubscriptionPaymentRedirectPage extends ConsumerStatefulWidget {
  final String planName;
  final String redirectUrl;
  final String movieId;

  const SubscriptionPaymentRedirectPage({
    super.key,
    required this.planName,
    required this.redirectUrl,
    required this.movieId
  });

  @override
  ConsumerState<SubscriptionPaymentRedirectPage> createState() => _SubscriptionPaymentRedirectPageState();
}

class _SubscriptionPaymentRedirectPageState extends ConsumerState<SubscriptionPaymentRedirectPage> {
  bool _hasOpenedUrl = false;
String userId='';
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.refresh(authUserProvider);
      ref.refresh(
        subsciptionPaymentProvider(PaymentDetailParameter(
          planName: widget.planName,
          redirectUrl: widget.redirectUrl,
        )),
      );
    });
  }

  @override
  Widget build(BuildContext context) {

    final authUser = ref.watch(authUserProvider);
    final paymentAsyncValue = ref.watch(
      subsciptionPaymentProvider(PaymentDetailParameter(
        planName: widget.planName,
        redirectUrl: widget.redirectUrl,
      )),
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Subscription Payment"),leading: IconButton(onPressed: (){
                Future.delayed(Duration(milliseconds: 1000), () {
          print("userid for redirect in rental is ${userId}>>");
        widget.movieId == "" || widget.movieId.isEmpty? Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AccountSettingsPage()),
          ) : Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MovieDetailPage(movieId: widget.movieId,mediaType: "Movie",userId:userId ,)),
          );
        });
      }, icon: const Icon(Icons.arrow_back)),),
      body: authUser.when(
        data: (user) {
          if (user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Please login", style: TextStyle(fontSize: 16, color: Colors.red)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) =>  LoginScreen()),
                      );
                    },
                    child: const Text("Login"),
                  ),
                ],
              ),
            );
          }else{
            setState(() {
              userId=user.id;
            });
          }

          return paymentAsyncValue.when(
            data: (paymentUrl) {
              if (paymentUrl != null && !_hasOpenedUrl) {
                _hasOpenedUrl = true;
                _openRedirectUrl(paymentUrl);
              }

              return const Center(child: Text("Redirecting to payment..."));
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text("Error: $error")),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text("Error: $error")),
      ),
    );
  }

  void _openRedirectUrl(String url) async {
    final uri = Uri.parse(url);
    print("🔗 Launching URL: $url");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.inAppBrowserView); // Or use inAppBrowserView if needed
    } else {
      print("❌ Could not launch $url");
    }
  }
}
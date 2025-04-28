// import 'dart:convert';
// import 'dart:developer';
// import 'package:crypto/crypto.dart';
// import 'package:flutter/material.dart';
// import 'package:nandiott_flutter/app/widgets/custombottombar.dart';
// import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';

// class Phonepe {
//   int amount;
//   BuildContext context;

//   Phonepe({required this.context, required this.amount});

//   String merchantId = "UATM22FBWOVHDLUR";
//   String salt = "0e7eed21-c47a-43dd-bf06-d619b959e7f8";  
//   int saltIndex = 1;
//   String callbackUrl = "https://webhook.site/3112eb2a-0d98-483d-8ba7-76a40b41aa42";
//   String apiEndPoint = "/pg/v1/pay";

//   init() {
//     PhonePePaymentSdk.init("SANDBOX", null, merchantId, true)
//         .then((val) {
//       print("PhonePe SDK Initialized - $val");
//       startTransaction();
//     }).catchError((error) {
//       return <dynamic>{};
//     });
//   }

//   startTransaction() {
//     Map body = {
//       "merchantId": merchantId,
//       "merchantTransactionId": "MT7850590068188104",
//       "merchantUserId": "MUID123",
//       "amount": amount ,
//       "callbackUrl": callbackUrl,
//       "mobileNumber": "7025699003",
//       "paymentInstrument": {
//         "type": "PAY_PAGE"
//       }
//     };
//     // base64
//     String bodyEncoded = base64Encode(utf8.encode(json.encode(body)));
//     // checksum => sha256
//     // base64body + apiendpoints + salt 
//     var byteCodes = utf8.encode(bodyEncoded + apiEndPoint + salt);
//     String checksum = "${sha256.convert(byteCodes)}###$saltIndex";
//     var response=PhonePePaymentSdk.startTransaction(bodyEncoded, callbackUrl, checksum, "")
//         .then((success) {
//           print("checksum is $checksum");
//       log("Payment Success ${success}");
//       Navigator.pushAndRemoveUntil(
//           context, MaterialPageRoute(builder: (a) => ResponsiveNavigation()), (e) => false);
//     }).catchError((error) {
//       log("Payment Failed ${error}");
//     });
//   }
// }

// class PaymentWidget extends StatelessWidget {
//   final int amount;


//   PaymentWidget({ required this.amount});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Payment"),
//       ),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () {
//             // Create an instance of Phonepe and trigger payment
//             Phonepe phonepe = Phonepe(context: context, amount: amount);
//             phonepe.init();
//           },
//           child: Text("Make Payment"),
//         ),
//       ),
//     );
//   }
// }
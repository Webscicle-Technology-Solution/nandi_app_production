// // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // import 'package:nandiott_flutter/models/account_settings_model.dart';
// // import 'package:nandiott_flutter/services/auth_service.dart';

// // class AccountSettingsNotifier extends StateNotifier<AccountSettings>{
// //       final AuthService _authService;

// //   AccountSettingsNotifier(this._authService):super(AccountSettings(
// //     name:'',
// //     email:'',
// //     phone: '',
// //     subscriptionPlan: '',
// //     profilePicture: null
// //   ));
// //   }

// // //Define the Riverpod provider

// // final accountSettingsProvider= StateNotifierProvider<AccountSettingsNotifier, AccountSettings>((ref){
// //   return AccountSettingsNotifier(AuthService());
// // });

// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:nandiott_flutter/features/profile/account_settings/account_settings_notifier.dart';
// import 'package:nandiott_flutter/models/account_settings_model.dart';
// import 'package:nandiott_flutter/services/profile_service.dart';

// final profileServiceProvider = Provider<ProfileService>((ref) {
//   return ProfileService(); // Create the ProfileService instance
// });

// final accountSettingsProvider = StateNotifierProvider<AccountSettingsNotifier, AccountSettings>((ref) {
//   final profileService = ref.watch(profileServiceProvider); // Access ProfileService
//   return AccountSettingsNotifier(profileService); // Pass ProfileService to the Notifier
// });

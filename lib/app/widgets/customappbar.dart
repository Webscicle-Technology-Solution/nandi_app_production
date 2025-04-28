import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nandiott_flutter/pages/search_page.dart';
import 'package:nandiott_flutter/utils/Device_size.dart';
import 'package:nandiott_flutter/utils/appstyle.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showBackButton;
  final bool showActionIcon;
  final NetworkImage? image;

  const CustomAppBar({
    Key? key,
    this.title,
    this.showBackButton = false,
    this.showActionIcon = true,
    this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding:
          EdgeInsets.only(top: 5.0, bottom: 2.0),
      child: AppBar(
        toolbarHeight:  70.0,
        leading: showBackButton
            ? IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  size: AppSizes.getIconSize(context),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            : Container(
                margin: EdgeInsets.only(left:  20),
                height:  50,
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                  image: DecorationImage(
                    image: AssetImage('assets/logo/main-logo.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
        title: title != null && title!.isNotEmpty
            ? Text(
                title!,
                style: TextStyle(
                  fontSize: AppSizes.getTitleFontSize(context),
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
        centerTitle: true,
        actions: showActionIcon
            ? [
                // Watch the authUserProvider to conditionally show the login button
                // Consumer(
                //   builder: (context, ref, child) {
                //     final authUser = ref.watch(authUserProvider);

                //     // ref.invalidate(authUserProvider);

                //     return authUser.when(
                //       data: (user) {
                //         // Future.delayed(Duration(seconds: 2));
                //         if (user == null) {
                //           // User is not logged in, show the login button
                //           return ElevatedButton.icon(
                //             style: ElevatedButton.styleFrom(
                //               padding: EdgeInsets.symmetric(
                //                   vertical: 8.0,
                //                   horizontal:
                //                       16.0), // Adjust vertical padding to reduce height
                //             ),
                //             onPressed: () async {
                //               final login = await Navigator.push(
                //                 context,
                //                 MaterialPageRoute(
                //                     builder: (context) => LoginPage()),
                //               );
                //               print("is login = $login");
                //               if (login == true) {
                //                 ref.invalidate(authUserProvider);
                //               }
                //             },
                //             icon: Icon(Icons.login),
                //             label: Text('Login'),
                //           );
                //         } else {
                //           // User is logged in, don't show the login button
                //           return SizedBox(); // Empty widget
                //         }
                //       },
                //       loading: () => Container(),
                //       error: (error, stackTrace) => SizedBox(),
                //     );
                //   },
                // ),
                // SizedBox(width: isTV ? 50.0 : 30.0),
                Consumer(
                  builder: (context, ref, child) {
                    // final selectedFilter = ref.watch(filterProvider);
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                SearchPage(),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Icon(Icons.travel_explore, size: 25),
                          Padding(
                            padding: EdgeInsets.only(right:  20.0),
                            child: Text(
                              'Search',
                              style: TextStyle(
                                color: AppStyles.primaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ]
            : null,
        bottom: showBackButton
            ? PreferredSize(
                preferredSize: Size.fromHeight( 2.0),
                child: Container(
                  color: AppStyles.secondaryColor,
                  height:  2.0,
                ),
              )
            : null,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
           60);
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nandiott_flutter/app/widgets/skeltonLoader/filmSkelton.dart';
import 'package:nandiott_flutter/features/auth/page/loginpage_tv.dart';
import 'package:nandiott_flutter/features/profile/widget/historyCard_widget.dart';
import 'package:nandiott_flutter/features/profile/provider/watchHistory_provider.dart';
import 'package:nandiott_flutter/features/auth/providers/checkauth_provider.dart';
import 'package:nandiott_flutter/features/movieDetails/provider/detail_provider.dart';
import 'package:nandiott_flutter/features/profile/provider/series_watchhistory_provider.dart';
import 'package:nandiott_flutter/utils/Device_size.dart';

class WatchHistoryPage extends ConsumerStatefulWidget {
  const WatchHistoryPage({super.key});

  @override
  _WatchHistoryPageState createState() => _WatchHistoryPageState();
}

class _WatchHistoryPageState extends ConsumerState<WatchHistoryPage> {

  bool isButtonFocused = false;

  @override
  void initState() {
    super.initState();
    // We don't trigger the API call in initState, as we want to listen for changes
    final userAsyncValue = ref.read(authUserProvider);

    userAsyncValue.when(
      data: (user) {
        if (user != null) {
          // Initially trigger the watch history provider when user enters the page
          ref.read(watchHistoryProvider(user.id));
          // _refreshWatchHistory(user.id);
        }else{

        }
      },
      loading: () {},
      error: (error, _) {},
    );
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    Future.microtask(() => ref.invalidate(watchHistoryProvider));
    Future.microtask(() => ref.invalidate(movieDetailProvider));
    Future.microtask(() => ref.invalidate(tvSeriesWatchProgressProvider));
  }

  @override
  Widget build(BuildContext context) {
    final userAsyncValue = ref.watch(authUserProvider);
    final isTv = AppSizes.getDeviceType(context) == DeviceType.tv;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Watch History"),
      ),
      body: userAsyncValue.when(
        data: (user) {
          if (user != null) {
            // Trigger the watch history API whenever the user is valid
            final watchHistoryAsyncValue =
                ref.watch(watchHistoryProvider(user.id));

            return watchHistoryAsyncValue.when(
              data: (history) {
                if (history.isEmpty) {
                  return const Center(
                      child: Text("You haven't watched anything yet."));
                }

                // Filter out items that failed to load movie details
                final validHistory = history.where((item) {
                  final movieDetail =
                      ref.watch(movieDetailProvider(MovieDetailParameter(
                    movieId: item.tvSeriesId ?? item.contentId,
                    mediaType: item.contentType,
                  )));

                  return movieDetail is AsyncData;
                }).toList();

                if (validHistory.isEmpty) {
                  Future.delayed(const Duration(seconds: 3));
                  return const Center(
                      child: Text("No valid watch history available."));
                }

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isTv ? 5 : 3, // Display 3 items per row
                      crossAxisSpacing:
                          8.0, // Spacing between cards horizontally
                      mainAxisSpacing: 8.0, // Spacing between cards vertically
                      childAspectRatio:
                          0.75, // Aspect ratio for each card (adjust as needed)
                    ),
                    itemCount: validHistory.length,
                    itemBuilder: (context, index) {
                      final item = validHistory[index];
                      return HistorycardWidget(historyItem: item);
                    },
                  ),
                );
              },
              loading: () {
                return Center(
                    child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Row(
                                children: List.generate(5, (index) {
                                  return const SkeletonLoader(); // Use skeleton loader for each film card
                                }),
                              ),
                            ))));
              },
              error: (error, _) => Center(child: Text("Error: $error")),
            );
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Please log in to see your watch history.",
                      style: TextStyle(color: Colors.red)),
                  const SizedBox(height: 20),
                  Container(
                      decoration: BoxDecoration(
                        border: 
                            Border.all(color: Colors.amber, width: 2),
                            
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: ElevatedButton(
                        onFocusChange: (value) {
                      setState(() {
                        isButtonFocused = value;
                      });
                    },
                    onPressed: () async {
                      // Navigate to login
                      final loginResult = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                  
                      if (loginResult == true) {
                        ref.invalidate(watchHistoryProvider);
                        ref.invalidate(movieDetailProvider);
                        ref.invalidate(tvSeriesWatchProgressProvider);
                      }
                    },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          backgroundColor: isButtonFocused && isTv
                              ? Colors.amber
                              : Theme.of(context).primaryColorLight, // fallback default
                        ),
                        child: Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 16,
                            color: isButtonFocused && isTv
                                ? Colors.black
                                : Colors.white,
                          ),
                        ),
                      ),
                    
                    ),
                ],
              ),
            );
          }
        },
        loading: () {
          return Center(
              child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Row(
                          children: List.generate(5, (index) {
                            return const SkeletonLoader(); // Use skeleton loader for each film card
                          }),
                        ),
                      ))));
        },
        error: (error, _) => Center(child: Text("Error: $error")),
      ),
    );
  }
}

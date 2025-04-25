import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nandiott_flutter/app/widgets/customappbar.dart';
import 'package:nandiott_flutter/app/widgets/film_card_widget.dart';
import 'package:nandiott_flutter/app/widgets/filterSelector_widget.dart';
import 'package:nandiott_flutter/features/home/filter_container_widget.dart';
import 'package:nandiott_flutter/providers/filter_provider.dart';
import 'package:nandiott_flutter/providers/search_provider.dart';
import 'package:nandiott_flutter/utils/appstyle.dart';
import 'package:nandiott_flutter/utils/Device_size.dart';
import 'dart:async';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final Map<String, String> mediaTypeMap = {
    'Movies': 'movies',
    'Series': 'tvseries',
    'Short Film': 'shortfilms',
    'Documentary': 'documentaries',
    'Music': 'videosongs',
  };

  final _debounceDuration = Duration(milliseconds: 800);
  Timer? _debounceTimer;

  final FocusNode _searchFieldFocus = FocusNode();
  final FocusNode _filterRowFocus = FocusNode();
  final FocusNode _gridViewFocus = FocusNode();
  final FocusNode _filmcardFocus = FocusNode();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();

    // Optional: Auto-focus on search field if on TV
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isTV = AppSizes.getDeviceType(context) == DeviceType.tv;
      if (isTV) {
        _searchFieldFocus.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchFieldFocus.dispose();
    _filterRowFocus.dispose();
    _gridViewFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTV = AppSizes.getDeviceType(context) == DeviceType.tv;
    final crossAxisCount = isTV ? 5 : 3;
      final FocusNode _filterFocusNode = FocusNode();
  final List<FocusNode> _filterFocusNodes = [];  
  int _focusedFilterIndex = 0;
    final selectedFilter = ref.watch(searchFilterProvider);
    final mediaType = mediaTypeMap[selectedFilter] ?? 'movies';
    final searchController = ref.watch(searchTextControllerProvider);
    final searchState = ref.watch(searchPaginationProvider);
    final searchNotifier = ref.read(searchPaginationProvider.notifier);

    ref.listen<String>(searchFilterProvider, (previous, next) {
      final query = ref.read(searchQueryProvider);
      if (query.isNotEmpty) {
        final newMediaType = mediaTypeMap[next] ?? 'movies';
        searchNotifier.fetchSearchResults(newMediaType, reset: true);
      }
    });
    

    return Scaffold(
      appBar: isTV
          ? null
          : const CustomAppBar(
              title: 'Search', showBackButton: true, showActionIcon: false),
      body: RawKeyboardListener(
        autofocus: true,
        focusNode: FocusNode(),
        onKey: (event) {
          if (event is RawKeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.arrowDown &&
                _searchFieldFocus.hasFocus) {
              _gridViewFocus.requestFocus();
            } else if (event.logicalKey == LogicalKeyboardKey.arrowUp &&
                _gridViewFocus.hasFocus) {
              _searchFieldFocus.requestFocus();
            } else if (event.logicalKey == LogicalKeyboardKey.escape &&
                _searchFieldFocus.hasFocus) {
              _filterRowFocus.requestFocus();
            } else if (event.logicalKey == LogicalKeyboardKey.enter &&
                _searchFieldFocus.hasFocus) {
              setState(() {
                _isEditing = true;
              });
            }
          }
        },
        child: Column(
          children: [
            FilterSelector(
                    
                    onFilterSelected: (filter) {
                      ref.read(selectedFilterProvider.notifier).state = filter;
                    },
                  ),
            // Focus(
            //   focusNode: _filterRowFocus,
            //   child: SingleChildScrollView(
            //     scrollDirection: Axis.horizontal,
            //     padding: const EdgeInsets.all(8),
            //     child: Row(
            //       children: mediaTypeMap.keys.map((filter) {
            //         return FilterContainer(
            //           filterOption: filter,
            //           isSelected: selectedFilter == filter,
            //           onTap: () {
            //             ref.read(searchFilterProvider.notifier).state = filter;
            //           },
            //           focusNode: FocusNode(),
            //         );
            //       }).toList(),
            //     ),
            //   ),
            // ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: TextFormField(
                onTap: () {
                  if (!isTV) return; // On mobile, do default behavior
                  setState(() {
                    _isEditing = true;
                  });
                  // You may need to open keyboard manually here depending on platform
                },
                controller: searchController,
                readOnly: !isTV ||
                    !_isEditing, // allow editing only when _isEditing is true
                focusNode: _searchFieldFocus,
                autofocus: false,
                onChanged: (value) {
                  _debounceTimer?.cancel();
                  ref.read(searchQueryProvider.notifier).state = value;

                  _debounceTimer = Timer(_debounceDuration, () {
                    searchNotifier.updateQuery(value);
                    searchNotifier.fetchSearchResults(mediaType, reset: true);
                  });
                },
                onEditingComplete: () {
                  if (isTV) {
                    setState(() {
                      _isEditing = false;
                    });
                    _gridViewFocus.requestFocus();
                  }
                },
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    focusColor: Theme.of(context).primaryColorLight,
                    icon: const Icon(Icons.search,
                        size: 35, color: AppStyles.primaryColor),
                    onPressed: () {
                      final trimmed = searchController.text.trim();
                      ref.read(searchQueryProvider.notifier).state = trimmed;
                      searchNotifier.updateQuery(trimmed);
                      searchNotifier.fetchSearchResults(mediaType, reset: true);
                      if (isTV) {
                        setState(() {
                          _isEditing = false;
                        });
                        _gridViewFocus.requestFocus();
                      }
                    },
                  ),
                  labelText: 'Search your favorite $mediaType',
                ),
              ),
            ),
            Expanded(
              child: Focus(
                focusNode: _gridViewFocus,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (scrollInfo) {
                      if (scrollInfo.metrics.pixels ==
                              scrollInfo.metrics.maxScrollExtent &&
                          !searchState.isLastPage &&
                          !searchState.isLoading) {
                        searchNotifier.fetchSearchResults(mediaType);
                      }
                      return false;
                    },
                    child: searchState.isLoading && searchState.movies.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : searchState.movies.isEmpty &&
                                searchState.query.isNotEmpty
                            ? const Center(
                                child: Text("No results found",
                                    style: TextStyle(fontSize: 18)))
                            : GridView.builder(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  childAspectRatio: 0.75,
                                  crossAxisSpacing: 2.0,
                                  mainAxisSpacing: 8.0,
                                ),
                                itemCount: searchState.movies.length +
                                    (searchState.isLoading ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index == searchState.movies.length) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }
                                  return FilmCard(
                                    key: ValueKey(searchState.movies[index].id),
                                    film: searchState.movies[index],
                                    mediaType: mediaType,
                                    // focusNode: _filmcardFocus,
                                  );
                                },
                              ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Also make sure to update FilterContainer to properly handle focus for TV navigation
// class FilterContainer extends StatefulWidget {
//   final String filterOption;
//   final bool isSelected;
//   final VoidCallback onTap;

//   const FilterContainer({
//     super.key,
//     required this.filterOption,
//     required this.isSelected,
//     required this.onTap,
//   });

//   @override
//   _FilterContainerState createState() => _FilterContainerState();
// }

// class _FilterContainerState extends State<FilterContainer> {
//   late FocusNode _focusNode;

//   @override
//   void initState() {
//     super.initState();
//     _focusNode = FocusNode();
//   }

//   @override
//   void dispose() {
//     _focusNode.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Determine if we're on TV or mobile
//     final isTV = AppSizes.getDeviceType(context) == DeviceType.tv;

//     // Get the current theme (either light or dark)
//     bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

//     return Focus(
//       focusNode: _focusNode,
//       onFocusChange: (hasFocus) {
//         if (hasFocus && isTV) {
//           // Only tap on focus gain for TV
//           setState(() {});
//         }
//       },
//       onKey: (FocusNode node, RawKeyEvent event) {
//         if (event is RawKeyDownEvent &&
//             (event.logicalKey == LogicalKeyboardKey.select ||
//                 event.logicalKey == LogicalKeyboardKey.enter)) {
//           widget.onTap();
//           return KeyEventResult.handled;
//         }
//         return KeyEventResult.ignored;
//       },
//       child: GestureDetector(
//         onTap: widget.onTap,
//         child: Container(
//           padding: isTV
//               ? EdgeInsets.symmetric(horizontal: 14, vertical: 12)
//               : EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//           margin: isTV ? EdgeInsets.all(8) : EdgeInsets.all(4),
//           decoration: BoxDecoration(
//             // Set the container's background color based on the theme
//             color: isDarkMode ? Colors.grey[900] : Colors.grey[50],
//             // Highlight the border when focused on TV
//             border: _focusNode.hasFocus || widget.isSelected
//                 ? Border.all(color: Colors.amber, width: 2.0)
//                 : Border.all(color: Colors.transparent),
//             borderRadius: BorderRadius.circular(isTV ? 12 : 10),
//             boxShadow: _focusNode.hasFocus || widget.isSelected
//                 ? [
//                     BoxShadow(
//                         color: Colors.amber.withOpacity(0.5),
//                         blurRadius: 8,
//                         spreadRadius: 1)
//                   ]
//                 : null,
//           ),
//           child: Text(
//             widget.filterOption,
//             style: TextStyle(
//               fontSize: isTV ? 14 : 13,
//               fontWeight: _focusNode.hasFocus || widget.isSelected
//                   ? FontWeight.bold
//                   : FontWeight.normal,
//               color: _focusNode.hasFocus || widget.isSelected
//                   ? Colors.amber
//                   : null,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

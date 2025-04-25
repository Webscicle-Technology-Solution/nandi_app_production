import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nandiott_flutter/app/widgets/filterSelector_widget.dart';
import 'package:nandiott_flutter/features/home/filter_container_widget.dart';
import 'package:nandiott_flutter/providers/filter_provider.dart';

class FilterSelector extends ConsumerWidget {
  final Function(String) onFilterSelected;

  const FilterSelector({
    Key? key,
    required this.onFilterSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visibleContentTypesAsync = ref.watch(visibleContentTypesProvider);
    final selectedFilter = ref.watch(selectedFilterProvider);

    return visibleContentTypesAsync.when(
      data: (contentTypes) {
        final displayNames = contentTypes.map((typeData) {
          final contentType = typeData['contentType'] as String;
          return getDisplayName(contentType);
        }).toList();
        
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: displayNames.map((displayName) {
                return FilterContainer(
                  filterOption: displayName,
                  isSelected: selectedFilter == displayName,
                  onTap: () => onFilterSelected(displayName),
                  focusNode: FocusNode(),
                );
              }).toList(),
            ),
          ),
        );
      },
      loading: () => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: List.generate(5, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Container(
                  height: 35,
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
      error: (error, stack) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            // Fallback to hardcoded filters if API fails
            children: [
              'Movies',
              'Series',
              'Short Film',
              'Documentary',
              'Music'
            ].map((filter) {
              return FilterContainer(
                filterOption: filter,
                isSelected: selectedFilter == filter,
                onTap: () => onFilterSelected(filter), focusNode: FocusNode(),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:nandiott_flutter/models/tvSeries_model.dart';

Future<void> showSeasonSelectorDialog({
  required BuildContext context,
  required List<Season> seasons,
  required void Function(Season) onSelected,
}) async {
  final ScrollController scrollController = ScrollController();

  await showDialog(
    context: context,
    builder: (ctx) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: SizedBox(
          height: 400,
          width: double.maxFinite,
          child: Scrollbar(
            thumbVisibility: true, // always show the scrollbar thumb
            controller: scrollController,
            child: ListView.builder(
              controller: scrollController,
              itemCount: seasons.length,
              itemBuilder: (context, index) {
                final season = seasons[index];
                return ListTile(
                  title: Text('Season ${season.seasonNumber}'),
                  subtitle: season.status != null
                      ? Text('Status: ${season.status}')
                      : null,
                  onTap: () {
                    onSelected(season);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ),
      );
    },
  );
}

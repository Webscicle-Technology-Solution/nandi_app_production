
import 'package:flutter/material.dart';
import 'package:nandiott_flutter/services/getBannerPoster_service.dart';
import 'package:nandiott_flutter/utils/banner_poster_util.dart';

class BannerPosterImageWidget extends StatefulWidget {
  final String mediaType;
  final String mediaId;
  final double height;
  final String imageType;

  const BannerPosterImageWidget({
    super.key,
    required this.mediaType,
    required this.mediaId,
    this.height = 300,
    required this.imageType,  // Added imageType to choose banner or poster
  });

  @override
  _BannerPosterImageWidgetState createState() => _BannerPosterImageWidgetState();
}

class _BannerPosterImageWidgetState extends State<BannerPosterImageWidget> {
  String imgUrl = "";
  late PosterHelper _posterHelper;

  @override
  void initState() {
    super.initState();
    _posterHelper = PosterHelper(getBannerPosterService());
    _loadImage();
  }

  Future<void> _loadImage() async {
    String imageUrl = "";

    if (widget.imageType == "poster") {
      imageUrl = await _posterHelper.getPosterImage(
        mediaType: widget.mediaType,
        mediaId: widget.mediaId,
      );
    } else if (widget.imageType == "banner") {
      imageUrl = await _posterHelper.getBannerImage(
        mediaType: widget.mediaType,
        mediaId: widget.mediaId,
      );
    }

    if (mounted) {
      setState(() {
        imgUrl = imageUrl;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: widget.height,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: imgUrl.isEmpty
              ? const AssetImage('assets/images/placeholder.png') as ImageProvider
              : NetworkImage(imgUrl),
          fit: BoxFit.cover,  // Ensures the image covers the space
        ),
      ),
    );
  }
}

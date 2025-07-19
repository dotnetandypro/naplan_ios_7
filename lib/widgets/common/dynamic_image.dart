import 'dart:async';
import 'package:flutter/material.dart';

class DynamicImage extends StatefulWidget {
  final String imageUrl;
  final double maxWidth; // Allows flexible width control

  const DynamicImage(
      {Key? key, required this.imageUrl, this.maxWidth = double.infinity})
      : super(key: key);

  @override
  _DynamicImageState createState() => _DynamicImageState();
}

class _DynamicImageState extends State<DynamicImage> {
  Future<Size>? _imageSizeFuture;

  @override
  void initState() {
    super.initState();
    _imageSizeFuture = _getImageSize(widget.imageUrl);
  }

  Future<Size> _getImageSize(String imageUrl) async {
    final Completer<Size> completer = Completer<Size>();
    final Image image = Image.network(imageUrl);

    image.image.resolve(ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        completer.complete(
            Size(info.image.width.toDouble(), info.image.height.toDouble()));
      }),
    );

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Size>(
      future: _imageSizeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child:
                  CircularProgressIndicator()); // ✅ Show loader while fetching
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Center(
              child:
                  Text("Image failed to load")); // ✅ Handle errors gracefully
        }

        double aspectRatio = snapshot.data!.width / snapshot.data!.height;
        return LayoutBuilder(
          builder: (context, constraints) {
            double width = widget.maxWidth == double.infinity
                ? constraints.maxWidth
                : widget.maxWidth;
            return Container(
              width: width,
              height: width / aspectRatio, // ✅ Maintain original aspect ratio
              child: Image.network(
                widget.imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    Text("Image not found"),
              ),
            );
          },
        );
      },
    );
  }
}

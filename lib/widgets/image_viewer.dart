import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImageViewer extends StatefulWidget {
  const ImageViewer({super.key, required this.image});

  final String image;

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Center(
        child: Container(
          color: Colors.black54,
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // top bar
              Padding(
                padding: EdgeInsets.all(8),
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        'Preview image',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 3,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          Icons.close,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                thickness: 1,
                color: Colors.white54,
              ),

              // main box
              Padding(
                padding: EdgeInsets.all(8),
                child: Container(
                  child: CachedNetworkImage(
                    imageUrl: widget.image,
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                    // Ensure the image is always visible
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,
                    // Adjust the image loading duration (optional)
                    fadeInDuration: Duration(milliseconds: 500),
                    fadeOutDuration: Duration(milliseconds: 1000),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

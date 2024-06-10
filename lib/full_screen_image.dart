import 'dart:io';
import 'package:flutter/material.dart';

class FullScreenImage extends StatefulWidget {
  const FullScreenImage({super.key, required this.image});

  final File image;

  @override
  State<FullScreenImage> createState() {
    return _FullScreenImageState();
  }
}

class _FullScreenImageState extends State<FullScreenImage> {
  double rotationAngle = 0;

  void _rotateImage() {
    setState(() {
      rotationAngle += 90; // Rotate 90 degrees clockwise
      if (rotationAngle >= 360) {
        rotationAngle = 0; // Reset to 0 degrees after 360 degrees
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Transform.rotate(
              angle: rotationAngle * (3.1415926535897932 / 180),
              child: Image.file(widget.image),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: _rotateImage,
                child: const Text("Rotate Image 90°"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

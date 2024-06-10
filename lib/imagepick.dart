import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class ImagePick extends StatefulWidget {
  const ImagePick({super.key});

  @override
  _ImagePickState createState() => new _ImagePickState();
}

class _ImagePickState extends State<ImagePick> {
  File? image;

  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);

      if (image == null) return;

      final imageTemp = File(image.path);

      setState(() => this.image = imageTemp);

    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

    Future pickImageC() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.camera);

      if (image == null) return;

      final imageTemp = File(image.path);

      setState(() => this.image = imageTemp);

    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
          children: [
            MaterialButton(
              onPressed: pickImage,
              color: Colors.purple,
              child: const Text("Image from gallery"),
            ),
            MaterialButton(
              onPressed: pickImageC,
              color: Colors.purple,
              child: const Text("Image from camera"),
            ),
            const SizedBox(height: 20,),
            image != null ? Image.file(image!) : const Text("no image selected")
          ],
        ),
      );
  }
}

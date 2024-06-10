
import 'dart:io';

import 'package:bitirmeson/viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ImagePickPage extends StatelessWidget {
  Future<File> cropImage(var image) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: image!.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 100,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Cropper',
        ),
      ],
    );
    File newfile = File(croppedFile!.path);
    return newfile;
  }

  Future<String?> uploadImageToFirebase(File image) async {
    try {
      String fileName = 'images/${DateTime
          .now()
          .millisecondsSinceEpoch}.jpg';
      Reference ref = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = ref.putFile(image);

      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<File?> getImageFromSource(ImageSource source, bool toCrop) async {
    var image = await ImagePicker().pickImage(source: source);
    if (image == null) return null;
    if (toCrop) {
      var croppedImage = await cropImage(File(image.path));
      return croppedImage;
    }
    return File(image.path);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: ChangeNotifierProvider<ViewModel>(
          create: (context) => ViewModel(),
          child: Consumer<ViewModel>(
            builder: (context, viewmodel, child) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Resmin büyük boyutta gösterilmesi
                    viewmodel.image != null
                        ? Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: FileImage(viewmodel.image!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    )
                        : Icon(
                      Icons.camera,
                      size: 70,
                    ),
                    SizedBox(height: 20),
                    // Boşluk ekleyerek butonların alt kısmında görüntüleme
                    ElevatedButton(
                      onPressed: () async {
                        var image = await getImageFromSource(
                            ImageSource.gallery, viewmodel.cropAfterPicked);
                        if (image == null) return;
                        viewmodel.setImage(image);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                      ),
                      child: Text("Get image from gallery"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        var image = await getImageFromSource(
                            ImageSource.camera, viewmodel.cropAfterPicked);
                        if (image == null) return;
                        viewmodel.setImage(image);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                      ),
                      child: Text("Get image from camera"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (viewmodel.image == null) return;
                        var image = await cropImage(viewmodel.image);
                        if (image == null) return;
                        viewmodel.setImage(image);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                      ),
                      child: Text("Crop image"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await viewmodel.uploadImage();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Image uploaded successfully'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                      ),
                      child: Text("Upload image"),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
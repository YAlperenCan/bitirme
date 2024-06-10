import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart'as firebase_storage;
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewModel extends ChangeNotifier {
  File? image;
  bool cropAfterPicked = false;

  void setImage(File newImage) {
    image = newImage;
    notifyListeners();
  }

  void setCropAfterPicked(bool value) {
    cropAfterPicked = value;
    notifyListeners();
  }

  Future<void> uploadImage() async {
    if (image == null) return;

    try {
      // Kullanıcıyı al
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("No user logged in");
        return;
      }

      // Benzersiz dosya adı oluştur
      String fileName = '${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Firebase Storage referansı oluştur
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('uploads/${user.uid}/$fileName');

      // Dosyayı yükle
      await ref.putFile(image!);

      // Dosyanın URL'sini al
      String imageUrl = await ref.getDownloadURL();

      // Firestore'a fotoğraf bilgilerini ekle
      await FirebaseFirestore.instance.collection('photos').add({
        'userId': user.uid,
        'imageUrl': imageUrl,
        'rating': 0,
        'votecounter': 0,// Başlangıç rating değeri
        'timestamp': FieldValue.serverTimestamp(),
      });

      print('Image uploaded successfully: $imageUrl');
    } catch (e) {
      print('Error uploading image: $e');
    }
  }
}
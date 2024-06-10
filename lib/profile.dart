import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bitirmeson/Auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ChangePasswordScreen.dart';
import 'LoginScreen.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final User? user = AuthService().currentUser;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _fetchUserProfileImage();
  }

  Future<void> _fetchUserProfileImage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (snapshot.exists) {
      setState(() {
        _profileImageUrl = snapshot.data()?['profileImageUrl'];
      });
    }
  }

  Future<void> _uploadProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final file = File(pickedFile.path);
      final storageRef = FirebaseStorage.instance.ref().child('profile_images').child(user.uid);

      await storageRef.putFile(file);
      final downloadUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'profileImageUrl': downloadUrl,
      }, SetOptions(merge: true));

      setState(() {
        _profileImageUrl = downloadUrl;
      });
    }
  }

  Future<Map<String, String>> getUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return {};
    return {
      'username': user.displayName ?? 'Anonymous',
      'email': user.email ?? 'No email',
    };
  }

  Future<List<Map<String, dynamic>>> getUserImages() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final snapshot = await FirebaseFirestore.instance
        .collection('photos')
        .where('userId', isEqualTo: user.uid)
        .get();

    return snapshot.docs.map((doc) => {
      'imageUrl': doc.data()['imageUrl'],
      'rating': doc.data()['rating'] ?? 0,
    }).toList();
  }

  Future<void> signOut(BuildContext context) async {
    await AuthService().signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  void _refreshProfilePage() {
    setState(() {
      _fetchUserProfileImage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              const PopupMenuItem(
                child: Text('Change Password'),
                value: 'change_password',
              ),
              const PopupMenuItem(
                child: Text('Log Out'),
                value: 'log_out',
              ),
            ],
            onSelected: (value) async {
              if (value == 'change_password') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChangePasswordScreen()),
                );
              } else if (value == 'log_out') {
                signOut(context);
                await FirebaseAuth.instance.signOut();
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: Center(
        child: FutureBuilder<Map<String, String>>(
          future: getUserData(),
          builder: (context, userDataSnapshot) {
            if (userDataSnapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (userDataSnapshot.hasError) {
              return Text('Error: ${userDataSnapshot.error}');
            } else if (!userDataSnapshot.hasData) {
              return const Text('Data not found.');
            } else {
              return FutureBuilder<List<Map<String, dynamic>>>(
                future: getUserImages(),
                builder: (context, imagesSnapshot) {
                  if (imagesSnapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (imagesSnapshot.hasError) {
                    return Text('Error: ${imagesSnapshot.error}');
                  } else if (!imagesSnapshot.hasData) {
                    return const Text('Images not found.');
                  } else {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 80,
                          backgroundImage: _profileImageUrl != null
                              ? CachedNetworkImageProvider(_profileImageUrl!) as ImageProvider<Object>
                              : const AssetImage('assets/default_avatar.jpg') as ImageProvider<Object>,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _uploadProfileImage,
                          child: const Text('Upload Profile Photo'),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          userDataSnapshot.data!['username'] ?? 'Username',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          userDataSnapshot.data!['email'] ?? 'Email',
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                            ),
                            itemCount: imagesSnapshot.data!.length,
                            itemBuilder: (context, index) {
                              final imageData = imagesSnapshot.data![index];
                              final newRating = imageData['rating'].round();
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FullScreenImage(
                                        imageUrl: imageData['imageUrl'],
                                        onDelete: _refreshProfilePage,
                                      ),
                                    ),
                                  );
                                },
                                child: Stack(
                                  alignment: Alignment.bottomLeft,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(1.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: CachedNetworkImageProvider(
                                              imageData['imageUrl'],
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      color: Colors.black.withOpacity(0.4),
                                      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                      child: Text(
                                        '$newRating',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    );
                  }
                },
              );
            }
          },
        ),
      ),
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onDelete;

  const FullScreenImage({Key? key, required this.imageUrl, required this.onDelete}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: IconButton(
              icon: Icon(Icons.delete),
              iconSize: 30,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Delete Image'),
                      content: Text('Are you sure you want to delete the image?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context); // İletişim kutusunu kapat
                          },
                          child: Text('No'),
                        ),
                        TextButton(
                          onPressed: () async {
                            await deleteImage(context);
                          },
                          child: Text('Yes'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
      ],
        ),
        body: GestureDetector(
          onTap: () {
            Navigator.pop(context); // Ekranın herhangi bir yerine tıklanıldığında ekranı kapat
          },
          child: Center(
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> deleteImage(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('photos')
        .where('imageUrl', isEqualTo: imageUrl)
        .where('userId', isEqualTo: user.uid)
        .get()
        .then((snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.delete();
      }
    });

    Navigator.pop(context); // İletişim kutusunu kapat
    Navigator.pop(context); // FullScreenImage ekranını kapat
    onDelete(); // Profil ekranını güncelle
  }
}


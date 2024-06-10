import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Oylama extends StatefulWidget {
  const Oylama({Key? key}) : super(key: key);

  @override
  State<Oylama> createState() {
    return _OylamaState();
  }
}

class _OylamaState extends State<Oylama> {
  double _rating = 0;
  double _sliderValue = 0;
  int _roundedSliderValue = 0; // Yuvarlanmış slider değeri
  String? _randomImageUrl;
  String? _currentImageId;
  bool _isSliding = false;

  @override
  void initState() {
    super.initState();
    _fetchRandomNonUserImage();
  }

  Future<void> _fetchRandomNonUserImage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('photos')
        .where('userId', isNotEqualTo: user.uid)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final randomIndex =
      (snapshot.docs.length * (DateTime.now().millisecondsSinceEpoch % 1000) / 1000).floor();
      setState(() {
        _randomImageUrl = snapshot.docs[randomIndex].data()['imageUrl'];
        _currentImageId = snapshot.docs[randomIndex].id;
      });
    }
  }

  Future<void> _submitRating() async {
    if (_currentImageId != null) {
      // Mevcut rating ve vote counter değerlerini al
      var documentSnapshot = await FirebaseFirestore.instance.collection('photos').doc(_currentImageId).get();

      double currentRating = (documentSnapshot.data()?['rating'] ?? 0).toDouble();
      double voteCounter = (documentSnapshot.data()?['votecounter'] ?? 0).toDouble();

      // Yeni oy sayısını artır
      voteCounter += 1;

      // Yeni rating'i hesapla
      double newRating = ((currentRating * (voteCounter - 1)) + _rating) / voteCounter;

      // Yeni rating ve vote counter değerlerini Firebase Firestore'a kaydet
      await FirebaseFirestore.instance.collection('photos').doc(_currentImageId).update({'rating': newRating, 'votecounter': voteCounter});

      // Yeni bir rastgele fotoğraf yüklemek için fonksiyonu tekrar çağırın
      await _fetchRandomNonUserImage();
      setState(() {}); // Animasyonun çalışması için setState çağrısı
    }
  }

  @override
  Widget build(BuildContext context) {
    _roundedSliderValue = _sliderValue.toInt(); // Slider değerini tam sayıya yuvarla
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 500),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: _randomImageUrl != null
                    ? Container(
                  key: ValueKey<String>(_randomImageUrl!), // Her yeni görüntü için farklı bir key kullanılıyor
                  width: double.infinity,
                  height: double.infinity,
                  child: Image.network(
                    _randomImageUrl!,
                    fit: BoxFit.cover,
                  ),
                )
                    : const CircularProgressIndicator(),
              ),
            ),
            if (_isSliding)
            // Slider basılı tutulduğunda
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width, // Ekranın genişliği kadar
                  height: MediaQuery.of(context).size.height, // Ekranın yüksekliği kadar
                  color: Colors.black.withOpacity(0.5), // Saydam siyah arka plan
                  alignment: Alignment.center,
                  child: Text(
                    '$_roundedSliderValue', // Yuvarlanmış slider değerini göster
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 200,
                    ),
                  ),
                ),
              ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Slider(
                      value: _sliderValue,
                      min: 0.0,
                      max: 10,
                      divisions: 10,
                      activeColor: Colors.white, // Basıldığında tamamen beyaz
                      inactiveColor: Colors.black.withOpacity(0.1), // Saydam
                      onChanged: (newValue) {
                        setState(() {
                          _sliderValue = newValue;
                          _rating = newValue; // Slider değeri RatingBar'a aktarılıyor
                        });
                      },
                      onChangeStart: (value) {
                        setState(() {
                          _isSliding = true;
                        });
                      },
                      onChangeEnd: (value) {
                        setState(() {
                          _isSliding = false;
                        });
                      },
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await _submitRating();
                        setState(() {}); // Animasyonun çalışması için setState çağrısı
                      },
                      child: Text('Rate'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

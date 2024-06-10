import 'package:bitirmeson/imagepickpage.dart';
import 'package:bitirmeson/oylama.dart';
import 'package:bitirmeson/profile.dart';
import 'package:flutter/material.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() {
    return _TabsScreenState();
  }
}

class _TabsScreenState extends State<TabsScreen> {
  int _selectedPageIndex = 0;

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    Widget activePage = ImagePickPage();
    var activePageTitle = 'Upload an Image';

    if (_selectedPageIndex == 1) {
      activePage = Oylama();
      activePageTitle = 'Rately';
    }

    if (_selectedPageIndex == 2) {
      activePage = ProfilePage();
      activePageTitle = 'Profile';
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(40), // AppBar'ın yüksekliğini ayarlayın
          child: AppBar(
            centerTitle: true,
            title: Text(
              activePageTitle,
              style: TextStyle(color: Colors.white),
            ),
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black, Colors.black],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
        ),
        body: activePage,
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.shifting,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white,
          onTap: _selectPage,
          currentIndex: _selectedPageIndex,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.upload),
              label: 'Photo Upload',
              backgroundColor: Color.fromARGB(255, 0, 0, 0),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.star_rate),
              label: 'Rating',
              backgroundColor: Color.fromARGB(255, 0, 0, 0),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
              backgroundColor: Color.fromARGB(255, 0, 0, 0),
            ),
          ],
        ),
      ),
    );
  }}

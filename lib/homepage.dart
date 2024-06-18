import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tareeqy_metro/Profile/myProfile_Screen.dart';
import 'package:tareeqy_metro/components/TransportCard.dart';
import 'package:tareeqy_metro/firebasebus/BusScreen.dart';
import 'package:tareeqy_metro/firebasemetro/metroscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tareeqy_metro/Auth/Login.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _username;
  dynamic _wallet;
  int _selectedIndex = 0;

  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF073042),
    ));

    if (mounted) {
      _fetchUserData();
    }
  }

  Future<void> _fetchUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          if (mounted) {
            setState(() {
              _username = userDoc.data()!['userName'];
              _wallet = userDoc.data()!['wallet'];
            });
          }
        } else {
          // Document does not exist
          print('User document does not exist');
        }
      } catch (e) {
        // Error fetching document
        print('Error fetching user document: $e');
      }
    } else {
      // User is not signed in
      print('User is not signed in');
    }
  }

  void _logout() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute(builder: (context) => const Login()),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.logout, color: Color.fromARGB(255, 255, 0, 0)),
              SizedBox(width: 8),
              Text('Logout'),
            ],
          ),
          content: const Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
                _logout(); // Call the logout method
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color.fromARGB(255, 251, 0, 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(
        _selectedIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Set the system UI overlay style here to ensure it is applied whenever the HomePage is rebuilt
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF073042),
    ));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          children: [
            _buildHomePage(),
            const myProfile_Screen(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: const Color(0xFF073042), // Sophisticated navy blue
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withOpacity(0.6),
        selectedFontSize: 12.0,
        unselectedFontSize: 10.0,
        type: BottomNavigationBarType.fixed,
        elevation: 8.0,
        iconSize: 24.0,
        selectedIconTheme: const IconThemeData(size: 28.0),
        unselectedIconTheme: const IconThemeData(size: 22.0),
        selectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildHomePage() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 320,
            child: Stack(
              children: [
                Container(
                  height: 240,
                  padding: const EdgeInsets.all(20.0),
                  decoration: const BoxDecoration(
                    color: Color(0xFF073042), // Sophisticated navy blue
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20.0),
                      bottomRight: Radius.circular(20.0),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Text(
                          'Hello, \n${_username ?? ''}',
                          style: const TextStyle(
                            fontSize: 40,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: IconButton(
                          icon: const Icon(Icons.logout),
                          onPressed: _showLogoutDialog,
                          color: const Color.fromARGB(255, 255, 0, 0),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),
                Positioned(
                  left: 20,
                  right: 20,
                  top: 195,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    height: 100,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Card(
                      elevation: 0,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            const Text('Balance',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontStyle: FontStyle.italic)),
                            Text('\$ ${_wallet ?? ''}',
                                style: const TextStyle(
                                    fontStyle: FontStyle.italic,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20.0),
          const Text(
            'Choose your Transport',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: TransportCard(
              transportType: 'Bus',
              svgAssetPath: "assets/images/bus-side-view-icon.svg",
              SVGColor: Colors.white,
              BGcolor: const Color(0xFFB31312), // Soft amber
              width: 50,
              height: 63,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BusScreen()),
                );
              },
            ),
          ),
          const SizedBox(height: 16.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: TransportCard(
              transportType: 'Metro',
              svgAssetPath: "assets/images/Subway-HomePage.svg",
              SVGColor: Colors.white,
              BGcolor: const Color(0xFF00796B), // Muted teal

              width: 80,
              height: 75,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MetroScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

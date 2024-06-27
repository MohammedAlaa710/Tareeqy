import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tareeqy_metro/Profile/MyProfile.dart';
import 'package:tareeqy_metro/components/LogOutDialog.dart';
import 'package:tareeqy_metro/components/TransportCard.dart';
import 'package:tareeqy_metro/Bus/BusScreen.dart';
import 'package:tareeqy_metro/Bus/busService.dart';
import 'package:tareeqy_metro/Metro/metroService.dart';
import 'package:tareeqy_metro/Metro/MetroScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LogoutDialog logoutDialog = LogoutDialog();

  String? _username;
  dynamic _wallet;
  int _selectedIndex = 0;

  final PageController _pageController = PageController();
  final metroService _metroService = metroService();
  late final BusService _busService = BusService();

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF073042),
    ));

    if (mounted) {
      _fetchUserData();
      _metroService.getStations();
      _loadBusData();
    }
  }

  Future<void> _loadBusData() async {
    await _busService.getStations();
    await _busService.getBuses();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        _firestore
            .collection('users')
            .doc(user.uid)
            .snapshots()
            .listen((userDoc) {
          if (userDoc.exists) {
            if (mounted) {
              setState(() {
                _username = userDoc.data()!['userName'];
                _wallet = userDoc.data()!['wallet'];
              });
            }
          }
        });
      } catch (e) {
        print('Error fetching user document: $e');
      }
    }
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
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF073042),
    ));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF073042),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Color(0xFF073042),
        ),
      ),
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
            const MyProfile(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: const Color(0xFF073042),
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
                    color: Color(0xFF073042),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20.0),
                      bottomRight: Radius.circular(20.0),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, \n${_username ?? ''}',
                        style: const TextStyle(
                          fontSize: 40,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: IconButton(
                          icon: const Icon(Icons.logout),
                          onPressed: () =>
                              logoutDialog.showLogoutDialog(context),
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
              BGcolor: const Color(0xFFB31312),
              width: 50,
              height: 65,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BusScreen()),
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
              BGcolor: const Color(0xFF00796B),
              width: 50,
              height: 65,
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

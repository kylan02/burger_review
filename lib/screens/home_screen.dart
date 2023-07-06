import 'package:burger_review_3/constants.dart';
import 'package:burger_review_3/screens/gmap.dart';
import 'package:burger_review_3/providers/user_provider.dart';
import 'package:burger_review_3/screens/search_page.dart';
import 'package:burger_review_3/screens/social_page.dart';
import 'package:burger_review_3/screens/store.dart';
import 'package:burger_review_3/models/user.dart' as model;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>{


  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  String username = "";
  late model.User user;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //getUsername();
    addData();
  }

  void addData() async {
    UserProvider _userProvider = Provider.of(context, listen: false);
    await _userProvider.refreshUser();
    print("in add data");
    setState(() {
      user = Provider.of<UserProvider>(context, listen: false).getUser!;
      username = user.username;
    });
  }

  Future signOut() async {
    try {
      return await FirebaseAuth.instance.signOut();
    } catch (err) {
      print(err.toString());
      return null;
    }
  }

  final List<Widget> _widgetOptions = <Widget>[
    Gmap(),
    const SocialPage(),
    const Store(),
  ];

  Widget buildDrawer() {
    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            height: 150,
            child: DrawerHeader(
              child: Text(
                username,
                style: const TextStyle(fontSize: 30),
              ),
              decoration: const BoxDecoration(
                color: kPrimaryColor,
              ),
            ),
          ),
          ListTile(
            title: const Text(
              'Sign Out',
              style: TextStyle(color: Colors.black),
            ),
            onTap: () {
              // Update the state of the app
              signOut();
              // Then close the drawer
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text(
              '',
              style: TextStyle(color: Colors.black),
            ),
            onTap: () {
              // Update the state of the app
              // ...
              // Then close the drawer
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    //fetchIndividualBusiness('tm87DWqehpt79ZInFVmv1w');
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: kPrimaryColor,
        title: (() {
          String s = 'Kylan\'s Burger App';
          if (_selectedIndex == 1) {
            s = 'Social';
            //print('in social');
          } else if (_selectedIndex == 2) {
            s = 'IN-N-OUT STORE';
            //print('in store');
          }
          return Text(
            s,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 25, /*fontStyle: FontStyle.italic*/
            ),
          );
        }()),
        leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            }),
        actions: [
          // Navigate to the Search Screen
          IconButton(
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => SearchPage())),
              icon: const Icon(Icons.search)),
        ],
      ),
      drawer: buildDrawer(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: kBackgroundColor,
        //fixedColor: kPrimaryColor,
        currentIndex: _selectedIndex,
        selectedItemColor: kPrimaryColor,
        unselectedItemColor: Colors.grey,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera),
            label: 'Watch',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Store',
          ),
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      body: _widgetOptions.elementAt(
          _selectedIndex), // This trailing comma makes auto-formatting nicer for build methods.
      // body: IndexedStack(
      //   children: <Widget>[
      //     Gmap(),
      //     const SocialPage(),
      //     const Store(),
      //   ],
      //   index: _selectedIndex,
      // ),
    );
  }
}

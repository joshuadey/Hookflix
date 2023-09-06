import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_app/admin/adminhome.dart';
import 'package:my_app/admin/movielist.dart';
import 'package:my_app/appdata.dart';
import 'package:my_app/widgets/avatardialog.dart';
import 'package:my_app/globalvariables.dart';
import 'package:my_app/pages/home.dart';
import 'package:iconly/iconly.dart';
import 'package:my_app/pages/movies.dart';
import 'package:my_app/pages/mylist.dart';
import 'package:my_app/pages/searchpage.dart';
import 'package:provider/provider.dart';
import 'package:wakelock/wakelock.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedTab = 0;
  List<Widget> _pages = [
    HomePage(),
    Movies(),
    MyList(),
  ];

  void _changeTab(int index) {
    setState(() {
      _selectedTab = index;
    });
  }

  Color dim_text = Color.fromARGB(255, 189, 189, 189);

  @override
  void initState() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    Wakelock.disable();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int home_color1 = Provider.of<AppData>(context).home_color_1;
    
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: (_selectedTab == 0)
            ? Color(home_color1)
            : Colors.black,
        title: GestureDetector(
          onLongPress: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => AdminHome()));
          },
          child: Text(
            'For ${user_name}',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
        ),
        elevation: 0,
        actions: [
          // search
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SearchPage(page: _selectedTab)));
              },
              child: Icon(
                Icons.search_rounded,
                size: 30,
              ),
            ),
          ),

          // avatar
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: GestureDetector(
              onTap: () async {
                await showDialog(
                    context: context, builder: (context) => AvatarDialog());

                setState(() {});
              },
              child: Container(
                width: 30,
                height: 20,
                child: Image.asset(
                    selectedImage,
                    width: 30,
                    height: 20,
                  ),
              ),
            ),
          ),
        ],
      ),
      body: _pages[_selectedTab],
      bottomNavigationBar: BottomNavigationBar(
        // elevation: 8.0,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Color(home_color1).withOpacity(0.5),
        currentIndex: _selectedTab,
        onTap: (index) => _changeTab(index),
        selectedItemColor: Colors.white,
        unselectedItemColor: dim_text,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(icon: Icon(IconlyBold.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.new_releases_outlined),
              activeIcon: Icon(Icons.new_releases_rounded),
              label: 'New & Hot'),
          BottomNavigationBarItem(
              icon: Icon(Icons.movie_rounded), label: 'My List'),
        ],
      ),
    );
  }
}

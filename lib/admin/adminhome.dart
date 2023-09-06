import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_app/admin/manage_banner_colors.dart';
import 'package:my_app/admin/manage_home_colors.dart';
import 'package:my_app/admin/movielist.dart';
import 'package:my_app/mainpage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: kIsWeb ? Container() : IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
        title: Text('Admin Home'),
        centerTitle: true,
      ),
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: [
          // manage movies
          Padding(
            padding: EdgeInsets.all(10),
            child: ListTile(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => MovieList()));
              },
              leading: Icon(
                Icons.movie_edit,
                color: Colors.white,
              ),
              title: Text(
                'Manage movies',
                style: TextStyle(color: Colors.white),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: Colors.white60,
              ),
            ),
          ),

          // colors
          Padding(
            padding: EdgeInsets.all(10),
            child: ListTile(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ManageHomeColors()));
              },
              leading: Icon(
                Icons.color_lens_rounded,
                color: Colors.white,
              ),
              title: Text(
                'Manage Home page colors',
                style: TextStyle(color: Colors.white),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: Colors.white60,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: ListTile(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ManageBannerColors()));
              },
              leading: Icon(
                Icons.color_lens_rounded,
                color: Colors.white,
              ),
              title: Text(
                'Manage Banner box colors',
                style: TextStyle(color: Colors.white),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: Colors.white60,
              ),
            ),
          ),

          SizedBox(height: 30),

          // reload app
          kIsWeb ? Container() : Padding(
            padding: EdgeInsets.all(10),
            child: ListTile(
              onTap: () {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => MainPage()),
                    (route) => false);
              },
              leading: Icon(
                Icons.refresh,
                color: Colors.white,
              ),
              title: Text(
                'Reload App',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

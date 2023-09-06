import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:my_app/widgets/confrim_action_dialog.dart';
import 'package:my_app/widgets/loadingScreen.dart';

class ManageBannerColors extends StatefulWidget {
  const ManageBannerColors({super.key});

  @override
  State<ManageBannerColors> createState() => _ManageBannerColorsState();
}

class _ManageBannerColorsState extends State<ManageBannerColors> {
  TextEditingController banner_cl_1 = TextEditingController();
  TextEditingController banner_cl_2 = TextEditingController();
  TextEditingController banner_cl_3 = TextEditingController();
  TextEditingController banner_cl_4 = TextEditingController();
  TextEditingController banner_cl_5 = TextEditingController();

  String banner_color_1 = '';
  String banner_color_2 = '';
  String banner_color_3 = '';
  String banner_color_4 = '';
  String banner_color_5 = '';

  int banner_col_1 = 0;
  int banner_col_2 = 0;
  int banner_col_3 = 0;
  int banner_col_4 = 0;
  int banner_col_5 = 0;

  setControllers() async {
    DataSnapshot snap = await FirebaseDatabase.instance
        .ref()
        .child('Admin/Colors/banner_colors')
        .get();

    if (snap.value != null) {
      Map val = snap.value as Map;

      banner_cl_1.text = "${val['banner_color1']}";
      banner_cl_2.text = "${val['banner_color2']}";
      banner_cl_3.text = "${val['banner_color3']}";
      banner_cl_4.text = "${val['banner_color4']}";
      banner_cl_5.text = "${val['banner_color5']}";
    } else {
    }

    setState(() {});
  }

  commitBanner() {
    setState(() {
      banner_col_1 = int.tryParse('0x1A$banner_color_1')!;
      banner_col_2 = int.tryParse('0x33$banner_color_2')!;
      banner_col_3 = int.tryParse('0x40$banner_color_3')!;
      banner_col_4 = int.tryParse('0x8C$banner_color_4')!;
      banner_col_5 = int.tryParse('0x8C$banner_color_5')!;
    });
  }

  setBanner() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => LoadingScreen());

    Map home_cl = {
      'banner_color1': banner_color_1,
      'banner_color2': banner_color_2,
      'banner_color3': banner_color_3,
      'banner_color4': banner_color_4,
      'banner_color5': banner_color_5,
    };

    await FirebaseDatabase.instance
        .ref()
        .child('Admin/Colors/banner_colors')
        .set(home_cl);

    Navigator.pop(context);
    Navigator.pop(context);
  }

  @override
  void initState() {
    setControllers();
    super.initState();
  }

  @override
  void dispose() {
    banner_cl_1.dispose();
    banner_cl_2.dispose();
    banner_cl_3.dispose();
    banner_cl_4.dispose();
    banner_cl_5.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    banner_color_1 = banner_cl_1.text.trim();
    banner_color_2 = banner_cl_2.text.trim();
    banner_color_3 = banner_cl_3.text.trim();
    banner_color_4 = banner_cl_4.text.trim();
    banner_color_5 = banner_cl_5.text.trim();

    banner_col_1 = int.tryParse('0x1A$banner_color_1') ?? 0xFFffffff;
    banner_col_2 = int.tryParse('0x33$banner_color_2') ?? 0xFFffffff;
    banner_col_3 = int.tryParse('0x40$banner_color_3') ?? 0xFFffffff;
    banner_col_4 = int.tryParse('0x8C$banner_color_4') ?? 0xFFffffff;
    banner_col_5 = int.tryParse('0x8C$banner_color_5') ?? 0xFFffffff;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
        title: Text('Manage Banner box Colors'),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: GestureDetector(
              onTap: () async {
                final confirmed = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return ConfirmActionDialog(
                      title: 'Reset colors',
                      subtitle:
                          'Would you like to reset your current color setting to the last saved, this cannot be undone!',
                    );
                  },
                );

                if (confirmed) {
                  setControllers();
                } else {
                  // Action cancelled
                }
              },
              child: Icon(
                Icons.restore,
                size: 25,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // home color 1
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                      child: TextField(
                    controller: banner_cl_1,
                    onChanged: (value) {
                      setState(() {});
                    },
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: '######',
                      hintStyle: TextStyle(color: Colors.white),
                      prefix: Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: Text(
                          '0x1A',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  )),
                  SizedBox(width: 10),
                  Container(
                    height: 60,
                    width: 60,
                    color: Color(banner_col_1),
                  ),
                ],
              ),
            ),

            // home color 2
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                      child: TextField(
                    controller: banner_cl_2,
                    onChanged: (value) {
                      setState(() {});
                    },
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: '######',
                      hintStyle: TextStyle(color: Colors.white),
                      prefix: Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: Text(
                          '0x33',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  )),
                  SizedBox(width: 10),
                  Container(
                    height: 60,
                    width: 60,
                    color: Color(banner_col_2),
                  ),
                ],
              ),
            ),

            // home color 3
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                      child: TextField(
                    controller: banner_cl_3,
                    onChanged: (value) {
                      setState(() {});
                    },
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: '######',
                      hintStyle: TextStyle(color: Colors.white),
                      prefix: Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: Text(
                          '0x40',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  )),
                  SizedBox(width: 10),
                  Container(
                    height: 60,
                    width: 60,
                    color: Color(banner_col_3),
                  ),
                ],
              ),
            ),

            // home color 4
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                      child: TextField(
                    controller: banner_cl_4,
                    onChanged: (value) {
                      setState(() {});
                    },
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: '######',
                      hintStyle: TextStyle(color: Colors.white),
                      prefix: Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: Text(
                          '0x8C',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  )),
                  SizedBox(width: 10),
                  Container(
                    height: 60,
                    width: 60,
                    color: Color(banner_col_4),
                  ),
                ],
              ),
            ),

            // home color 5
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                      child: TextField(
                    controller: banner_cl_5,
                    onChanged: (value) {
                      setState(() {});
                    },
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: '######',
                      hintStyle: TextStyle(color: Colors.white),
                      prefix: Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: Text(
                          '0x8C',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  )),
                  SizedBox(width: 10),
                  Container(
                    height: 60,
                    width: 60,
                    color: Color(banner_col_5),
                  ),
                ],
              ),
            ),

            // commit home color
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: InkWell(
                onTap: () {
                  commitBanner();
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.arrow_downward_rounded,
                          size: 25,
                          color: Colors.white70,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Preview',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // preview box
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.0, 0.1, 0.3, 0.7, 1.0],
                    colors: [
                      Color(banner_col_1),
                      Color(banner_col_2),
                      Color(banner_col_3),
                      Color(banner_col_4),
                      Color(banner_col_5),
                    ],
                  ),
                ),
                width: double.infinity,
                height: 300,
              ),
            ),

            // save
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: InkWell(
                onTap: () async {
                  final confirmed = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return ConfirmActionDialog(
                        title: 'Save Colors',
                        subtitle:
                            'Would you like to save the current color setting to the database?',
                      );
                    },
                  );

                  if (confirmed) {
                    setBanner();
                  } else {
                    // Action cancelled
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.save_rounded,
                          size: 25,
                          color: Colors.white70,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Commit & Save',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 30),
          ],
        ),
      )),
    );
  }
}

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_app/admin/adminhome.dart';
import 'package:my_app/appdata.dart';
import 'package:my_app/globalvariables.dart';
import 'package:my_app/mainpage.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Hive.initFlutter();

  await Hive.openBox('lastDuration');
  await Hive.openBox('myList');
  await Hive.openBox('myProfile');

  Map prof = Hive.box('myProfile').get('profile') ??
      {'name': 'Hookfilx', 'image': 'images/dog.png'};
  user_name = prof['name'];
  selectedImage = prof['image'];

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppData(),
      child: MaterialApp(
        title: 'Hookflix',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
        ),
        home: kIsWeb ? AdminHome() : MainPage(),
      ),
    );
  }

  final MaterialColor primaryBlack = MaterialColor(
    0xFF000000,
    <int, Color>{
      50: Color(0xFF000000),
      100: Color(0xFF000000),
      200: Color(0xFF000000),
      300: Color(0xFF000000),
      400: Color(0xFF000000),
      500: Color(0xFF000000),
      600: Color(0xFF000000),
      700: Color(0xFF000000),
      800: Color(0xFF000000),
      900: Color(0xFF000000),
    },
  );
}

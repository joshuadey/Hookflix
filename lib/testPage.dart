import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  load() async {
    var box = Hive.box('lastDuration');
    

    Map? movie_dt = box.get('-6326teyweytwe');

    if (movie_dt != null) {
      Duration last = parseTime(movie_dt['lastDuration']) ?? Duration();

      if (last > Duration(minutes: 3)) {
        print('seek');
      }
    }

    if (movie_dt != null) {
      print('vloume');
    } else {
      print('0.5');
    }
  }

  // subtitle 
  // https://b.yaradua.h.sabishare.com/dl/XegUFzELM91/7e9c3936beac9fd4e15b366b7794a3e357dc70a8b17104084738cba58609f3bd/Back_Roads_(2018)_(NetNaija.com).srt

  // vid
  // https://awolowo.000c.h.sabishare.com/dl/ozboOLAsF85/aa6702c038a677504c5c27856bec3aea3f915292101ecf387a9932783117e310/Back_Roads_(2018)_(NetNaija.com).mp4

  // error
  // https://h.azikiwe.h.sabishare.com/dl/sdaKhpgCa13/9929f2e1ff33df6405dee4a4b115796e3016585f8174b562654e28139f5bc971/Almost_Paradise_S02E10_-_Brigade_(NetNaija.com).mkv

  // https://f.mandela.h.sabishare.com/dl/WsqnfbYMV93/25d78afbc711eb4ecab21f1bbf1623045ccc356331ec5848a70f79692379c524/Almost_Paradise_S02E10_-_Brigade_(NetNaija.com).srt

  putB() async {
    var box = Hive.box('lastDuration');

    Map movie_data = {
      'lastDuration':
          Duration(microseconds: 200, hours: 10, minutes: 4).toString(),
      'volume': 0.5,
    };

    box.put('-6326teyweytwe', movie_data);
  }

  Duration? parseTime(String input) {
    final parts = input.split(':');

    if (parts.length != 3) return null;

    int days;
    int hours;
    int minutes;
    int seconds;
    int milliseconds;
    int microseconds;

    {
      final p = parts[2].split('.');

      if (p.length != 2) return null;

      // If fractional seconds is passed, but less than 6 digits
      // Pad out to the right so we can calculate the ms/us correctly
      final p2 = int.parse(p[1].padRight(6, '0'));
      microseconds = p2 % 1000;
      milliseconds = p2 ~/ 1000;

      seconds = int.parse(p[0]);
    }

    minutes = int.parse(parts[1]);

    {
      int p = int.parse(parts[0]);
      hours = p % 24;
      days = p ~/ 24;
    }

    // TODO verify that there are no negative parts

    return Duration(
        days: days,
        hours: hours,
        minutes: minutes,
        seconds: seconds,
        milliseconds: milliseconds,
        microseconds: microseconds);
  }

  @override
  void initState() {
    load();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          IconButton(
              onPressed: () {
                putB();
              },
              icon: Icon(Icons.add))
        ],
      ),
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_app/appdata.dart';
import 'package:my_app/datamodel/movielistmodel.dart';
import 'package:my_app/globalvariables.dart';
import 'package:my_app/moviedetail.dart';
import 'package:my_app/movieplayer.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DatabaseReference _firebaseRef =
      FirebaseDatabase.instance.ref().child('Movies');

  List<MovieListModel> _latest_movies = [];
  List<MovieListModel> _popular_movies = [];
  List<MovieListModel> _trending_movies = [];
  List<MovieListModel> _already_watching = [];

  getHomeColors() async {
    DataSnapshot snap = await FirebaseDatabase.instance
        .ref()
        .child('Admin/Colors/home_colors')
        .get();

    if (snap.value != null) {
      Map val = snap.value as Map;

      String home_cl_1 = "${val['home_color1']}";
      String home_cl_2 = "${val['home_color2']}";
      String home_cl_3 = "${val['home_color3']}";
      String home_cl_4 = "${val['home_color4']}";
      String home_cl_5 = "${val['home_color5']}";

      home_color1 = int.tryParse('0xFF$home_cl_1') ?? 0xFFffffff;
      home_color2 = int.tryParse('0xFF$home_cl_2') ?? 0xFFffffff;
      home_color3 = int.tryParse('0xFF$home_cl_3') ?? 0xFFffffff;
      home_color4 = int.tryParse('0xFF$home_cl_4') ?? 0xFFffffff;
      home_color5 = int.tryParse('0xFF$home_cl_5') ?? 0xFFffffff;

      Provider.of<AppData>(context, listen: false)
          .update_home_color_1(home_color1);
    } else {}
  }

  getBannerColors() async {
    DataSnapshot snap = await FirebaseDatabase.instance
        .ref()
        .child('Admin/Colors/banner_colors')
        .get();

    if (snap.value != null) {
      Map val = snap.value as Map;

      String banner_cl_1 = "${val['banner_color1']}";
      String banner_cl_2 = "${val['banner_color2']}";
      String banner_cl_3 = "${val['banner_color3']}";
      String banner_cl_4 = "${val['banner_color4']}";
      String banner_cl_5 = "${val['banner_color5']}";

      banner_color1 = int.tryParse('0x1A$banner_cl_1') ?? 0xFFffffff;
      banner_color2 = int.tryParse('0x33$banner_cl_2') ?? 0xFFffffff;
      banner_color3 = int.tryParse('0x40$banner_cl_3') ?? 0xFFffffff;
      banner_color4 = int.tryParse('0x8C$banner_cl_4') ?? 0xFFffffff;
      banner_color5 = int.tryParse('0x8C$banner_cl_5') ?? 0xFFffffff;

      setState(() {});
    } else {}
  }

  @override
  void initState() {
    getHomeColors();
    getBannerColors();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      height: double.infinity,
      child: StreamBuilder(
        stream: _firebaseRef.onValue,
        builder: (context, snapshot) {
          if (!snapshot.hasData ||
              snapshot.hasError ||
              snapshot.data!.snapshot.value == null) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          Map value = snapshot.data!.snapshot.value as Map;

          _trending_movies.clear();
          _popular_movies.clear();
          _latest_movies.clear();
          _already_watching.clear();

          MovieListModel? bannerMovie;

          value.forEach((key, value) {
            MovieListModel newMovie = MovieListModel(
              id: key,
              title: value['movie_title'] ?? '',
              thumbnail: value['movie_thumbnail'] ?? '',
              category: value['category'] ?? '',
              genre_list: value['movie_genres'].toString().split(','),
              movie_url: value['movie_url'] ?? '',
              subtitle: value['subtitle'] ?? '',
            );

            bool isAvailable = value['isAvailable'] ?? false;
            if (!isAvailable) return;

            bool isBanner = value['isBanner'] ?? false;
            if (isBanner) bannerMovie = newMovie;

            if (newMovie.category.contains('Latest'))
              _latest_movies.add(newMovie);

            if (newMovie.category.contains('Popular'))
              _popular_movies.add(newMovie);

            if (newMovie.category.contains('Trending'))
              _trending_movies.add(newMovie);

            // check if already watching
            var box = Hive.box('lastDuration');
            bool started = box.containsKey(newMovie.id);
            if (started) _already_watching.add(newMovie);
          });

          return SingleChildScrollView(
            child: Stack(
              children: [
                // paint box
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.0, 0.1, 0.3, 0.5, 0.7, 1.0],
                      colors: [
                        Color(home_color1),
                        Color(home_color2),
                        Color(home_color3),
                        Color(home_color4),
                        Color(home_color5),
                        Colors.black,
                      ],
                    ),
                  ),
                ),

                // main page
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // banner
                    bannerMovie != null ? _banner(bannerMovie!) : Container(),

                    // continue
                    _already_watching.isNotEmpty
                        ? _continue(_already_watching)
                        : Container(),

                    // popular
                    _popular_movies.isNotEmpty
                        ? _category('Popular on Hookflix', _popular_movies)
                        : Container(),

                    // trending
                    _trending_movies.isNotEmpty
                        ? _category('Trending Now', _trending_movies)
                        : Container(),

                    // latest
                    _latest_movies.isNotEmpty
                        ? _category('New Releases', _latest_movies)
                        : Container(),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // widgets
  // main banner
  Widget _banner(MovieListModel movie) {
    double height = MediaQuery.of(context).size.height / 1.5;

    List<String> list = movie.genre_list.length > 4
        ? movie.genre_list.sublist(0, 4)
        : movie.genre_list;

    TextStyle a_TextStyle = TextStyle(
      fontSize: 40,
      // fontWeight: FontWeight.bold,
      fontFamily: 'UnicaOne',
      color: Colors.white,
      shadows: [
        Shadow(
          blurRadius: 5,
          color: Colors.black,
          offset: Offset(2, 2),
        ),
      ],
    );

    TextStyle b_TextStyle = TextStyle(
      fontSize: 30,
      // fontWeight: FontWeight.bold,
      fontFamily: 'BadScript',
      color: Colors.white,
      shadows: [
        Shadow(
          blurRadius: 5,
          color: Colors.black,
          offset: Offset(2, 2),
        ),
      ],
    );

    TextStyle c_TextStyle = TextStyle(
      fontSize: 30,
      // fontWeight: FontWeight.bold,
      fontFamily: 'UnicaOne',
      color: Colors.white,
      shadows: [
        Shadow(
          blurRadius: 5,
          color: Colors.black,
          offset: Offset(2, 2),
        ),
      ],
    );

    var boxL = Hive.box('myList');

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: GestureDetector(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MovieDetail(id: movie.id),
            ),
          );

          setState(() {});
        },
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  offset: Offset(0.7, 0.7),
                  spreadRadius: 0.7,
                  blurRadius: 5,
                  color: Colors.white24,
                )
              ]),
          width: double.infinity,
          height: height,
          child: Stack(
            children: [
              // image
              Container(
                width: double.infinity,
                height: height,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CachedNetworkImage(
                    imageUrl: movie.thumbnail,
                    placeholder: (context, url) =>
                        Image.asset('images/placeholder.png'),
                    errorWidget: (context, url, error) =>
                        Image.asset('images/placeholder.png'),
                    fit: BoxFit.cover,
                    // Adjust the image loading duration (optional)
                    fadeInDuration: Duration(milliseconds: 500),
                    fadeOutDuration: Duration(milliseconds: 1000),
                  ),
                ),
              ),

              // color box
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  width: double.infinity,
                  height: 230,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.0, 0.1, 0.3, 0.5, 0.7, 1.0],
                      colors: [
                        Colors.transparent,
                        Color(banner_color1),
                        Color(banner_color2),
                        Color(banner_color3),
                        Color(banner_color4),
                        Color(banner_color5),
                      ],
                    ),
                  ),
                ),
              ),

              // movie details
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.all(12),
                  color: Colors.transparent,
                  child: Column(
                    children: [
                      // title
                      Text(
                        movie.title.split(' ').first,
                        style: a_TextStyle,
                      ),
                      movie.title.split(' ').length > 1
                          ? Text(
                              movie.title.split(' ')[1],
                              style: b_TextStyle,
                            )
                          : Container(),
                      movie.title.split(' ').length > 2
                          ? Text(
                              movie.title.split(' ').sublist(2).join(' '),
                              style: c_TextStyle,
                            )
                          : Container(),

                      SizedBox(height: 15),

                      // genres
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: list
                            .map(
                              (e) => (e == list.last)
                                  ? Text(e.trim(),
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 14))
                                  : Row(
                                      children: [
                                        Text(e.trim(),
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12)),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 4),
                                          child: Icon(
                                            Icons.circle,
                                            size: 6,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                            )
                            .toList(),
                      ),

                      SizedBox(height: 15),

                      // action button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // play button
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MoviePlayer(
                                      movieTitle: movie.title,
                                      movieUrl: movie.movie_url,
                                      movie_id: movie.id,
                                      subtitle: movie.subtitle,
                                      preview: false,
                                    ),
                                  ),
                                );

                                setState(() {});
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  color: Colors.white,
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 8),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.play_arrow,
                                        size: 30,
                                        color: Colors.black,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        'Play',
                                        style: TextStyle(
                                          color: Colors.black,
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

                          SizedBox(width: 12),

                          // my list
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                if (boxL.containsKey(movie.id)) {
                                  boxL.delete(movie.id);
                                } else {
                                  String now = DateTime.now().toString();
                                  boxL.put(movie.id, now);
                                }

                                setState(() {});
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  color: Colors.black26,
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 8),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        boxL.containsKey(movie.id)
                                            ? Icons.remove
                                            : Icons.add,
                                        size: 30,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        'My List',
                                        style: TextStyle(
                                          color: Colors.white,
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
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // continue watching
  Widget _continue(List<MovieListModel> movie_list) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category title
          Text(
            'Continue Watching for ${user_name}',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
          ),

          SizedBox(height: 10),

          Container(
            height: 200,
            width: double.infinity,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: BouncingScrollPhysics(),
              itemCount: movie_list.length,
              itemBuilder: (context, index) =>
                  _continue_movieTile(movie_list[index]),
            ),
          ),
        ],
      ),
    );
  }

  // category
  Widget _category(String title, List<MovieListModel> movie_list) {
    // movie_list.shuffle();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category title
          Text(
            title,
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
          ),

          SizedBox(height: 10),

          Container(
            height: 160,
            width: double.infinity,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: BouncingScrollPhysics(),
              itemCount: movie_list.length,
              itemBuilder: (context, index) => _movieTile(movie_list[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _movieTile(MovieListModel movie) {
    return Container(
      padding: EdgeInsets.only(right: 15),
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MovieDetail(id: movie.id),
            ),
          );

          setState(() {});
        },
        child: Stack(
          children: [
            // thumbnail
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              width: 120,
              height: 160,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: movie.thumbnail,
                  placeholder: (context, url) =>
                      Image.asset('images/placeholder.png'),
                  errorWidget: (context, url, error) =>
                      Image.asset('images/placeholder.png'),
                  fit: BoxFit.cover,
                  // Adjust the image loading duration (optional)
                  fadeInDuration: Duration(milliseconds: 500),
                  fadeOutDuration: Duration(milliseconds: 1000),
                ),
              ),
            ),

            // logo
            Positioned(
              top: 0,
              left: 0,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Image.asset(
                  'images/logo.png',
                  width: 16,
                  height: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _continue_movieTile(MovieListModel movie) {
    return Container(
      padding: EdgeInsets.only(right: 15),
      child: Column(
        children: [
          Stack(
            children: [
              // thumbnail
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                width: 120,
                height: 160,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: movie.thumbnail,
                    placeholder: (context, url) =>
                        Image.asset('images/placeholder.png'),
                    errorWidget: (context, url, error) =>
                        Image.asset('images/placeholder.png'),
                    fit: BoxFit.cover,
                    // Adjust the image loading duration (optional)
                    fadeInDuration: Duration(milliseconds: 500),
                    fadeOutDuration: Duration(milliseconds: 1000),
                  ),
                ),
              ),

              // play button
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                    color: Colors.white12,
                  ),
                  child: Center(
                    child: InkWell(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MoviePlayer(
                              movieTitle: movie.title,
                              movieUrl: movie.movie_url,
                              movie_id: movie.id,
                              subtitle: movie.subtitle,
                              preview: false,
                            ),
                          ),
                        );

                        setState(() {});
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black54,
                          border: Border.all(color: Colors.white70, width: 3),
                        ),
                        padding: EdgeInsets.all(8),
                        child: Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // bottom bar
          Container(
            width: 120,
            height: 40,
            decoration: BoxDecoration(
              color: Color.fromARGB(136, 71, 71, 71),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MovieDetail(id: movie.id),
                      ),
                    );

                    setState(() {});
                  },
                  child: Icon(
                    Icons.info_outline_rounded,
                    color: Colors.white,
                    size: 25,
                  ),
                ),
                _build_continueTile_menu(movie.id),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _build_continueTile_menu(String id) {
    var box = Hive.box('myList');

    return Container(
      child: PopupMenuButton<int>(
        offset: Offset(20, 0),
        color: Colors.black87,
        enabled: true,
        tooltip: 'Menu',
        onSelected: (value) {
          if (value == 1) {
            if (box.containsKey(id)) {
              box.delete(id);
            } else {
              String now = DateTime.now().toString();
              box.put(id, now);
            }
          } else {
            var box2 = Hive.box('lastDuration');
            box2.delete(id);
          }

          setState(() {});
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            value: 1,
            child: Row(
              children: [
                Icon(
                  box.containsKey(id) ? Icons.remove : Icons.add,
                  color: Colors.white,
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  'My List',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuItem(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            value: 0,
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.white,
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  'Complete',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
        child: Icon(
          Icons.more_vert_rounded,
          color: Colors.white,
          size: 25,
        ),
      ),
    );
  }

  //
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_app/datamodel/movielistmodel.dart';
import 'package:my_app/moviedetail.dart';
import 'package:my_app/movieplayer.dart';

class MyList extends StatefulWidget {
  const MyList({super.key});

  @override
  State<MyList> createState() => _MyListState();
}

class _MyListState extends State<MyList> {
  DatabaseReference _firebaseRef =
      FirebaseDatabase.instance.ref().child('Movies');

  List<Map> allkeys = [];
  List<MovieListModel> movies = [];

  load_list() {
    var box = Hive.box('myList');
    var all_keys = box.keys;

    allkeys.clear();

    all_keys.forEach((key) {
      String val = box.get(key);
      Map newIt = {
        'key': key,
        'value': val,
      };

      allkeys.add(newIt);
    });

    allkeys.sort((a, b) =>
        DateTime.parse(b['value']).compareTo(DateTime.parse(a['value'])));

    movies.clear();

    all_keys.forEach((key) async {
      DataSnapshot snap = await _firebaseRef.child(key).get();

      Map value = snap.value as Map;

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

      setState(() {
        movies.add(newMovie);
      });
    });

    setState(() {});
  }

  @override
  void initState() {
    load_list();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      height: double.infinity,
      child: movies.isEmpty
          ? Center(
              child: Text(
                'No movie in your list',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            )
          : ListView.builder(
              physics: BouncingScrollPhysics(),
              itemCount: movies.length,
              itemBuilder: (context, index) => _movieTile(movies[index]),
            ),
    );
  }

  Widget _movieTile(MovieListModel movie) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          // thumbnail
          InkWell(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MovieDetail(id: movie.id),
                ),
              );

              load_list();
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              width: 130,
              height: 70,
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
          ),

          SizedBox(width: 12),

          // title
          Expanded(
            child: Text(
              movie.title,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
                backgroundColor: Colors.black38,
              ),
            ),
          ),

          SizedBox(width: 10),

          InkWell(
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
                border: Border.all(color: Colors.white70, width: 2),
              ),
              padding: EdgeInsets.all(6),
              child: Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 25,
              ),
            ),
          ),
        ],
      ),
    );
  }

  //
}

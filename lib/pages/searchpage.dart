import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_app/datamodel/movielistmodel.dart';
import 'package:my_app/globalvariables.dart';
import 'package:my_app/moviedetail.dart';
import 'package:my_app/movieplayer.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key, required this.page});

  final int page;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchNode = FocusNode();

  DatabaseReference _databaseRef =
      FirebaseDatabase.instance.ref().child('Movies');

  List<MovieListModel> movies = [];

  bool search_on = false;

  Future<void> checkStringExist(String searchString) async {
    if (searchString.isEmpty) {
      movies.clear();
      setState(() {
        search_on = false;
      });
      return;
    }

    final dataSnapshot = await _databaseRef.get();

    Map value = dataSnapshot.value as Map;

    movies.clear();
    search_on = true;

    var box = Hive.box('myList');
    var all_keys = box.keys;

    // Loop through each record in the database
    value.forEach((key, value) {
      // Check if the value contains the given search string
      if (value['movie_title']
          .toString()
          .toLowerCase()
          .contains(searchString.toLowerCase())) {
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

        if (widget.page == 2 && !all_keys.contains(key)) return;

        setState(() {
          movies.add(newMovie);
        });
      }
    });

    print('Search completed');
  }

  @override
  void initState() {
    Future.delayed(Duration(milliseconds: 400), () {
      FocusScope.of(context).requestFocus(searchNode);
    });
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
        title: TextField(
          controller: searchController,
          focusNode: searchNode,
          onChanged: checkStringExist,
          style: TextStyle(
            color: Colors.white70,
          ),
          decoration: InputDecoration(
            hintText: "Search games, shows, movies...",
            hintStyle: TextStyle(
                color: Colors.white38, overflow: TextOverflow.ellipsis),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 5),
            filled: true,
            fillColor: Color.fromARGB(255, 84, 84, 84),
            prefixIcon: Padding(
              padding: EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () {
                  if (searchController.text.isNotEmpty) {
                    searchController.clear();

                    setState(() {
                      search_on = false;
                      movies.clear();
                    });
                  }
                },
                child: Icon(
                  searchController.text.isEmpty ? Icons.search : Icons.clear,
                  color: Colors.white38,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Container(
        color: Colors.black,
        height: double.infinity,
        child: movies.isNotEmpty
            // main search
            ? ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: movies.length,
                itemBuilder: (context, index) => _movieTile(movies[index]),
              )
            : recent_movies.isNotEmpty && !search_on && widget.page != 2
                // recent search
                ? ListView.builder(
                    physics: BouncingScrollPhysics(),
                    itemCount: recent_movies.length,
                    itemBuilder: (context, index) =>
                        _movieTile(recent_movies[index]),
                  )
                // empty search
                : Center(
                    child: Text(
                      'No movie found',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
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
              if (!recent_movies.contains(movie)) recent_movies.add(movie);

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
                borderRadius: BorderRadius.circular(8),
              ),
              width: 130,
              height: 70,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
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

          SizedBox(width: 10),

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

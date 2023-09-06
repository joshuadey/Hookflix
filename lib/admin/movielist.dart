import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:my_app/admin/uploadmovie.dart';
import 'package:my_app/datamodel/movielistmodel.dart';
import 'package:my_app/moviedetail.dart';

class MovieList extends StatefulWidget {
  const MovieList({super.key});

  @override
  State<MovieList> createState() => _MovieListState();
}

class _MovieListState extends State<MovieList> {
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchNode = FocusNode();

  DatabaseReference _firebaseRef =
      FirebaseDatabase.instance.ref().child('Movies');

  List<MovieListModel> movie_list = [];
  List<MovieListModel> search_list = [];

  bool search_on = false;

  Future<void> checkStringExist(String searchString) async {
    if (searchString.isEmpty) {
      search_list.clear();
      setState(() {});
      return;
    }

    final dataSnapshot = await _firebaseRef.get();

    Map value = dataSnapshot.value as Map;

    search_list.clear();

    // Loop through each record in the database
    value.forEach((key, value) {
      // Check if the value contains the given search string
      if (value['movie_title']
          .toString()
          .toLowerCase()
          .contains(searchString.toLowerCase())) {
        print('String found in $key');

        MovieListModel newMovie = MovieListModel(
          id: key,
          title: value['movie_title'] ?? '',
          thumbnail: value['movie_thumbnail'] ?? '',
          category: value['category'] ?? '',
          genre_list: value['movie_genres'].toString().split(','),
          movie_url: value['movie_url'] ?? '',
          subtitle: value['subtitle'] ?? '',
        );

        setState(() {
          search_list.add(newMovie);
        });
      }
    });

    setState(() {});

    print('Search completed');
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
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            if (search_on) {
              setState(() {
                search_on = false;
              });
            } else {
              Navigator.pop(context);
            }
          },
          icon: Icon(
            search_on ? Icons.clear : Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
        title: !search_on
            ? Text('All Movies')
            : TextField(
                focusNode: searchNode,
                controller: searchController,
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
                            search_list.clear();
                          });
                        }
                      },
                      child: Icon(
                        searchController.text.isEmpty
                            ? Icons.search
                            : Icons.clear,
                        color: Colors.white38,
                      ),
                    ),
                  ),
                ),
              ),
        actions: search_on
            ? []
            : [
                // search
                Padding(
                  padding: EdgeInsets.only(right: 20),
                  child: GestureDetector(
                    onTap: () {
                      //
                      setState(() {
                        search_on = true;
                      });
                      Future.delayed(Duration(milliseconds: 400), () {
                        FocusScope.of(context).requestFocus(searchNode);
                      });
                    },
                    child: Icon(
                      Icons.search_rounded,
                      size: 25,
                    ),
                  ),
                ),
              ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
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

                movie_list.clear();

                Map value = snapshot.data!.snapshot.value as Map;

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

                  movie_list.add(newMovie);
                });

                return search_on && search_list.isEmpty
                    ? Container()
                    : search_on
                        ? ListView.builder(
                            physics: BouncingScrollPhysics(),
                            itemCount: search_list.length,
                            itemBuilder: (context, index) =>
                                _movieTile(search_list[index]),
                          )
                        : movie_list.isEmpty
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
                                itemCount: movie_list.length,
                                itemBuilder: (context, index) =>
                                    _movieTile(movie_list[index]),
                              );
              },
            ),
          ),

          // add new movie button
          Padding(
            padding: EdgeInsets.all(12),
            child: InkWell(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        UploadMovie(editMode: false, mov_id: ''),
                  ),
                );

                setState(() {});
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
                        Icons.add,
                        size: 25,
                        color: Colors.white70,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Add New Movie',
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
        ],
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

              setState(() {});
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
                  builder: (context) =>
                      UploadMovie(editMode: true, mov_id: movie.id),
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
                Icons.edit,
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

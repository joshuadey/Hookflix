import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:my_app/datamodel/movielistmodel.dart';
import 'package:my_app/moviedetail.dart';

class Movies extends StatefulWidget {
  const Movies({super.key});

  @override
  State<Movies> createState() => _MoviesState();
}

class _MoviesState extends State<Movies> {
  DatabaseReference _firebaseRef =
      FirebaseDatabase.instance.ref().child('Movies');

  List<MovieListModel> movie_list = [];

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

              bool isAvailable = value['isAvailable'] ?? false;
              if (!isAvailable) return;

              // if (newMovie.category.contains('Latest'))
              movie_list.add(newMovie);
            });

            return _movies(movie_list);
          }),
    );
  }

  Widget _movies(List<MovieListModel> movie_list) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category title
          Text(
            'New & Hot Movies',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),

          SizedBox(height: 20),

          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 160,
                crossAxisSpacing: 0,
                mainAxisExtent: 160,
                mainAxisSpacing: 18,
              ),
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

  //
}

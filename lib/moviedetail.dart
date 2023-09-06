import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_app/datamodel/moviemodel.dart';
import 'package:my_app/movieplayer.dart';
import 'package:wakelock/wakelock.dart';

class MovieDetail extends StatefulWidget {
  const MovieDetail({super.key, required this.id});

  final String id;

  @override
  State<MovieDetail> createState() => _MovieDetailState();
}

class _MovieDetailState extends State<MovieDetail> {
  DatabaseReference _firebaseRef = FirebaseDatabase.instance.ref('Movies');

  Color grey_text = Color.fromARGB(255, 189, 189, 189);

  int more_container_list = 0;

  bool done = false;

  @override
  void initState() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    Wakelock.disable();
    super.initState();
  }

  var boxList = Hive.box('myList');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(24, 24, 24, 1),
      body: SafeArea(
        child: StreamBuilder(
          stream: _firebaseRef.child(widget.id).onValue,
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.hasError) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            MovieDetailModel movie =
                MovieDetailModel.fromSnapshot(snapshot.data!.snapshot);

            // check if already watching
            var box = Hive.box('lastDuration');
            bool started = box.containsKey(movie.movie_id);

            return SingleChildScrollView(
              child: Column(
                children: [
                  //Image
                  Stack(
                    children: [
                      CachedNetworkImage(
                        imageUrl: movie.movie_image!,
                        placeholder: (context, url) =>
                            Image.asset('images/placeholder.png'),
                        errorWidget: (context, url, error) =>
                            Image.asset('images/placeholder.png'),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 280,
                        // Adjust the image loading duration (optional)
                        fadeInDuration: Duration(milliseconds: 500),
                        fadeOutDuration: Duration(milliseconds: 1000),
                      ),

                      // preview text
                      Positioned(
                        bottom: 20,
                        left: 15,
                        child: (movie.trailer == '')
                            ? Container()
                            : Text(
                                'Preview',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                      ),

                      // play preview button
                      Positioned.fill(
                        child: Container(
                          color: Colors.white10,
                          child: Center(
                            child: (movie.trailer == '')
                                ? Container()
                                : InkWell(
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MoviePlayer(
                                          movieTitle: movie.movie_title!,
                                          movieUrl: movie.trailer!,
                                          movie_id: movie.movie_id!,
                                          subtitle: movie.subtitle!,
                                          preview: true,
                                        ),
                                      ),
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.black54,
                                        border: Border.all(
                                            color: Colors.white54, width: 3),
                                      ),
                                      padding: EdgeInsets.all(12),
                                      child: Icon(
                                        Icons.play_arrow,
                                        color: Colors.white,
                                        size: 50,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),

                      // close button
                      Positioned(
                        top: 20,
                        right: 15,
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black87,
                            ),
                            padding: EdgeInsets.all(8),
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  // movie detail
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          movie.movie_title!,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: Colors.white,
                          ),
                        ),

                        SizedBox(height: 20),

                        // Movie details
                        Row(
                          children: [
                            // relase year
                            Text(
                              movie.relase_year ?? '',
                              style: TextStyle(
                                fontSize: 16,
                                color: grey_text,
                              ),
                            ),

                            SizedBox(width: 8),

                            // rated
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 3),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: Color.fromARGB(129, 133, 133, 133),
                              ),
                              child: Text(
                                movie.movie_rated ?? '13+',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: grey_text,
                                ),
                              ),
                            ),

                            SizedBox(width: 8),

                            // duration
                            Text(
                              movie.duration ?? '0h 0m',
                              style: TextStyle(
                                fontSize: 16,
                                color: grey_text,
                              ),
                            ),

                            // divider
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Container(
                                width: 1,
                                height: 16,
                                color: grey_text,
                              ),
                            ),

                            // main genre
                            Text(
                              movie.main_genre ?? '',
                              style: TextStyle(
                                fontSize: 16,
                                color: grey_text,
                              ),
                            ),

                            // divider
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Container(
                                width: 1,
                                height: 16,
                                color: grey_text,
                              ),
                            ),

                            (movie.subtitle != '')
                                ? Icon(
                                    Icons.subtitles_outlined,
                                    size: 18,
                                    color: grey_text,
                                  )
                                : Container(),
                          ],
                        ),

                        SizedBox(height: 15),

                        // movie ranking
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.red.shade600,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              width: 35,
                              height: 30,
                              child: Center(
                                child: Text(
                                  'Top',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              '#${1} in Movies Today',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            )
                          ],
                        ),

                        SizedBox(height: 20),

                        // play button
                        InkWell(
                          onTap: () async {
                            var response = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MoviePlayer(
                                  movieTitle: movie.movie_title!,
                                  movieUrl: movie.movie_url!,
                                  movie_id: movie.movie_id!,
                                  subtitle: movie.subtitle!,
                                  preview: false,
                                ),
                              ),
                            );

                            if (response == 'done') {
                              setState(() {
                                done = true;
                              });
                            } else {
                              setState(() {});
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color:
                                  started ? Colors.white : Colors.red.shade600,
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 8),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.play_arrow,
                                    size: 35,
                                    color:
                                        started ? Colors.black : Colors.white,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    started
                                        ? 'Resume'
                                        : done
                                            ? 'Watch again'
                                            : 'Watch now',
                                    style: TextStyle(
                                      color:
                                          started ? Colors.black : Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 30),

                        // to-do
                        // progrees bar

                        // Movie description
                        Text(
                          movie.description ?? '',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            height: 1.5,
                          ),
                        ),

                        SizedBox(height: 20),

                        // casts
                        RichText(
                          text: TextSpan(
                            text: 'Starring: ',
                            style: TextStyle(fontSize: 16, color: grey_text),
                            children: [
                              TextSpan(
                                text: movie.cast_list ?? '',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: grey_text,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 5),

                        // director
                        RichText(
                          text: TextSpan(
                            text: 'Director: ',
                            style: TextStyle(fontSize: 16, color: grey_text),
                            children: [
                              TextSpan(
                                text: movie.director ?? '',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: grey_text,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 5),

                        // writer
                        RichText(
                          text: TextSpan(
                            text: 'Writer: ',
                            style: TextStyle(fontSize: 16, color: grey_text),
                            children: [
                              TextSpan(
                                text: movie.writer ?? '',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: grey_text,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 20),

                        // action button
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          child: Row(
                            // scrollDirection: Axis.horizontal,
                            // physics: BouncingScrollPhysics(),
                            children: [
                              // my list
                              InkWell(
                                onTap: () {
                                  if (boxList.containsKey(movie.movie_id)) {
                                    boxList.delete(movie.movie_id);
                                  } else {
                                    String now = DateTime.now().toString();
                                    boxList.put(movie.movie_id, now);
                                  }

                                  setState(() {});
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 20),
                                  child: Column(
                                    children: [
                                      Icon(boxList.containsKey(movie.movie_id) ? Icons.remove : Icons.add,
                                          color: Colors.white, size: 30),
                                      SizedBox(height: 8),
                                      Text(
                                        'My List',
                                        style: TextStyle(
                                            fontSize: 14, color: grey_text),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              SizedBox(width: 20),

                              // rate
                              InkWell(
                                onTap: () {},
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 20),
                                  child: Column(
                                    children: [
                                      Icon(Icons.thumb_up_alt_rounded,
                                          color: Colors.white, size: 30),
                                      SizedBox(height: 8),
                                      Text(
                                        'Rate',
                                        style: TextStyle(
                                            fontSize: 14, color: grey_text),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              SizedBox(width: 20),

                              // share
                              InkWell(
                                onTap: () {},
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 20),
                                  child: Column(
                                    children: [
                                      Icon(Icons.share_rounded,
                                          color: Colors.white, size: 30),
                                      SizedBox(height: 8),
                                      Text(
                                        'Share',
                                        style: TextStyle(
                                            fontSize: 14, color: grey_text),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 20),

                        Row(
                          // scrollDirection: Axis.horizontal,
                          // physics: BouncingScrollPhysics(),
                          children: [
                            // more
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  more_container_list = 0;
                                });
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: more_container_list == 0
                                          ? Colors.red.shade600
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    width: 115,
                                    height: 4,
                                  ),
                                  SizedBox(height: 20),
                                  Text(
                                    'More Like This',
                                    style: TextStyle(
                                      color: more_container_list == 0
                                          ? Colors.white
                                          : grey_text,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(width: 30),

                            // trailers
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  more_container_list = 1;
                                });
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: more_container_list == 1
                                          ? Colors.red.shade600
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    width: 120,
                                    height: 4,
                                  ),
                                  SizedBox(height: 20),
                                  Text(
                                    'Trailers & More',
                                    style: TextStyle(
                                      color: more_container_list == 1
                                          ? Colors.white
                                          : grey_text,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20),

                        Container(
                          height: 200,
                          width: double.infinity,
                          child: Center(
                            child: Text(
                              'No data available',
                              style: TextStyle(color: grey_text, fontSize: 15),
                            ),
                          ),
                        ),

                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

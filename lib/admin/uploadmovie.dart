import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_app/datamodel/moviemodel.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:my_app/widgets/confrim_action_dialog.dart';
import 'package:my_app/widgets/image_viewer.dart';
import 'package:my_app/widgets/loadingScreen.dart';
import 'package:my_app/widgets/video_viewer.dart';
import 'package:path/path.dart' as Path;
import 'package:file_picker/file_picker.dart';

List<String> selected_category = [];
List<String> categoryList = ['Latest', 'Popular', 'Trending', 'TV Shows'];

class UploadMovie extends StatefulWidget {
  const UploadMovie({super.key, required this.editMode, required this.mov_id});

  final bool editMode;
  final String mov_id;

  @override
  State<UploadMovie> createState() => _UploadMovieState();
}

class _UploadMovieState extends State<UploadMovie> {
  final TextEditingController id = TextEditingController();
  final TextEditingController title = TextEditingController();
  final TextEditingController year = TextEditingController();
  final TextEditingController age_rate = TextEditingController();
  final TextEditingController duration = TextEditingController();
  final TextEditingController main_genre = TextEditingController();
  final TextEditingController all_genre = TextEditingController();
  final TextEditingController description = TextEditingController();
  final TextEditingController cast = TextEditingController();
  final TextEditingController director = TextEditingController();
  final TextEditingController writer = TextEditingController();
  final TextEditingController movie_url = TextEditingController();
  final TextEditingController movie_trailer = TextEditingController();
  final TextEditingController movie_subtitle = TextEditingController();
  final TextEditingController movie_image = TextEditingController();
  final TextEditingController thumbnail = TextEditingController();
  final TextEditingController category = TextEditingController();

  bool set_banner = false;
  bool is_available = false;

  DatabaseReference _firebaseRef =
      FirebaseDatabase.instance.ref().child('Movies').push();

  getMovie(String id) async {
    DataSnapshot _fmovieRef =
        await FirebaseDatabase.instance.ref('Movies').child(id).get();

    MovieDetailModel movie = MovieDetailModel.fromSnapshot(_fmovieRef);

    setControllers(movie);
  }

  setControllers(MovieDetailModel? mov) {
    if (widget.editMode) {
      id.text = mov!.movie_id ?? '';
      title.text = mov.movie_title ?? '';
      year.text = mov.relase_year ?? '';
      age_rate.text = mov.movie_rated ?? '';
      duration.text = mov.duration ?? '';
      main_genre.text = mov.main_genre ?? '';
      all_genre.text = mov.genre_list ?? '';
      description.text = mov.description ?? '';
      cast.text = mov.cast_list ?? '';
      director.text = mov.director ?? '';
      writer.text = mov.writer ?? '';
      movie_url.text = mov.movie_url ?? '';
      movie_trailer.text = mov.trailer ?? '';
      movie_subtitle.text = mov.subtitle ?? '';
      thumbnail.text = mov.thumbnail ?? '';
      movie_image.text = mov.movie_image ?? '';
      category.text = mov.category ?? '';

      if (mov.category != '') selected_category = mov.category!.split(',');

      set_banner = mov.isBanner ?? false;
      is_available = mov.is_Available ?? false;
    } else {
      id.text = _firebaseRef.key!;
    }
    setState(() {});
  }

  addMovie() async {
    // check id, title,
    if (id.text.isEmpty || title.text.isEmpty) {
      //
      return;
    }

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => LoadingScreen());

    MovieDetailModel movie = MovieDetailModel(
      movie_id: id.text,
      movie_title: title.text,
      movie_url: movie_url.text,
      relase_year: year.text,
      movie_rated: age_rate.text,
      duration: duration.text,
      main_genre: main_genre.text,
      description: description.text,
      cast_list: cast.text,
      movie_image: movie_image.text,
      thumbnail: thumbnail.text,
      director: director.text,
      writer: writer.text,
      subtitle: movie_subtitle.text,
      trailer: movie_trailer.text,
      category: category.text,
      genre_list: all_genre.text,
      isBanner: set_banner,
      is_Available: is_available,
    );

    Map<String, dynamic> mov = movie.toJson();

    if (widget.editMode) {
      FirebaseDatabase.instance
          .ref('Movies')
          .child(movie.movie_id!)
          .update(mov);
    } else {
      _firebaseRef.set(mov);
    }

    if (set_banner) {
      await setBanner(movie.movie_id!);
    }

    Navigator.pop(context);

    Navigator.pop(context);
  }

  setBanner(String id) async {
    final dataSnapshot = await FirebaseDatabase.instance.ref('Movies').get();

    Map value = dataSnapshot.value as Map;

    // Loop through each record in the database
    value.forEach((key, value) {
      if (key != id) {
        bool is_ban = value['isBanner'] ?? true;

        if (is_ban) {
          FirebaseDatabase.instance
              .ref('Movies')
              .child(key)
              .child('isBanner')
              .set(false);
        }
      }
    });
  }

  Future<Uint8List?> selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      Uint8List file = result.files.single.bytes!;

      return file;
    } else {
      return null;
    }
  }

  Future<String?> uploadFile(Uint8List file, String type) async {
    // String fileName = Path.basename(file.path);

    try {
      Reference storageReference =
          FirebaseStorage.instance.ref().child('${id.text}/$type');
      UploadTask uploadTask = storageReference.putData(file);
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);

      if (taskSnapshot.state == TaskState.success) {
        String downloadUrl = await taskSnapshot.ref.getDownloadURL();
        return downloadUrl;
      }
    } catch (e) {
      print(e.toString());
    }

    return null;
  }

  deleteMovie() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => LoadingScreen());

    FirebaseDatabase.instance.ref('Movies').child(id.text).remove();

    Navigator.pop(context);

    Navigator.pop(context);
  }

  @override
  void initState() {
    selected_category.clear();
    if (widget.editMode) {
      getMovie(widget.mov_id);
    } else {
      setControllers(null);
    }
    super.initState();
  }

  @override
  void dispose() {
    id.dispose();
    title.dispose();
    year.dispose();
    age_rate.dispose();
    duration.dispose();
    main_genre.dispose();
    all_genre.dispose();
    description.dispose();
    cast.dispose();
    director.dispose();
    writer.dispose();
    movie_url.dispose();
    movie_trailer.dispose();
    movie_subtitle.dispose();
    thumbnail.dispose();
    movie_image.dispose();
    category.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    category.text = selected_category.join(',');

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.editMode ? 'Edit Movie' : 'Add movie'),
        actions: [
          // delete
          widget.editMode
              ? Padding(
                  padding: EdgeInsets.only(right: 20),
                  child: GestureDetector(
                    onTap: () async {
                      final confirmed = await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return ConfirmActionDialog(
                            title: 'Delete movie',
                            subtitle:
                                'Would you like to delete this movie, this cannot be undone!',
                          );
                        },
                      );

                      if (confirmed) {
                        deleteMovie();
                      } else {
                        // Action cancelled
                      }
                    },
                    child: Icon(
                      Icons.delete,
                      size: 25,
                    ),
                  ),
                )
              : Container(),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // id
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Movie ID',
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: id,
                            style: TextStyle(color: Colors.white),
                            readOnly: true,
                            decoration: InputDecoration(
                              hintText: 'Movie ID',
                              hintStyle: TextStyle(color: Colors.white60),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white60),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // title
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Movie title',
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: title,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Movie Title',
                              hintStyle: TextStyle(color: Colors.white60),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white60),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // main genre , duration
                    Row(
                      children: [
                        // main genre
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Movie genre',
                                  style: TextStyle(color: Colors.white),
                                ),
                                SizedBox(height: 10),
                                TextField(
                                  controller: main_genre,
                                  style: TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: 'Drama',
                                    hintStyle: TextStyle(color: Colors.white60),
                                    border: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white60),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // duration
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Duration',
                                  style: TextStyle(color: Colors.white),
                                ),
                                SizedBox(height: 10),
                                TextField(
                                  controller: duration,
                                  style: TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: '2h 34m',
                                    hintStyle: TextStyle(color: Colors.white60),
                                    border: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white60),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    // list of genre
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'All genre',
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: all_genre,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Drama, Rommance, Horror',
                              hintStyle: TextStyle(color: Colors.white60),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white60),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // year , age rate
                    Row(
                      children: [
                        // year
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Release year',
                                  style: TextStyle(color: Colors.white),
                                ),
                                SizedBox(height: 10),
                                TextField(
                                  controller: year,
                                  style: TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: 'YYYY',
                                    hintStyle: TextStyle(color: Colors.white60),
                                    border: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white60),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // age rate
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Age rating',
                                  style: TextStyle(color: Colors.white),
                                ),
                                SizedBox(height: 10),
                                TextField(
                                  controller: age_rate,
                                  style: TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: '13+',
                                    hintStyle: TextStyle(color: Colors.white60),
                                    border: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white60),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    // category
                    Row(
                      children: [
                        // category
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Movie category',
                                  style: TextStyle(color: Colors.white),
                                ),
                                SizedBox(height: 10),
                                TextField(
                                  controller: category,
                                  readOnly: true,
                                  style: TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: '',
                                    hintStyle: TextStyle(color: Colors.white60),
                                    border: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white60),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // viewer / uploader
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(''),
                              SizedBox(height: 10),
                              InkWell(
                                onTap: () async {
                                  await showDialog(
                                      context: context,
                                      builder: (context) => CategoryDialog());

                                  setState(() {});
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: EdgeInsets.all(13),
                                  child: Icon(
                                    Icons.select_all_rounded,
                                    size: 25,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // description
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Movie description',
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: description,
                            maxLines: 5,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Description...',
                              hintStyle: TextStyle(color: Colors.white60),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white60),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // cast
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Movie cast',
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: cast,
                            maxLines: 3,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Michael Yen, James Clark, All cast...',
                              hintStyle: TextStyle(color: Colors.white60),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white60),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // director , writer
                    Row(
                      children: [
                        // director
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Director',
                                  style: TextStyle(color: Colors.white),
                                ),
                                SizedBox(height: 10),
                                TextField(
                                  controller: director,
                                  style: TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: 'Christopher Nolan',
                                    hintStyle: TextStyle(color: Colors.white60),
                                    border: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white60),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // writer
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Writer',
                                  style: TextStyle(color: Colors.white),
                                ),
                                SizedBox(height: 10),
                                TextField(
                                  controller: writer,
                                  style: TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: 'David Washington',
                                    hintStyle: TextStyle(color: Colors.white60),
                                    border: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white60),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    // thumbnail
                    Row(
                      children: [
                        // thumbnail
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Movie thumbnail',
                                  style: TextStyle(color: Colors.white),
                                ),
                                SizedBox(height: 10),
                                TextField(
                                  controller: thumbnail,
                                  style: TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: 'https://example.png...',
                                    hintStyle: TextStyle(color: Colors.white60),
                                    border: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white60),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    setState(() {});
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),

                        // viewer / uploader
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(''),
                              SizedBox(height: 10),
                              InkWell(
                                onTap: () async {
                                  if (thumbnail.text.isNotEmpty) {
                                    showDialog(
                                        context: context,
                                        builder: (context) => ImageViewer(
                                              image: thumbnail.text,
                                            ));
                                  } else {
                                    showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (context) => LoadingScreen());

                                    Uint8List? _file = await selectFile();

                                    if (_file != null) {
                                      String? _path =
                                          await uploadFile(_file, 'thumbnail');
                                      thumbnail.text = _path!;
                                    }

                                    Navigator.pop(context);

                                    setState(() {});
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: EdgeInsets.all(13),
                                  child: Icon(
                                    thumbnail.text.isNotEmpty
                                        ? Icons.image
                                        : Icons.upload,
                                    size: 25,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // movie image
                    Row(
                      children: [
                        // image
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Movie image',
                                  style: TextStyle(color: Colors.white),
                                ),
                                SizedBox(height: 10),
                                TextField(
                                  controller: movie_image,
                                  style: TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: 'https://example.png...',
                                    hintStyle: TextStyle(color: Colors.white60),
                                    border: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white60),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    setState(() {});
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),

                        // viewer / uploader
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(''),
                              SizedBox(height: 10),
                              InkWell(
                                onTap: () async {
                                  if (movie_image.text.isNotEmpty) {
                                    showDialog(
                                        context: context,
                                        builder: (context) => ImageViewer(
                                              image: movie_image.text,
                                            ));
                                  } else {
                                    showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (context) => LoadingScreen());
                                    Uint8List? _file = await selectFile();

                                    if (_file != null) {
                                      String? _path = await uploadFile(
                                          _file, 'movie_image');
                                      movie_image.text = _path!;
                                    }

                                    Navigator.pop(context);

                                    setState(() {});
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: EdgeInsets.all(13),
                                  child: Icon(
                                    movie_image.text.isNotEmpty
                                        ? Icons.image
                                        : Icons.upload,
                                    size: 25,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // trailer
                    Row(
                      children: [
                        // trailer
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Movie trailer',
                                  style: TextStyle(color: Colors.white),
                                ),
                                SizedBox(height: 10),
                                TextField(
                                  controller: movie_trailer,
                                  style: TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: 'https://example.mp4...',
                                    hintStyle: TextStyle(color: Colors.white60),
                                    border: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white60),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    setState(() {});
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),

                        // viewer / uploader
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(''),
                              SizedBox(height: 10),
                              InkWell(
                                onTap: () {
                                  if (movie_trailer.text.isEmpty) return;
                                  showDialog(
                                      context: context,
                                      builder: (context) => VideoViewer(
                                            movieUrl: movie_trailer.text,
                                          ));
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: EdgeInsets.all(13),
                                  child: Icon(
                                    Icons.movie_creation_rounded,
                                    size: 25,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // movie url
                    Row(
                      children: [
                        // url
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Movie URL',
                                  style: TextStyle(color: Colors.white),
                                ),
                                SizedBox(height: 10),
                                TextField(
                                  controller: movie_url,
                                  style: TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: 'https://example.mkv...',
                                    hintStyle: TextStyle(color: Colors.white60),
                                    border: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white60),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    setState(() {});
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),

                        // viewer / uploader
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(''),
                              SizedBox(height: 10),
                              InkWell(
                                onTap: () {
                                  if (movie_url.text.isEmpty) return;
                                  showDialog(
                                      context: context,
                                      builder: (context) => VideoViewer(
                                            movieUrl: movie_url.text,
                                          ));
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: EdgeInsets.all(13),
                                  child: Icon(
                                    Icons.movie_creation_rounded,
                                    size: 25,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // subtitle
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Movie subtitle',
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: movie_subtitle,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'https://example.srt...',
                              hintStyle: TextStyle(color: Colors.white60),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white60),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // set banner , set availability
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      child: Row(
                        children: [
                          Text(
                            'Set as banner',
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(width: 20),
                          // banner switch
                          Switch(
                            value: set_banner,
                            onChanged: (value) {
                              setState(() {
                                set_banner = !set_banner;
                              });
                            },
                          ),
                          SizedBox(width: 50),
                          Text(
                            'Set availablity',
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(width: 20),
                          // available switch
                          Switch(
                            value: is_available,
                            onChanged: (value) {
                              setState(() {
                                is_available = !is_available;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // add button
          Padding(
            padding: EdgeInsets.all(12),
            child: InkWell(
              onTap: () {
                addMovie();
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
                        size: 30,
                        color: Colors.white70,
                      ),
                      SizedBox(width: 6),
                      Text(
                        widget.editMode ? 'Update Movie' : 'Add Movie',
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
}

class CategoryDialog extends StatefulWidget {
  const CategoryDialog({super.key});

  @override
  State<CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<CategoryDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Center(
        child: Container(
          color: Colors.white70,
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.all(8),
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        'Select all categories',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 3,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          Icons.close,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                thickness: 1,
                color: Colors.black54,
              ),

              // list
              categoryList.isEmpty
                  ? Container()
                  : Padding(
                      padding: EdgeInsets.all(8),
                      child: Container(
                        height: 350,
                        child: ListView.builder(
                          itemCount: categoryList.length,
                          itemBuilder: (BuildContext context, int index) {
                            final item = categoryList[index];
                            return CheckboxListTile(
                              title: Text(item),
                              value: selected_category.contains(item),
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value!) {
                                    selected_category.add(item);
                                  } else {
                                    selected_category.remove(item);
                                  }
                                });
                              },
                              onFocusChange: (value) {
                                setState(() {});
                              },
                            );
                          },
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

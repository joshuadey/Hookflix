import 'package:firebase_database/firebase_database.dart';

class MovieDetailModel {
  String? movie_id;
  String? movie_title;
  String? movie_url;
  String? relase_year;
  String? movie_rated;
  String? duration;
  String? main_genre;
  String? description;
  String? cast_list;
  String? movie_image;
  String? thumbnail;
  String? director;
  String? writer;
  String? subtitle;
  String? trailer;
  String? genre_list;
  String? category;
  bool? isBanner;
  bool? is_Available;

  MovieDetailModel({
    required this.movie_id,
    required this.movie_title,
    required this.movie_url,
    required this.relase_year,
    required this.movie_rated,
    required this.duration,
    required this.main_genre,
    required this.description,
    required this.cast_list,
    required this.movie_image,
    required this.thumbnail,
    required this.director,
    required this.writer,
    required this.subtitle,
    required this.trailer,
    required this.category,
    required this.genre_list,
    required this.isBanner,
    required this.is_Available,
  });

  MovieDetailModel.fromSnapshot(DataSnapshot snapshot) {
    Map value = snapshot.value as Map;

    movie_id = snapshot.key;
    movie_title = value['movie_title'] ?? '';
    movie_url = value['movie_url'] ?? '';
    relase_year = value['relase_year'] ?? '';
    movie_rated = value['movie_rated'] ?? '';
    duration = value['duration'] ?? '';
    main_genre = value['main_genre'] ?? '';
    description = value['description'] ?? '';
    cast_list = value['cast_list'] ?? '';
    director = value['director'] ?? '';
    writer = value['writer'] ?? '';
    movie_image = value['movie_image'] ?? '';
    thumbnail = value['movie_thumbnail'] ?? '';
    subtitle = value['subtitle'] ?? '';
    trailer = value['trailer'] ?? '';
    genre_list = value['movie_genres'] ?? '';
    category = value['category'] ?? '';
    isBanner = value['isBanner'] ?? false;
    is_Available = value['isAvailable'] ?? false;
  }

  Map<String, dynamic> toJson() {
    return {
      'movie_id': movie_id,
      'movie_title': movie_title,
      'movie_url': movie_url,
      'relase_year': relase_year,
      'movie_rated': movie_rated,
      'duration': duration,
      'main_genre': main_genre,
      'description': description,
      'cast_list': cast_list,
      'director': director,
      'writer': writer,
      'movie_image': movie_image,
      'movie_thumbnail': thumbnail,
      'trailer': trailer,
      'subtitle': subtitle,
      'movie_genres': genre_list,
      'category': category,
      'isBanner': isBanner,
      'isAvailable': is_Available,
    };
  }
}

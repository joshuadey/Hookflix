class MovieListModel {
  String id;
  String title;
  String thumbnail;
  String category;
  String movie_url;
  String subtitle;
  List<String> genre_list;

  MovieListModel({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.category,
    required this.movie_url,
    required this.subtitle,
    required this.genre_list,
  });
}

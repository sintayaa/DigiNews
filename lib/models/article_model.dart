class ArticleModel {
  String? title;
  String? thumb;
  String? author;
  String? tag;
  String? time;
  String? desc;
  String? key;

  ArticleModel({
    this.title,
    this.thumb,
    this.author,
    this.tag,
    this.time,
    this.desc,
    this.key,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      title: json['title'] as String?,
      thumb: json['thumb'] as String?,
      author: json['author'] as String?,
      tag: json['tag'] as String?,
      time: json['time'] as String?,
      desc: json['desc'] as String?, // Ensure this matches the API field
      key: json['key'] as String?,
    );
  }
}

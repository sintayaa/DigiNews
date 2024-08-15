class NewsDetail {
  final String title;
  final String author;
  final String date;
  final List<String> categories;
  final List<String> figure;
  final List<String> content;

  NewsDetail({
    required this.title,
    required this.author,
    required this.date,
    required this.categories,
    required this.figure,
    required this.content,
  });

  factory NewsDetail.fromJson(Map<String, dynamic> json) {
    return NewsDetail(
      title: json['title'],
      author: json['author'],
      date: json['date'],
      categories: List<String>.from(json['categories']),
      figure: List<String>.from(json['figure']),
      content: List<String>.from(json['content']),
    );
  }
}

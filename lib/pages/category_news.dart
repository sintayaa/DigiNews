import 'package:cached_network_image/cached_network_image.dart';
import 'package:diginews/models/show_category.dart';
import 'package:diginews/pages/detail_news.dart';
import 'package:diginews/services/show_category_news.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart'; // Import shimmer package

class CategoryNews extends StatefulWidget {
  final String name;
  const CategoryNews({super.key, required this.name});

  @override
  State<CategoryNews> createState() => _CategoryNewsState();
}

class _CategoryNewsState extends State<CategoryNews> {
  List<ShowCategoryModel> categories = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    getNews();
  }

  Future<void> getNews() async {
    ShowCategoryNews showCategoryNews = ShowCategoryNews();
    await showCategoryNews.getCategoriesNews(widget.name.toLowerCase());
    setState(() {
      categories = showCategoryNews.categories;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.name,
          style: const TextStyle(
              color: Colors.orange, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: _loading
          ? buildShimmer() // Use shimmer when loading
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return ShowCategory(
                  thumb: categories[index].thumb!,
                  desc: categories[index].desc!,
                  title: categories[index].title!,
                  url: categories[index].key!,
                );
              },
            ),
    );
  }

  Widget buildShimmer() => Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          itemCount: 6, // Number of shimmer placeholders
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.white,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 100,
                          height: 20,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 4.0),
                        Container(
                          width: double.infinity,
                          height: 60,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
}

class ShowCategory extends StatelessWidget {
  final String thumb, desc, title, url;
  const ShowCategory({
    super.key,
    required this.thumb,
    required this.desc,
    required this.title,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => NewsDetailScreen(newsKey: url)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0), // Added margin for spacing
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0), // Added border radius
          color: Colors.white, // Optional: background color
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3), // Shadow position
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  BorderRadius.circular(12.0), // Matching border radius
              child: CachedNetworkImage(
                imageUrl: thumb,
                width: MediaQuery.of(context).size.width,
                height: 200,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => const Icon(Icons.error),
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0), // Added padding for content
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    desc,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

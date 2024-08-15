import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:diginews/models/article_model.dart';
import 'package:diginews/pages/article_view.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AllNews extends StatefulWidget {
  final String news;
  const AllNews({super.key, required this.news});

  @override
  State<AllNews> createState() => _AllNewsState();
}

class _AllNewsState extends State<AllNews> {
  List<ArticleModel> articles = [];
  bool _loading = true;
  bool _hasMore = true;
  int _page = 1; // Track current page
  final int _pageSize = 20; // Define the page size for fetching news

  @override
  void initState() {
    super.initState();
    getNews();
  }

  Future<void> getNews() async {
    if (!_hasMore) return;

    setState(() {
      _loading = true;
    });

    try {
      final response = await http.get(Uri.parse(
          'https://the-lazy-media-api.vercel.app/api/tech/news?page=$_page'));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final articlesJson = jsonData['articles'] as List;
        setState(() {
          articles.addAll(
              articlesJson.map((json) => ArticleModel.fromJson(json)).toList());
          _loading = false;
          _hasMore = articlesJson.length ==
              _pageSize; // Check if more articles are available
          _page++; // Increment the page number for the next request
        });
      } else {
        throw Exception('Failed to load news');
      }
    } catch (e) {
      // Handle errors here
      setState(() {
        _loading = false;
      });
      print('Error fetching news: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Berita ${widget.news}",
          style: const TextStyle(
              color: Colors.orange, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: _loading && articles.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : NotificationListener<ScrollNotification>(
              onNotification: (scrollInfo) {
                if (!_loading &&
                    _hasMore &&
                    scrollInfo.metrics.pixels ==
                        scrollInfo.metrics.maxScrollExtent) {
                  getNews();
                }
                return false;
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10.0),
                child: ListView.builder(
                  itemCount: articles.length +
                      (_hasMore
                          ? 1
                          : 0), // Add one more for the loading indicator
                  itemBuilder: (context, index) {
                    if (index == articles.length) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final article = articles[index];
                    return AllNewsSection(
                      thumb: article.thumb!,
                      desc: article.desc!,
                      title: article.title!,
                      url: article.key!,
                    );
                  },
                ),
              ),
            ),
    );
  }
}

class AllNewsSection extends StatelessWidget {
  final String thumb;
  final String desc;
  final String title;
  final String url;

  const AllNewsSection({
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
          MaterialPageRoute(builder: (context) => ArticleView(blogUrl: url)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
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
            const SizedBox(height: 5.0),
            Text(
              title,
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              desc,
              maxLines: 3,
              overflow:
                  TextOverflow.ellipsis, // Added to handle long descriptions
            ),
            const SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }
}

import 'dart:convert';

import 'package:diginews/models/detail_model.dart'; // Import your model
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NewsDetailScreen extends StatefulWidget {
  final String newsKey;

  const NewsDetailScreen({super.key, required this.newsKey});

  @override
  _NewsDetailScreenState createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  late Future<NewsDetail> _newsDetailFuture;

  @override
  void initState() {
    super.initState();
    _newsDetailFuture = fetchNewsDetail(widget.newsKey);
  }

  Future<NewsDetail> fetchNewsDetail(String key) async {
    final response = await http.get(
        Uri.parse('https://the-lazy-media-api.vercel.app/api/detail/$key'));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return NewsDetail.fromJson(json['results']);
    } else {
      throw Exception('Failed to load news detail');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Digi"),
            Text(
              "News",
              style:
                  TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: FutureBuilder<NewsDetail>(
        future: _newsDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No detail available'));
          } else {
            final news = snapshot.data!;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(news.title,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8.0),
                    Text('By ${news.author}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8.0),
                    Text(news.date, style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 16.0),

                    // Display figures if there are any
                    if (news.figure.isNotEmpty) ...[
                      SizedBox(
                        height: 200, // Adjust height as needed
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: news.figure.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  news.figure[index],
                                  width: 150, // Adjust width as needed
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey,
                                      child: const Icon(Icons.error,
                                          color: Colors.red),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16.0),
                    ],

                    // Display content
                    ...news.content.map((line) => Text(
                          line,
                          textAlign:
                              TextAlign.justify, // Justify text alignment
                          style: const TextStyle(
                            fontSize: 16.0, // Adjust font size as needed
                            height: 1.5, // Adjust line height as needed
                          ),
                        )),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

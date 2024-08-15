import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ArticleView extends StatefulWidget {
  final String blogUrl; // Use final for immutable properties

  const ArticleView({super.key, required this.blogUrl});

  @override
  State<ArticleView> createState() => _ArticleViewState();
}

class _ArticleViewState extends State<ArticleView> {
  @override
  void initState() {
    super.initState();
    print(
        "ArticleView initialized with URL: ${widget.blogUrl}"); // Tambahkan log
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
      body: const WebView(
        initialUrl: "google.com",
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}

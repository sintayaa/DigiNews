import 'package:carousel_slider/carousel_slider.dart';
import 'package:diginews/models/article_model.dart';
import 'package:diginews/models/category_model.dart';
import 'package:diginews/models/slider_model.dart';
import 'package:diginews/pages/category_news.dart';
import 'package:diginews/pages/detail_news.dart';
import 'package:diginews/services/data.dart';
import 'package:diginews/services/news.dart';
import 'package:diginews/services/slider_data.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<CategoryModel> categories = [];
  List<sliderModel> sliders = [];
  List<ArticleModel> articles = [];
  List<ArticleModel> filteredArticles = [];
  bool _loading = true;
  int activeIndex = 0;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    categories = getCategories();
    getSlider();
    getNews();
  }

  Future<void> getNews() async {
    News newsClass = News();
    await newsClass.getNews();
    setState(() {
      articles = newsClass.news;
      filteredArticles = articles;
      _loading = false;
    });
  }

  Future<void> getSlider() async {
    Sliders slider = Sliders();
    await slider.getSlider();
    setState(() {
      sliders = slider.sliders;
      if (sliders.length > 5) {
        sliders = sliders.sublist(0, 5);
      }
    });
  }

  Future<void> _search(String query) async {
    if (query.isNotEmpty) {
      setState(() {
        _loading = true;
      });

      News newsClass = News();
      await newsClass.searchNews(query);
      setState(() {
        filteredArticles = newsClass.news;
        _loading = false;
      });
    } else {
      setState(() {
        filteredArticles = articles;
        _isSearching = false;
      });
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
    });
    if (_isSearching) {
      await _search(_searchController.text);
    } else {
      await getNews();
      setState(() {
        _isSearching = false;
        _searchController.clear();
      });
    }

    setState(() {
      activeIndex = 0;
    });

    _scrollController.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  border: InputBorder.none,
                ),
                onChanged: (query) async {
                  await _search(query);
                },
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Digi"),
                  Text(
                    "News",
                    style: TextStyle(
                        color: Colors.orange, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
        centerTitle: true,
        elevation: 0.0,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () async {
              if (_isSearching) {
                setState(() {
                  _isSearching = false;
                  _searchController.clear();
                  filteredArticles = articles;
                });
                await _refresh();
              } else {
                setState(() {
                  _isSearching = true;
                });
              }
            },
          ),
        ],
      ),
      body: _loading
          ? buildShimmer()
          : RefreshIndicator(
              onRefresh: _refresh,
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!_isSearching) ...[
                      buildCategoryList(),
                      const SizedBox(height: 30.0),
                      buildCarouselSlider(),
                      const SizedBox(height: 20.0),
                      Center(child: buildIndicator()),
                      const SizedBox(height: 20.0),
                      buildRecommendedNewsTitle(),
                      buildRecommendedNewsList(),
                    ],
                    if (_isSearching) ...[
                      buildSearchResultsList(),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget buildCategoryList() {
    return Container(
      margin: const EdgeInsets.only(left: 10.0),
      height: 43,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return CategoryTile(
            categoryName: categories[index].categoryName ?? 'Unknown',
          );
        },
      ),
    );
  }

  Widget buildCarouselSlider() {
    return CarouselSlider.builder(
      itemCount: sliders.length,
      itemBuilder: (context, index, realIndex) {
        final slider = sliders[index];
        return buildImage(slider.thumb!, index, slider.title!);
      },
      options: CarouselOptions(
        height: 250,
        autoPlay: true,
        enlargeCenterPage: true,
        enlargeStrategy: CenterPageEnlargeStrategy.height,
        onPageChanged: (index, reason) {
          setState(() {
            activeIndex = index;
          });
        },
      ),
    );
  }

  Widget buildRecommendedNewsTitle() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Berita Rekomendasi",
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18.0),
          ),
          SizedBox(height: 10.0),
        ],
      ),
    );
  }

  Widget buildRecommendedNewsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredArticles.length,
      itemBuilder: (context, index) {
        final article = filteredArticles[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: BlogTile(
            key: ValueKey(article.key),
            desc: article.desc ?? 'No description',
            imageUrl: article.thumb ?? '',
            title: article.title ?? 'No title',
            blogUrl: article.key ?? '',
          ),
        );
      },
    );
  }

  Widget buildSearchResultsList() {
    if (_loading) {
      // Tampilkan shimmer loading jika sedang memuat data
      return buildShimmerSearchResults();
    } else {
      // Tampilkan daftar berita jika data sudah siap
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: filteredArticles.length,
        itemBuilder: (context, index) {
          final article = filteredArticles[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: BlogTile(
              key: ValueKey(article.key),
              desc: article.desc ?? 'No description',
              imageUrl: article.thumb ?? '',
              title: article.title ?? 'No title',
              blogUrl: article.key ?? '',
            ),
          );
        },
      );
    }
  }

  Widget buildImage(String image, int index, String name) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 5.0),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                image,
                height: 250,
                fit: BoxFit.cover,
                width: MediaQuery.of(context).size.width,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 250,
                    width: MediaQuery.of(context).size.width,
                    color: Colors.grey,
                    child: const Icon(Icons.error, color: Colors.red),
                  );
                },
              ),
            ),
            Container(
              height: 250,
              padding: const EdgeInsets.only(left: 10.0),
              margin: const EdgeInsets.only(top: 170.0),
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              child: Center(
                child: Text(
                  name,
                  maxLines: 2,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  Widget buildIndicator() => AnimatedSmoothIndicator(
        activeIndex: activeIndex,
        count: sliders.length,
        effect: const SlideEffect(
          dotWidth: 15,
          dotHeight: 15,
          activeDotColor: Colors.orange,
        ),
      );

  Widget buildShimmer() => Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(left: 10.0),
              height: 43,
              child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: 5, // Adjust this count as needed
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Center(
                      child: Container(
                        width: 60,
                        height: 20,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20.0),
            Container(
              height: 250,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 20.0),
            buildShimmerLoadingTile(),
            buildShimmerLoadingTile(),
            buildShimmerLoadingTile(),
            buildShimmerLoadingTile(),
          ],
        ),
      );

  Widget buildShimmerSearchResults() => Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(5, (index) => buildShimmerLoadingTile()),
        ),
      );

  Widget buildShimmerLoadingTile() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
      child: ShimmerLoading(
        height: 130,
        width: double.infinity,
      ),
    );
  }
}

class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;

  const ShimmerLoading({
    this.width = double.infinity,
    this.height = 100.0,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Colors.white,
    );
  }
}

class CategoryTile extends StatelessWidget {
  final String categoryName;

  const CategoryTile({
    required this.categoryName,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryNews(name: categoryName),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Center(
          child: Text(
            categoryName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class BlogTile extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String desc;
  final String blogUrl;

  const BlogTile({
    required Key key,
    required this.desc,
    required this.imageUrl,
    required this.title,
    required this.blogUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewsDetailScreen(
              newsKey: blogUrl,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Material(
          elevation: 3.0,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 3.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    imageUrl,
                    height: 130,
                    width: 130,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 130,
                        width: 130,
                        color: Colors.grey,
                        child: const Icon(Icons.error, color: Colors.red),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 5.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 7.0),
                      Text(
                        title,
                        maxLines: 2,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 17.0,
                        ),
                      ),
                      const SizedBox(height: 5.0),
                      Text(
                        desc,
                        maxLines: 3,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                          fontSize: 17.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

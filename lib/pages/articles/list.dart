import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:lazyreader/components/article_card.dart';

import 'package:lazyreader/pages/articles/sidebar.dart';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:lazyreader/service/article_service.dart';

class ImageCacheManager {
  static final ImageCacheManager _instance = ImageCacheManager._internal();
  factory ImageCacheManager() => _instance;
  ImageCacheManager._internal();

  final Map<String, Uint8List> _cache = {};

  Uint8List? getImageFromCache(String url) {
    return _cache[url];
  }

  void addImageToCache(String url, Uint8List imageData) {
    _cache[url] = imageData;
  }
}

class ArticleList extends StatefulWidget {
  const ArticleList({Key? key}) : super(key: key);

  @override
  _ArticleListState createState() => _ArticleListState();
}

// ignore: unused_element
class _CIProperties {
  final String name;
  bool disable = false;
  bool clamping = false;
  bool background = false;
  MainAxisAlignment alignment;
  bool message = true;
  bool text = true;
  bool infinite;
  bool immediately = false;

  _CIProperties({
    required this.name,
    required this.alignment,
    required this.infinite,
  });
}

class _ArticleListState extends State<ArticleList> {
  List<Map<String, dynamic>> articleList = [];
  Map<String, dynamic> nowFeed = {};
  bool isMore = true;
  int currentPage = 1;
  int totalPages = 1;
  late EasyRefreshController _controller;
  int _selectedIndex = 0;

  Axis _scrollDirection = Axis.vertical;

  @override
  void initState() {
    super.initState();
    fetchData(true);
    _controller = EasyRefreshController(
      controlFinishRefresh: true,
      controlFinishLoad: true,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateSelectedIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> fetchData(bool reset) async {
    ArticleService articleService = ArticleService();

    // 如果是重置，则从第1页开始
    if (reset) {
      currentPage = 1;
    }

    Map<String, dynamic> queryParams = {
      'page': currentPage,
      'per_page': 20,
    };

    // 如果选择了特定feed，添加feed_id参数
    if (nowFeed.isNotEmpty && nowFeed['feed_id'] != null) {
      queryParams['feed_id'] = nowFeed['feed_id'];
    }

    try {
      var response = await articleService.getSubscriptionArticles(queryParams);
      if (response['code'] == 200) {
        var result = response['data'];
        List<Map<String, dynamic>> newDataList =
            List<Map<String, dynamic>>.from(result['items']);

        setState(() {
          if (reset) {
            articleList = newDataList;
          } else {
            articleList.addAll(newDataList);
          }

          currentPage = result['current_page'];
          totalPages = result['pages'];
          isMore = currentPage < totalPages;

          // 如果加载成功且还有更多数据，增加页码
          if (!reset && isMore) {
            currentPage++;
          }
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leadingWidth: 26,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: Text(nowFeed.isEmpty ? "All Articles" : nowFeed['title'] ?? "",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      drawer: Drawer(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.zero,
              bottomRight: Radius.zero,
            ),
          ),
          child: SafeArea(
            child: FeedDrawer(
              selectedIndex: _selectedIndex,
              onSelectedIndexChange: _updateSelectedIndex,
              onSelectFeed: (feed) {
                setState(() {
                  articleList = [];
                  nowFeed = feed ?? {};
                });
                fetchData(true);
              },
            ),
          )),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Stack(
                      children: <Widget>[
                        EasyRefresh(
                          clipBehavior: Clip.none,
                          controller: _controller,
                          header: const ClassicHeader(),
                          footer: const ClassicFooter(),
                          onRefresh: () async {
                            await fetchData(true);
                            if (!mounted) return;
                            _controller.finishRefresh();
                            _controller.resetFooter();
                          },
                          onLoad: () async {
                            if (isMore) {
                              await fetchData(false);
                            }
                            if (!mounted) return;
                            _controller.finishLoad(
                              !isMore
                                  ? IndicatorResult.noMore
                                  : IndicatorResult.success,
                            );
                          },
                          child: articleList.isEmpty
                              ? const Center(
                                  child: Text('No articles found'),
                                )
                              : ListView.separated(
                                  itemCount: articleList.length,
                                  scrollDirection: _scrollDirection,
                                  separatorBuilder: (context, index) {
                                    return Divider(
                                      thickness: 1,
                                      color: Colors.grey[200],
                                    );
                                  },
                                  itemBuilder: (context, index) {
                                    return ArticleCard(
                                      article: articleList[index],
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

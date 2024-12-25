import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lazyreader/components/article_card.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:lazyreader/service/article_service.dart';

class ArticleList extends StatefulWidget {
  const ArticleList({Key? key}) : super(key: key);

  @override
  _ArticleListState createState() => _ArticleListState();
}

class _ArticleListState extends State<ArticleList> {
  List<Map<String, dynamic>> articleList = [];
  Map<String, dynamic> nowFeed = {};
  bool isMore = true;
  int currentPage = 1;
  int totalPages = 1;
  bool isLoading = true; // 添加 loading 状态
  late EasyRefreshController _controller;
  List<Map<String, dynamic>> feedsList = [];
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> filteredFeeds = [];

  @override
  void initState() {
    super.initState();
    _controller = EasyRefreshController(
      controlFinishRefresh: true,
      controlFinishLoad: true,
    );
    _initializeData();
  }

  // 新增初始化数据的方法
  Future<void> _initializeData() async {
    setState(() {
      isLoading = true;
    });
    await Future.wait([
      fetchData(true),
      fetchFeeds(),
    ]);
    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    searchController.dispose();
    super.dispose();
  }

  void filterFeeds(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredFeeds = feedsList;
      } else {
        filteredFeeds = feedsList.where((feed) {
          final title = feed['title']?.toString().toLowerCase() ?? '';
          return title.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  Future<void> fetchFeeds() async {
    ArticleService articleService = ArticleService();
    try {
      Map<String, dynamic> params = {
        'page': 1,
        'per_page': 100 // 设置一个较大的数值以获取所有订阅源
      };

      var response = await articleService.getUserSubscriptions(params);
      print('Feeds response: $response'); // 添加日志查看响应数据

      if (response['code'] == 200) {
        setState(() {
          feedsList = List<Map<String, dynamic>>.from(response['data']['items'])
              .map((feed) {
            return feed;
          }).toList();

          filteredFeeds = feedsList;
          print('Processed feeds: $feedsList'); // 添加日志查看处理后的数据
        });
      }
    } catch (e) {
      print('Error fetching feeds: $e');
    }
  }

  Future<void> fetchData(bool reset) async {
    ArticleService articleService = ArticleService();

    if (reset) {
      currentPage = 1;
    }

    Map<String, dynamic> queryParams = {
      'page': currentPage,
      'per_page': 20,
    };

    print('nowFeed: $nowFeed');

    if (nowFeed.isNotEmpty && nowFeed['id'] != null) {
      queryParams['feed_id'] =
          nowFeed['id'].toString(); // Ensure feed_id is a string
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

          if (!reset && isMore) {
            currentPage++;
          }
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  void showFeedsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 顶部拖动条
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 8, bottom: 16),
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEEEEE),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // 标题
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                    child: Row(
                      children: [
                        const Text(
                          'My Subscriptions',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${filteredFeeds.length}',
                            style: const TextStyle(
                              color: Color(0xFF666666),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 源列表
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredFeeds.length,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          final isSelected = nowFeed.isEmpty;
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  nowFeed = {};
                                  articleList = [];
                                });
                                fetchData(true);
                                Navigator.pop(context);
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                margin: const EdgeInsets.only(bottom: 4),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: isSelected
                                      ? const Color(0xFFF5F5F5)
                                      : Colors.transparent,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      margin: const EdgeInsets.only(right: 12),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.05),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.article_outlined,
                                        size: 20,
                                        color: Color(0xFF666666),
                                      ),
                                    ),
                                    const Text(
                                      'All Articles',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF333333),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                        final feed = filteredFeeds[index];
                        print('Feed: $feed');
                        final isSelected = nowFeed['id'] == feed['id'];

                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                nowFeed = feed;
                                articleList = [];
                              });
                              fetchData(true);
                              Navigator.pop(context);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              margin: const EdgeInsets.only(bottom: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: isSelected
                                    ? const Color(0xFFE3F2FD)
                                    : const Color(0xFFFAFAFA),
                              ),
                              child: Row(
                                children: [
                                  // 源图标
                                  Container(
                                    width: 40,
                                    height: 40,
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: feed['logo'] != null
                                        ? Image.network(
                                            feed['logo'],
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return const Icon(
                                                Icons.rss_feed_rounded,
                                                size: 20,
                                                color: Color(0xFF666666),
                                              );
                                            },
                                          )
                                        : const Icon(
                                            Icons.rss_feed_rounded,
                                            size: 20,
                                            color: Color(0xFF666666),
                                          ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          feed['title'] ?? '',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.w500,
                                            color: const Color(0xFF333333),
                                          ),
                                        ),
                                        if (feed['total_articles_count'] !=
                                            null) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            '${feed['total_articles_count']} articles · ${_getTimeAgo(feed['last_successful_fetch_at'])}',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFF999999),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _getTimeAgo(String? dateStr) {
    if (dateStr == null) return 'never';

    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 30) {
        return '${(difference.inDays / 30).floor()} months ago';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} days ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hours ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minutes ago';
      } else {
        return 'just now';
      }
    } catch (e) {
      return 'unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF5F5F5); // 统一的浅灰色背景

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: showFeedsBottomSheet,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (nowFeed.isNotEmpty && nowFeed['logo'] != null) ...[
                    Container(
                      width: 26,
                      height: 26,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 13,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          nowFeed['logo'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                            Icons.rss_feed,
                            size: 16,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ),
                    ),
                  ] else
                    ...[],
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          nowFeed.isEmpty
                              ? "All Articles"
                              : nowFeed['title'] ?? "",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(4),
                    child: const Icon(
                      Icons.unfold_more_rounded,
                      color: Color(0xFF666666),
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        centerTitle: false,
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
            child: IconButton(
              icon: Icon(
                Icons.search_rounded,
                color: const Color(0xFF666666),
                size: 28,
              ),
              onPressed: () {
                // 这里添加搜索功能实现
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          color: backgroundColor,
          child: EasyRefresh(
            clipBehavior: Clip.none,
            controller: _controller,
            header: const ClassicHeader(),
            footer: const ClassicFooter(),
            onRefresh: () async {
              setState(() {
                isLoading = true;
              });
              await fetchData(true);
              setState(() {
                isLoading = false;
              });
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
                !isMore ? IndicatorResult.noMore : IndicatorResult.success,
              );
            },
            child: isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Loading articles...',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF999999),
                          ),
                        ),
                      ],
                    ),
                  )
                : articleList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.article_outlined,
                              size: 48,
                              color: Color(0xFFCCCCCC),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No articles found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF999999),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: articleList.length,
                        separatorBuilder: (context, index) {
                          return const SizedBox(height: 16);
                        },
                        itemBuilder: (context, index) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ArticleCard(
                              article: articleList[index],
                            ),
                          );
                        },
                      ),
          ),
        ),
      ),
    );
  }
}

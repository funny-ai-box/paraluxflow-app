import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import 'package:lazyreader/utils/http_util.dart';

import 'package:lazyreader/service/news_service.dart';

class NewsDetails extends StatefulWidget {
  final int detailId;
  const NewsDetails({Key? key, required this.detailId}) : super(key: key);

  @override
  _NewsDetailsState createState() => _NewsDetailsState();
}

class _NewsDetailsState extends State<NewsDetails> {
  Map<String, dynamic> detailsInfo = {};
  StreamController<String> summaryStreamController =
      StreamController.broadcast();
  bool isGeneratingSummary = false;

  bool showSummaryBubble = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  fetchData() async {
    NewsService newsService = NewsService();
    Map<String, dynamic> queryParams = {
      'article_id': widget.detailId,
    };
    try {
      var result = await newsService.getDetailsInfo(queryParams);

      print('details====${result['data']}');
      // rss的文章简介
      setState(() {
        detailsInfo = result['data'];
      });
    } catch (e) {
      print('111111222222: ${e}');
    }
  }

  String formatDate(String date) {
    try {
      DateTime dateTime = DateTime.parse(date);
      return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
    } catch (e) {
      print('Error formatting date: $e');
      return date;
    }
  }

  @override
  void dispose() {
    summaryStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDataLoaded = detailsInfo.isNotEmpty;
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.bookmark_add_outlined),
              onPressed: () {
                // Implement your favorite/bookmark functionality here
                print('Favorite button tapped');
              },
            ),
          ],
        ),
        body: SafeArea(
          child: isDataLoaded
              ? Stack(
                  children: [
                    detailsInfo['content_id'] != null
                        ? SingleChildScrollView(
                            child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  detailsInfo['title'],
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                if (detailsInfo['published_date'] != null)
                                  Text(
                                    '${detailsInfo['feed_title']} / ${formatDate(detailsInfo['published_date'])}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ))
                        : Center(
                            child: CircularProgressIndicator(),
                          ),
                    if (showSummaryBubble)
                      Positioned(
                        left: 20,
                        right: 20,
                        bottom: 60,
                        child: SummaryBubble(),
                      ),
                  ],
                )
              : Center(
                  child: CircularProgressIndicator(),
                ),
        ),
        floatingActionButton: showSummaryBubble
            ? null
            : FloatingActionButton(
                onPressed: () async {
                  if (showSummaryBubble) {
                    setState(() {
                      showSummaryBubble = false;
                    });
                  } else {
                    generateSummary();
                    setState(() {
                      showSummaryBubble = true;
                    });
                  }
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                foregroundColor: Colors.white,
                backgroundColor: Theme.of(context).primaryColor,
                child: Icon(Icons.assistant),
              ));
  }

  void generateSummary() async {
    isGeneratingSummary = true;

    try {
      // It's important to properly encode the content to ensure the URL is valid.
      var content_id = detailsInfo['content_id'];
      Stream<String> stream = HttpUtil.requestSSE(
          'v1/assistant/article_summarize_by_html?content_id=$content_id');
      String msg = "";
      stream.listen((event) {
        print(event);
        // Check if the event string starts with 'data: '
        if (event.startsWith('data: ')) {
          // Remove the 'data: ' prefix to get the JSON payload
          final jsonPayload = event.substring('data: '.length);

          try {
            // Decode the JSON payload
            final eventData = json.decode(jsonPayload);

            // Extract the 'message' field
            final String message = eventData['message'];
            msg = msg + message;

            if (msg.isNotEmpty) {
              summaryStreamController.add(msg);
            }
          } catch (e) {
            // Handle JSON parsing error
            print('Error parsing SSE JSON data: $e');
          }
        }
      }, onDone: () {
        isGeneratingSummary = false;
      }, onError: (error) {
        print('Error receiving SSE: $error');
        isGeneratingSummary = false;
      });
    } catch (e) {
      print('Error connecting to SSE: $e');
      isGeneratingSummary = false;
    }
  }

  Widget SummaryBubble() {
    return Stack(
      clipBehavior: Clip.none, // Allow overflow
      children: [
        Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(children: [
              Container(
                  child: SingleChildScrollView(
                      child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              StreamBuilder<String>(
                                stream: summaryStreamController.stream,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return SingleChildScrollView(
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              snapshot.data ?? "",
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors
                                                    .white, // 由于背景是黑色，需要将文本颜色改为白色
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  } else {
                                    return Center(
                                        child: CircularProgressIndicator());
                                  }
                                },
                              ),
                            ],
                          ))))
            ])),
        Positioned(
          top: -10, // 根据需要调整这些值
          left: -10,
          child: GestureDetector(
            onTap: () {
              setState(() {
                showSummaryBubble = false;
              });
            },
            child: Container(
              padding: EdgeInsets.all(6), // 设置为0，或根据需要调整
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor, // 红色背景
                shape: BoxShape.circle, // 圆形
              ),
              child: Icon(
                Icons.close,
                size: 16, // 减小图标尺寸
                color: Colors.white,
              ),
            ),
          ),
        )
      ],
    );
  }
}

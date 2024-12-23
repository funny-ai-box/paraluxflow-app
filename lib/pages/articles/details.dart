import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:lazyreader/components/CustomHtmlViewer.dart';

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
  bool isLoading = true; // Add loading state

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.bookmark_add_outlined,
              color: Theme.of(context).primaryColor,
            ),
            onPressed: () {
              print('Favorite button tapped');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'Loading article...',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
            : Stack(
                children: [
                  SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: 24,
                          right: 24,
                          top: 16,
                          bottom: MediaQuery.of(context).padding.bottom + 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title section with enhanced typography
                          Text(
                            detailsInfo['title'] ?? '',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              height: 1.4,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 16),

                          // Source and date with better visual hierarchy
                          Row(
                            children: [
                              Icon(
                                Icons.source_outlined,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              SizedBox(width: 8),
                              Text(
                                detailsInfo['feed_title'] ?? '',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(width: 16),
                              Icon(
                                Icons.access_time,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              SizedBox(width: 8),
                              Text(
                                formatDate(detailsInfo['published_date'] ?? ''),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 24),

                          // Article content with improved readability
                          if (detailsInfo['html_content'] != null)
                            CustomHtmlViewer(
                              htmlContent: detailsInfo['html_content'],
                              onLinkTap: (url, context, attributes) {
                                if (url != null) {
                                  // 处理链接点击
                                  print('Link tapped: $url');
                                }
                              },
                            ),

                          // Add bottom padding for floating button
                          SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                  if (showSummaryBubble)
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 60,
                      child: SummaryBubble(),
                    ),
                ],
              ),
      ),
      floatingActionButton: showSummaryBubble
          ? null
          : Container(
              margin: EdgeInsets.only(bottom: 16),
              child: FloatingActionButton.extended(
                onPressed: () {
                  if (!isGeneratingSummary) {
                    setState(() {
                      showSummaryBubble = true;
                    });
                    generateSummary();
                  }
                },
                icon: Icon(Icons.assistant),
                label: Text('Generate Summary'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
    );
  }

  Widget SummaryBubble() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.9),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: StreamBuilder<String>(
                  stream: summaryStreamController.stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                color: Colors.yellow,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'AI Summary',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Text(
                            snapshot.data ?? "",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              height: 1.6,
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Container(
                        height: 120,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Generating summary...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: -16,
          right: -16,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  showSummaryBubble = false;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.close,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  fetchData() async {
    setState(() {
      isLoading = true;
    });

    NewsService newsService = NewsService();
    Map<String, dynamic> queryParams = {
      'article_id': widget.detailId,
    };

    try {
      var result = await newsService.getDetailsInfo(queryParams);
      print(result['data']);
      setState(() {
        detailsInfo = result['data'];
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        isLoading = false;
      });
      // Show error message to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load article')),
      );
    }
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
}

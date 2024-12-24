import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lazyreader/components/CustomHtmlViewer.dart';
import 'package:lazyreader/service/article_service.dart';
import 'package:lazyreader/utils/http_util.dart';

class NewsDetails extends StatefulWidget {
  final int detailId;
  final bool isPreviewMode;

  const NewsDetails({
    Key? key,
    required this.detailId,
    this.isPreviewMode = false,
  }) : super(key: key);

  @override
  _NewsDetailsState createState() => _NewsDetailsState();
}

class _NewsDetailsState extends State<NewsDetails> {
  Map<String, dynamic> detailsInfo = {};
  StreamController<String> summaryStreamController =
      StreamController.broadcast();
  bool isLoading = true;
  bool showSummaryBubble = false;
  bool isGeneratingSummary = false;
  bool isFavorite = false;
  bool _showAppBarTitle = false;
  late ScrollController _scrollController;
  double _appBarElevation = 0;
  final GlobalKey _titleKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    fetchData();
  }

  void _onScroll() {
    final RenderBox? titleBox =
        _titleKey.currentContext?.findRenderObject() as RenderBox?;
    if (titleBox != null) {
      final titlePosition = titleBox.localToGlobal(Offset.zero);
      setState(() {
        _appBarElevation = _scrollController.offset > 0 ? 2 : 0;
        _showAppBarTitle = titlePosition.dy < 0; // 当标题滚动到不可见区域时显示在AppBar
      });
    }
  }

  @override
  void dispose() {
    summaryStreamController.close();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
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

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });

    ArticleService articleService = ArticleService();
    Map<String, dynamic> queryParams = {
      'article_id': widget.detailId,
    };

    try {
      var result = await articleService.getDetailsInfo(queryParams);
      setState(() {
        detailsInfo = result['data'];
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('加載文章失敗')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          if (isLoading)
            _buildLoadingView()
          else
            SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _buildArticleContent(),
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 80),
                ],
              ),
            ),
          if (showSummaryBubble) _buildSummaryBubbleOverlay(),
        ],
      ),
      bottomNavigationBar: !widget.isPreviewMode ? _buildBottomBar() : null,
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: _appBarElevation,
      backgroundColor: _showAppBarTitle ? Colors.white : Colors.transparent,
      iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: AnimatedOpacity(
        opacity: _showAppBarTitle ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Text(
          detailsInfo['title'] ?? '',
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      centerTitle: false,
      titleSpacing: 0,
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '正在加載文章...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category tag if available
          if (detailsInfo['category'] != null)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                detailsInfo['category'] ?? '',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

          // Title with enhanced typography
          Text(
            detailsInfo['title'] ?? '',
            key: _titleKey,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              height: 1.4,
              letterSpacing: -0.5,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 20),

          // Source and date with modern design
          Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(detailsInfo['feed_logo'] ?? ''),
                radius: 14,
              ),
              const SizedBox(width: 8),
              Text(
                detailsInfo['feed_title'] ?? '',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.access_time,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                formatDate(detailsInfo['published_date'] ?? ''),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Article content with enhanced typography
          if (detailsInfo['html_content'] != null)
            CustomHtmlViewer(
              htmlContent: detailsInfo['html_content'],
              onLinkTap: (url, context, attributes) {
                if (url != null) {
                  _handleLinkTap(url);
                }
              },
            ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -1),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 65,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildModernBottomBarButton(
                icon: Icons.bookmark_outline_rounded,
                activeIcon: Icons.bookmark_rounded,
                isActive: isFavorite,
                label: '收藏',
                onTap: _toggleFavorite,
              ),
              _buildModernBottomBarButton(
                icon: Icons.share_rounded,
                label: '分享',
                onTap: _shareArticle,
              ),
              _buildModernBottomBarButton(
                icon: Icons.launch_rounded,
                label: '原文',
                onTap: _openOriginalArticle,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernBottomBarButton({
    required IconData icon,
    IconData? activeIcon,
    bool isActive = false,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 90,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isActive ? (activeIcon ?? icon) : icon,
                color: isActive
                    ? Theme.of(context).primaryColor
                    : Colors.grey[600],
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isActive
                      ? Theme.of(context).primaryColor
                      : Colors.grey[600],
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget? _buildFloatingActionButton() {
    if (widget.isPreviewMode || showSummaryBubble) return null;

    return Container(
      margin: const EdgeInsets.only(bottom: 80),
      child: FloatingActionButton(
        elevation: 2,
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () {
          if (!isGeneratingSummary) {
            setState(() => showSummaryBubble = true);
            generateSummary();
          }
        },
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: isGeneratingSummary
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.assistant_rounded, size: 26),
        ),
      ),
    );
  }

  Widget _buildSummaryBubbleOverlay() {
    return Positioned(
      left: 20,
      right: 20,
      bottom: MediaQuery.of(context).padding.bottom + 80,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.black.withOpacity(0.95),
              Colors.black.withOpacity(0.9),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.yellow.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: Colors.yellow,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'AI 摘要',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  StreamBuilder<String>(
                    stream: summaryStreamController.stream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Text(
                          snapshot.data ?? "",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            height: 1.6,
                            letterSpacing: 0.3,
                          ),
                        );
                      }
                      return const _BuildSummaryLoadingIndicator();
                    },
                  ),
                ],
              ),
            ),
            Positioned(
              top: -20,
              right: -20,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => setState(() => showSummaryBubble = false),
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> generateSummary() async {
    isGeneratingSummary = true;

    try {
      var content_id = detailsInfo['content_id'];
      Stream<String> stream = HttpUtil.requestSSE(
        'v1/assistant/article_summarize_by_html?content_id=$content_id',
      );

      String msg = "";
      await for (var event in stream) {
        if (event.startsWith('data: ')) {
          final jsonPayload = event.substring('data: '.length);

          try {
            final eventData = json.decode(jsonPayload);
            final String message = eventData['message'];
            msg += message;

            if (msg.isNotEmpty) {
              summaryStreamController.add(msg);
            }
          } catch (e) {
            print('Error parsing SSE JSON data: $e');
          }
        }
      }
    } catch (e) {
      print('Error connecting to SSE: $e');
    } finally {
      isGeneratingSummary = false;
    }
  }

  void _toggleFavorite() {
    setState(() {
      isFavorite = !isFavorite;
    });
    // TODO: 實現收藏邏輯
  }

  void _shareArticle() {
    // TODO: 實現分享邏輯
    print('Share article');
  }

  void _openOriginalArticle() {
    if (detailsInfo['link'] != null) {
      // TODO: 實現打開原文鏈接邏輯
      print('Open original article: ${detailsInfo['link']}');
    }
  }

  void _handleLinkTap(String url) {
    // TODO: 實現鏈接點擊邏輯
    print('Link tapped: $url');
  }
}

// 如果需要, 你可以添加一個擴展來處理日期格式化
extension DateTimeFormatExtension on DateTime {
  String toFormattedString() {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inMinutes < 1) {
      return '剛剛';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分鐘前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小時前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return DateFormat('yyyy-MM-dd HH:mm').format(this);
    }
  }
}

class _BuildSummaryLoadingIndicator extends StatelessWidget {
  const _BuildSummaryLoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 2,
            ),
            SizedBox(height: 16),
            Text(
              '正在生成摘要...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

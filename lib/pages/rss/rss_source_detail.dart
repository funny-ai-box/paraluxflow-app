import 'package:flutter/material.dart';
import 'package:lazyreader/service/rss_service.dart';
import 'package:timeago/timeago.dart' as timeago;

class RssSourceDetailPage extends StatefulWidget {
  final Map<String, dynamic> source;

  RssSourceDetailPage({required this.source});

  @override
  _RssSourceDetailPageState createState() => _RssSourceDetailPageState();
}

class _RssSourceDetailPageState extends State<RssSourceDetailPage> {
  final RssService _rssService = RssService();
  bool isSubscribed = false;
  List<Map<String, dynamic>> articles = [];
  bool isLoading = true;
  Map<String, dynamic> sourceDetail = {};
  String errorMessage = '';
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    // 初始化中文时间显示
    timeago.setLocaleMessages('zh', timeago.ZhMessages());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final feedId = widget.source['id'];

      final detailResponse = await _rssService.getFeedDetail(feedId);
      final articlesResponse = await _rssService.getFeedPreviewArticles(feedId);

      List<Map<String, dynamic>> articlesList = [];
      if (articlesResponse != null && articlesResponse['items'] != null) {
        articlesList = (articlesResponse['items'] as List)
            .map((item) => item as Map<String, dynamic>)
            .toList();
      }

      if (mounted) {
        setState(() {
          sourceDetail = detailResponse ?? {};
          articles = articlesList;
          isSubscribed = false;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = '加载数据失败，请稍后重试';
          isLoading = false;
        });
      }
      print('Error loading data: $e');
    }
  }

  Future<void> _toggleSubscription() async {
    try {
      final feedId = widget.source['id'];
      setState(() {
        isSubscribed = !isSubscribed;
      });

      // TODO: Implement actual subscription API call
      // await _rssService.toggleSubscription(feedId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isSubscribed ? Icons.check_circle : Icons.info,
                color: Colors.white,
              ),
              SizedBox(width: 8),
              Text(isSubscribed ? '订阅成功' : '已取消订阅'),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: isSubscribed ? Colors.green : Colors.grey[700],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: Duration(seconds: 2),
          margin: EdgeInsets.all(16),
        ),
      );
    } catch (e) {
      setState(() {
        isSubscribed = !isSubscribed;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 8),
              Text('操作失败，请稍后重试'),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
          margin: EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  String _getTimeAgo(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      return timeago.format(date, locale: 'zh');
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '订阅源详情',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        actions: [
          if (errorMessage.isNotEmpty)
            IconButton(
              icon: Icon(Icons.refresh_rounded, color: Colors.black87),
              onPressed: _loadInitialData,
            ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              )
            : errorMessage.isNotEmpty
                ? _buildErrorState()
                : _buildContent(),
      ),
      floatingActionButton:
          !isLoading && errorMessage.isEmpty ? _buildSubscribeButton() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            errorMessage,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadInitialData,
            icon: Icon(Icons.refresh_rounded),
            label: Text('重试'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue,
              padding: EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _loadInitialData,
      child: CustomScrollView(
        controller: _scrollController,
        physics: AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _buildSourceInfo(),
          ),
          SliverPadding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 24,
              bottom: 12,
            ),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '最新文章',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildArticlesList(),
          SliverToBoxAdapter(
            child: SizedBox(height: 100), // Bottom padding for FAB
          ),
        ],
      ),
    );
  }

  Widget _buildSourceInfo() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSourceLogo(),
          SizedBox(height: 20),
          Text(
            sourceDetail['title'] ?? widget.source['title'] ?? '',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          if (sourceDetail['description']?.isNotEmpty ?? false) ...[
            SizedBox(height: 12),
            Text(
              sourceDetail['description'] ?? '',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          SizedBox(height: 20),
          _buildSourceStats(),
        ],
      ),
    );
  }

  Widget _buildSourceLogo() {
    if (sourceDetail['logo'] != null && sourceDetail['logo'].isNotEmpty) {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: Image.network(
            sourceDetail['logo'],
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildLogoFallback(),
          ),
        ),
      );
    }
    return _buildLogoFallback();
  }

  Widget _buildLogoFallback() {
    String logoText =
        (sourceDetail['title']?.substring(0, 2) ?? 'RS').toUpperCase();
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade300,
            Colors.blue.shade500,
          ],
        ),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          logoText,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSourceStats() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.article_outlined,
            size: 18,
            color: Colors.blue,
          ),
          SizedBox(width: 8),
          Text(
            '${sourceDetail['total_articles_count'] ?? 0} 篇文章',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticlesList() {
    if (articles.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.article_outlined,
                size: 48,
                color: Colors.grey[400],
              ),
              SizedBox(height: 16),
              Text(
                '暂无文章',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final article = articles[index];
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  if (article['link']?.isNotEmpty ?? false) {
                    // TODO: Navigate to article detail
                    print('Navigate to: ${article['link']}');
                  }
                },
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (article['thumbnail_url'] != null) ...[
                        _buildArticleThumbnail(article['thumbnail_url']),
                        SizedBox(width: 16),
                      ],
                      Expanded(
                        child: _buildArticleContent(article),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        childCount: articles.length,
      ),
    );
  }

  Widget _buildArticleThumbnail(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        url,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.image_not_supported_outlined,
            color: Colors.grey[400],
            size: 32,
          ),
        ),
      ),
    );
  }

  Widget _buildArticleContent(Map<String, dynamic> article) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          article['title'] ?? '',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            height: 1.4,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (article['summary']?.isNotEmpty ?? false) ...[
          SizedBox(height: 8),
          Text(
            article['summary'],
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        SizedBox(height: 12),
        Row(
          children: [
            Icon(
              Icons.access_time_rounded,
              size: 14,
              color: Colors.grey[400],
            ),
            SizedBox(width: 4),
            Text(
              _getTimeAgo(article['published_date']),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubscribeButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: (isSubscribed ? Colors.grey[300]! : Colors.blue)
                  .withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _toggleSubscription,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(isSubscribed ? Icons.check : Icons.add),
              SizedBox(width: 8),
              Text(isSubscribed ? '已订阅' : '订阅'),
            ],
          ),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: isSubscribed ? Colors.grey[400] : Colors.blue,
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 0,
            textStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

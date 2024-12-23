import 'package:flutter/material.dart';
import 'package:lazyreader/components/article_card.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isSubscribed ? Icons.check_circle : Icons.info,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Text(isSubscribed ? '订阅成功' : '已取消订阅'),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor:
              isSubscribed ? Colors.green.shade600 : Colors.grey[700],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(16),
          elevation: 4,
          animation: CurvedAnimation(
            parent: const AlwaysStoppedAnimation(1),
            curve: Curves.easeOutCirc,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        isSubscribed = !isSubscribed;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 8),
              Text('操作失败，请稍后重试'),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade600,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
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
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 3,
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

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
        onPressed: () => Navigator.of(context).pop(),
        tooltip: '返回',
      ),
      title: const Text(
        '订阅源详情',
        style: TextStyle(
          color: Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      actions: [
        if (errorMessage.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.black87),
            onPressed: _loadInitialData,
            tooltip: '重新加载',
          ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 56,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            errorMessage,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _loadInitialData,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('重新加载'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 2,
              shadowColor: Colors.blue.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _loadInitialData,
      color: Colors.blue,
      backgroundColor: Colors.white,
      strokeWidth: 3,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(
            child: _buildSourceInfo(),
          ),
          SliverPadding(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 32,
              bottom: 16,
            ),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade600,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    '最新文章',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildArticlesList(),
          SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceInfo() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSourceLogo(),
          const SizedBox(height: 24),
          Text(
            sourceDetail['title'] ?? widget.source['title'] ?? '',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              letterSpacing: 0.5,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
          if (sourceDetail['description']?.isNotEmpty ?? false) ...[
            const SizedBox(height: 16),
            Text(
              sourceDetail['description'] ?? '',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.6,
                letterSpacing: 0.3,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 24),
          _buildSourceStats(),
        ],
      ),
    );
  }

  Widget _buildSourceLogo() {
    return Hero(
      tag: 'source_logo_${widget.source['id']}',
      child: Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(48),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: sourceDetail['logo'] != null && sourceDetail['logo'].isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(48),
                child: Image.network(
                  sourceDetail['logo'],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildLogoFallback(),
                ),
              )
            : _buildLogoFallback(),
      ),
    );
  }

  Widget _buildLogoFallback() {
    String logoText =
        (sourceDetail['title']?.substring(0, 2) ?? 'RS').toUpperCase();
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade400,
            Colors.blue.shade600,
          ],
        ),
        borderRadius: BorderRadius.circular(48),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          logoText,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildSourceStats() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.article_outlined,
            size: 20,
            color: Colors.blue.shade600,
          ),
          const SizedBox(width: 10),
          Text(
            '${sourceDetail['total_articles_count'] ?? 0} 篇文章',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade600,
              letterSpacing: 0.5,
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
                size: 56,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 20),
              Text(
                '暂无文章',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
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
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: ArticleCard(
              article: article,
            ),
          );
        },
        childCount: articles.length,
      ),
    );
  }

  Widget _buildSubscribeButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: (isSubscribed ? Colors.grey[400]! : Colors.blue)
                  .withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _toggleSubscription,
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor:
                isSubscribed ? Colors.grey[400] : Colors.blue.shade600,
            padding: const EdgeInsets.symmetric(horizontal: 32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            elevation: 0,
            textStyle: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSubscribed ? Icons.check : Icons.add,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(isSubscribed ? '已订阅' : '订阅'),
            ],
          ),
        ),
      ),
    );
  }
}

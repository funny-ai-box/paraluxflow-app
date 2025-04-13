import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:lazyreader/models/Article.dart';
import 'package:lazyreader/models/Subscription.dart';
import 'package:lazyreader/service/article_service.dart';
import 'package:lazyreader/service/subscription_service.dart';
import 'package:lazyreader/widgets/article_card.dart';

// 创建文章列表提供者
final articlesProvider = FutureProvider.autoDispose<List<Article>>((ref) async {
  // 这里我们需要获取所有订阅的文章，因此先获取所有订阅
  final subscriptionService = SubscriptionService();
  final subscriptionData = await subscriptionService.getSubscriptionsList();
  final List<Subscription> subscriptions = subscriptionData['subscriptions'];
  
  if (subscriptions.isEmpty) {
    return [];
  }
  
  // 获取第一个订阅的文章作为示例
  // 实际应用中，您可能想要合并所有订阅的文章或实现一个更复杂的逻辑
  final articleService = ArticleService();
  final feedArticlesData = await articleService.getFeedArticles(
    feedId: subscriptions.first.feedId,
    page: 1,
    perPage: 20,
  );
  
  return feedArticlesData['articles'];
});

class ArticlesPage extends ConsumerWidget {
  const ArticlesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articlesAsyncValue = ref.watch(articlesProvider);
    
    return Scaffold(
      body: articlesAsyncValue.when(
        data: (articles) {
          if (articles.isEmpty) {
            return _buildEmptyState(context);
          }
          
          return EasyRefresh(
            onRefresh: () async {
              // 刷新数据
              ref.refresh(articlesProvider);
            },
            child: ListView.builder(
              itemCount: articles.length,
              padding: EdgeInsets.only(top: 8, bottom: 16),
              itemBuilder: (context, index) {
                final article = articles[index];
                
                return ArticleCard(
                  title: article.title,
                  feedTitle: article.feedTitle,
                  feedLogo: article.feedLogo,
                  summary: article.summary,
                  thumbnailUrl: article.thumbnailUrl,
                  publishedDate: article.publishedDate,
                  isRead: article.isRead,
                  isFavorite: article.isFavorite,
                  onTap: () {
                    // 导航到文章详情页面
                    _navigateToArticleDetail(context, article);
                  },
                  onFavoriteTap: () {
                    // 切换收藏状态
                    _toggleFavorite(context, article);
                  },
                );
              },
            ),
          );
        },
        loading: () => Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text('加载失败: $error'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 标记全部已读
          _markAllAsRead(context);
        },
        child: Icon(Icons.done_all),
        tooltip: '标记全部已读',
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.article_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            '没有文章',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            '您可以添加一些订阅源来开始阅读',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // 导航到添加订阅页面
            },
            icon: Icon(Icons.add),
            label: Text('添加订阅源'),
          ),
        ],
      ),
    );
  }

  void _navigateToArticleDetail(BuildContext context, Article article) {
    // TODO: 实现导航到文章详情页面
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('查看文章: ${article.title}')),
    );
  }

  void _toggleFavorite(BuildContext context, Article article) async {
    try {
      final articleService = ArticleService();
      final result = await articleService.toggleFavorite(article.id);
      
      // 显示结果
      final message = result['is_favorite'] ? '已添加到收藏' : '已从收藏中移除';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('操作失败: $e')),
      );
    }
  }

  void _markAllAsRead(BuildContext context) async {
    try {
      final articleService = ArticleService();
      final result = await articleService.markAllRead();
      
      // 显示结果
      final count = result['count'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已将 $count 篇文章标记为已读')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('操作失败: $e')),
      );
    }
  }
}
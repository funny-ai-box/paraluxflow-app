import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:lazyreader/models/Article.dart';
import 'package:lazyreader/service/article_service.dart';
import 'package:lazyreader/widgets/article_card.dart';

// 创建收藏文章列表提供者
final favoritesProvider = FutureProvider.autoDispose<List<Article>>((ref) async {
  final articleService = ArticleService();
  return await articleService.getUserFavorites(limit: 50);
});

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsyncValue = ref.watch(favoritesProvider);
    
    return Scaffold(
      body: favoritesAsyncValue.when(
        data: (articles) {
          if (articles.isEmpty) {
            return _buildEmptyState(context);
          }
          
          return EasyRefresh(
            onRefresh: () async {
              // 刷新数据
              ref.refresh(favoritesProvider);
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
                  isFavorite: true, // 在收藏页面中，所有文章都是收藏的
                  onTap: () {
                    // 导航到文章详情页面
                    _navigateToArticleDetail(context, article);
                  },
                  onFavoriteTap: () {
                    // 从收藏中移除
                    _removeFromFavorites(context, ref, article);
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
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.star_border,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            '没有收藏文章',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            '浏览文章时，点击星形图标来收藏您喜欢的文章',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // 导航到文章列表页面
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => Scaffold(
                    body: Center(
                      child: Text('文章列表页面'),
                    ),
                  ),
                ),
              );
            },
            icon: Icon(Icons.article_outlined),
            label: Text('浏览文章'),
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

  void _removeFromFavorites(BuildContext context, WidgetRef ref, Article article) async {
    try {
      final articleService = ArticleService();
      await articleService.toggleFavorite(article.id);
      
      // 刷新收藏列表
      ref.refresh(favoritesProvider);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已从收藏中移除')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('操作失败: $e')),
      );
    }
  }
}
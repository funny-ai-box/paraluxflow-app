import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lazyreader/models/Article.dart';
import 'package:lazyreader/models/Subscription.dart';
import 'package:lazyreader/service/article_service.dart';
import 'package:lazyreader/service/subscription_service.dart';

// 全局计数器：未读文章数量
final unreadCountProvider = StateProvider<int>((ref) => 0);

// 用户订阅提供者
final userSubscriptionsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final subscriptionService = SubscriptionService();
  return await subscriptionService.getSubscriptionsList();
});

// 用户阅读历史提供者
final userHistoryProvider = FutureProvider.autoDispose<List<Article>>((ref) async {
  final articleService = ArticleService();
  return await articleService.getUserHistory(limit: 20);
});

// 全局通知类，用于在不同页面间传递事件
class AppNotifier extends ChangeNotifier {
  // 当前阅读的文章ID
  int? _currentArticleId;
  int? get currentArticleId => _currentArticleId;
  
  // 设置当前阅读的文章ID
  void setCurrentArticleId(int? id) {
    _currentArticleId = id;
    notifyListeners();
  }
  
  // 更新文章阅读状态
  void updateArticleReadStatus(int articleId, bool isRead) {
    // 实际应用中，这里可能需要更新本地缓存或发送网络请求
    notifyListeners();
  }
  
  // 更新文章收藏状态
  void updateArticleFavoriteStatus(int articleId, bool isFavorite) {
    // 实际应用中，这里可能需要更新本地缓存或发送网络请求
    notifyListeners();
  }
}

// 创建全局通知提供者
final appNotifierProvider = ChangeNotifierProvider((ref) => AppNotifier());

// 全局主题设置提供者
final themeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

// 全局语言设置提供者
final localeProvider = StateProvider<Locale>((ref) => Locale('zh', 'CN'));
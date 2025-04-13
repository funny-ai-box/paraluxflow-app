import 'package:lazyreader/models/Feed.dart';
import 'package:lazyreader/utils/http_util.dart';

class FeedService {
  // 获取发现页面的Feed列表
  Future<Map<String, dynamic>> discoverFeeds({
    int page = 1,
    int perPage = 20,
    String? title,
    int? categoryId,
  }) async {
    final path = '/api/client/v1/feed/discover';
    final parameters = <String, dynamic>{
      'page': page,
      'per_page': perPage,
   
    };

    if (title != null && title.isNotEmpty) {
      parameters['title'] = title ;
    }

    if (categoryId != null) {
      parameters['category_id'] = categoryId;
    }

    try {
      final response = await HttpUtil.request(
        path,
        method: 'GET',
        parameters: parameters,
      );

      final List<Feed> feeds = (response['data']['list'] as List)
          .map((item) => Feed.fromJson(item))
          .toList();

      return {
        'feeds': feeds,
        'total': response['data']['total'],
        'pages': response['data']['pages'],
        'current_page': response['data']['current_page'],
        'per_page': response['data']['per_page'],
      };
    } catch (e) {
      print('获取发现Feed列表失败: $e');
      throw Exception('获取Feed列表失败');
    }
  }

  // 获取Feed详情
  Future<Map<String, dynamic>> getFeedDetail(String feedId) async {
    final path = '/api/client/v1/feed/detail';
    final parameters = {
      'feed_id': feedId,
    };

    try {
      final response = await HttpUtil.request(
        path,
        method: 'GET',
        parameters: parameters,
      );

      final Feed feed = Feed.fromJson(response['data']['feed']);
      final bool isSubscribed = response['data']['is_subscribed'];
      final dynamic subscription = response['data']['subscription'];

      return {
        'feed': feed,
        'is_subscribed': isSubscribed,
        'subscription': subscription,
      };
    } catch (e) {
      print('获取Feed详情失败: $e');
      throw Exception('获取Feed详情失败');
    }
  }

  // 获取所有Feed分类
  Future<List<FeedCategory>> getFeedCategories() async {
    final path = '/api/client/v1/feed/categories';

    try {
      final response = await HttpUtil.request(
        path,
        method: 'GET',
      );

      return (response['data'] as List)
          .map((item) => FeedCategory.fromJson(item))
          .toList();
    } catch (e) {
      print('获取Feed分类失败: $e');
      throw Exception('获取Feed分类失败');
    }
  }

  // 通过URL发现Feed
  Future<Map<String, dynamic>> discoverFeedByUrl(String url) async {
    final path = '/api/client/v1/feed/discover_by_url';
    final parameters = {
      'url': url,
    };

    try {
      final response = await HttpUtil.request(
        path,
        method: 'POST',
        parameters: parameters,
      );

      final List<dynamic> discoveredFeeds = response['data']['discovered_feeds'];
      final String websiteUrl = response['data']['website_url'];
      final String websiteTitle = response['data']['website_title'];

      return {
        'discovered_feeds': discoveredFeeds,
        'website_url': websiteUrl,
        'website_title': websiteTitle,
      };
    } catch (e) {
      print('通过URL发现Feed失败: $e');
      throw Exception('通过URL发现Feed失败');
    }
  }

  // 请求添加新Feed
  Future<Map<String, dynamic>> requestAddFeed({
    required String url,
    required String title,
    String? description,
  }) async {
    final path = '/api/client/v1/feed/request_add';
    final parameters = {
      'url': url,
      'title': title,
    };

    if (description != null) {
      parameters['description'] = description;
    }

    try {
      final response = await HttpUtil.request(
        path,
        method: 'POST',
        parameters: parameters,
      );

      final String status = response['data']['status'];
      
      if (status == 'exists') {
        final Feed feed = Feed.fromJson(response['data']['feed']);
        return {
          'status': status,
          'feed': feed,
        };
      } else {
        return {
          'status': status,
          'request_info': response['data']['request_info'],
        };
      }
    } catch (e) {
      print('请求添加Feed失败: $e');
      throw Exception('请求添加Feed失败');
    }
  }
}
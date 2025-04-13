import 'package:lazyreader/models/Feed.dart';
import 'package:lazyreader/models/Subscription.dart';
import 'package:lazyreader/utils/http_util.dart';

class SubscriptionService {
  // 获取用户的所有订阅
  Future<Map<String, dynamic>> getSubscriptionsList() async {
    final path = '/api/client/v1/subscription/list';

    try {
      final response = await HttpUtil.request(
        path,
        method: 'GET',
      );

      final data = response['data'];
      
      // 解析订阅列表
      final List<Subscription> subscriptions = (data['subscriptions'] as List)
          .map((item) => Subscription.fromJson(item))
          .toList();

      // 解析分组列表
      final List<SubscriptionGroup> groups = (data['groups'] as List)
          .map((item) => SubscriptionGroup.fromJson(item))
          .toList();

      // 解析Feed字典
      final Map<String, Feed> feeds = {};
      (data['feeds'] as Map).forEach((key, value) {
        feeds[key] = Feed.fromJson(value);
      });

      // 解析分组后的订阅
      final Map<String, List<Subscription>> groupedSubscriptions = {};
      (data['grouped_subscriptions'] as Map).forEach((key, value) {
        groupedSubscriptions[key] = (value as List)
            .map((item) {
              final feedId = item['feed_id'];
              return Subscription.fromJson(item, feed: feeds[feedId]);
            })
            .toList();
      });

      return {
        'subscriptions': subscriptions,
        'groups': groups,
        'feeds': feeds,
        'grouped_subscriptions': groupedSubscriptions,
      };
    } catch (e) {
      print('获取订阅列表失败: $e');
      throw Exception('获取订阅列表失败');
    }
  }

  // 添加订阅
  Future<Map<String, dynamic>> addSubscription({
    required String feedId,
    int? groupId,
  }) async {
    final path = '/api/client/v1/subscription/add';
    final parameters = {
      'feed_id': feedId,
    };

    if (groupId != null) {
      parameters['group_id'] = groupId as String;
    }

    try {
      final response = await HttpUtil.request(
        path,
        method: 'POST',
        parameters: parameters,
      );

      final Subscription subscription = Subscription.fromJson(response['data']['subscription']);
      final Feed feed = Feed.fromJson(response['data']['feed']);

      return {
        'subscription': subscription,
        'feed': feed,
      };
    } catch (e) {
      print('添加订阅失败: $e');
      throw Exception('添加订阅失败');
    }
  }

  // 更新订阅
  Future<Map<String, dynamic>> updateSubscription({
    required String feedId,
    int? groupId,
    String? customTitle,
    bool? isFavorite,
  }) async {
    final path = '/api/client/v1/subscription/update';
    final parameters = {
      'feed_id': feedId,
    };

    if (groupId != null) parameters['group_id'] = groupId as String;
    if (customTitle != null) parameters['custom_title'] = customTitle;
    if (isFavorite != null) parameters['is_favorite'] = isFavorite as String;

    try {
      final response = await HttpUtil.request(
        path,
        method: 'POST',
        parameters: parameters,
      );

      final Subscription subscription = Subscription.fromJson(response['data']['subscription']);
      final Feed feed = Feed.fromJson(response['data']['feed']);

      return {
        'subscription': subscription,
        'feed': feed,
      };
    } catch (e) {
      print('更新订阅失败: $e');
      throw Exception('更新订阅失败');
    }
  }

  // 移除订阅
  Future<bool> removeSubscription(String feedId) async {
    final path = '/api/client/v1/subscription/remove';
    final parameters = {
      'feed_id': feedId,
    };

    try {
      final response = await HttpUtil.request(
        path,
        method: 'POST',
        parameters: parameters,
      );

      return response['data']['success'];
    } catch (e) {
      print('移除订阅失败: $e');
      throw Exception('移除订阅失败');
    }
  }

  // 获取用户的分组列表
  Future<List<SubscriptionGroup>> getSubscriptionGroups() async {
    final path = '/api/client/v1/subscription/groups';

    try {
      final response = await HttpUtil.request(
        path,
        method: 'GET',
      );

      return (response['data'] as List)
          .map((item) => SubscriptionGroup.fromJson(item))
          .toList();
    } catch (e) {
      print('获取分组列表失败: $e');
      throw Exception('获取分组列表失败');
    }
  }

  // 添加分组
  Future<SubscriptionGroup> addSubscriptionGroup(String name) async {
    final path = '/api/client/v1/subscription/group/add';
    final parameters = {
      'name': name,
    };

    try {
      final response = await HttpUtil.request(
        path,
        method: 'POST',
        parameters: parameters,
      );

      return SubscriptionGroup.fromJson(response['data']);
    } catch (e) {
      print('添加分组失败: $e');
      throw Exception('添加分组失败');
    }
  }

  // 更新分组
  Future<SubscriptionGroup> updateSubscriptionGroup({
    required int groupId,
    required String name,
  }) async {
    final path = '/api/client/v1/subscription/group/update';
    final parameters = {
      'group_id': groupId,
      'name': name,
    };

    try {
      final response = await HttpUtil.request(
        path,
        method: 'POST',
        parameters: parameters,
      );

      return SubscriptionGroup.fromJson(response['data']);
    } catch (e) {
      print('更新分组失败: $e');
      throw Exception('更新分组失败');
    }
  }

  // 删除分组
  Future<bool> deleteSubscriptionGroup(int groupId) async {
    final path = '/api/client/v1/subscription/group/delete';
    final parameters = {
      'group_id': groupId,
    };

    try {
      final response = await HttpUtil.request(
        path,
        method: 'POST',
        parameters: parameters,
      );

      return response['data']['success'];
    } catch (e) {
      print('删除分组失败: $e');
      throw Exception('删除分组失败');
    }
  }
}
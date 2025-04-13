import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lazyreader/models/Subscription.dart';
import 'package:lazyreader/service/subscription_service.dart';
import 'package:lazyreader/widgets/feed_card.dart';

// 创建订阅列表提供者
final subscriptionsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final subscriptionService = SubscriptionService();
  return await subscriptionService.getSubscriptionsList();
});

class SourcesPage extends ConsumerStatefulWidget {
  const SourcesPage({Key? key}) : super(key: key);

  @override
  _SourcesPageState createState() => _SourcesPageState();
}

class _SourcesPageState extends ConsumerState<SourcesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(() {
      // 当搜索文本变化时，可以在这里实现搜索逻辑
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isSearching
          ? _buildSearchAppBar()
          : PreferredSize(
              preferredSize: Size.fromHeight(kToolbarHeight),
              child: AppBar(
                automaticallyImplyLeading: false,
                title: TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(text: '全部'),
                    Tab(text: '分组'),
                  ],
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Theme.of(context).primaryColor,
                ),
                actions: [
                  IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      setState(() {
                        _isSearching = true;
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      _showAddSourceBottomSheet(context);
                    },
                  ),
                ],
              ),
            ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddSourceBottomSheet(context);
        },
        child: Icon(Icons.add),
        tooltip: '添加订阅源',
      ),
    );
  }

  AppBar _buildSearchAppBar() {
    return AppBar(
      title: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '搜索订阅源...',
          border: InputBorder.none,
        ),
        autofocus: true,
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          setState(() {
            _isSearching = false;
            _searchController.clear();
          });
        },
      ),
      actions: [
        if (_searchController.text.isNotEmpty)
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
            },
          ),
      ],
    );
  }

  Widget _buildBody() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildAllSourcesTab(),
        _buildGroupedSourcesTab(),
      ],
    );
  }

  Widget _buildAllSourcesTab() {
    final subscriptionsAsync = ref.watch(subscriptionsProvider);
    
    return subscriptionsAsync.when(
      data: (data) {
        final List<Subscription> subscriptions = data['subscriptions'];
        
        if (subscriptions.isEmpty) {
          return _buildEmptyState();
        }
        
        // 如果正在搜索，过滤订阅列表
        List<Subscription> filteredSubscriptions = subscriptions;
        if (_isSearching && _searchController.text.isNotEmpty) {
          final searchText = _searchController.text.toLowerCase();
          filteredSubscriptions = subscriptions.where((subscription) {
            return subscription.displayTitle.toLowerCase().contains(searchText);
          }).toList();
        }
        
        return ListView.builder(
          itemCount: filteredSubscriptions.length,
          padding: EdgeInsets.only(bottom: 80), // 为悬浮按钮留出空间
          itemBuilder: (context, index) {
            final subscription = filteredSubscriptions[index];
            
            return FeedCard(
              subscription: subscription,
              onTap: () {
                // 导航到订阅源的文章列表
                _navigateToFeedArticles(context, subscription);
              },
              onFavoriteTap: () {
                // 切换订阅源的收藏状态
                _toggleFeedFavorite(context, subscription);
              },
              onSettingsTap: () {
                // 显示订阅源的设置菜单
                _showFeedSettingsMenu(context, subscription);
              },
            );
          },
        );
      },
      loading: () => Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Text('加载失败: $error'),
      ),
    );
  }

  Widget _buildGroupedSourcesTab() {
    final subscriptionsAsync = ref.watch(subscriptionsProvider);
    
    return subscriptionsAsync.when(
      data: (data) {
        final Map<String, List<Subscription>> groupedSubscriptions = data['grouped_subscriptions'];
        final List<SubscriptionGroup> groups = data['groups'];
        
        if (groupedSubscriptions.isEmpty) {
          return _buildEmptyState();
        }
        
        // 将分组按照顺序排列
        final List<String> sortedGroupNames = [];
        for (var group in groups) {
          sortedGroupNames.add(group.name);
        }
        // 确保"无分组"在最后
        if (groupedSubscriptions.containsKey('无分组')) {
          sortedGroupNames.remove('无分组');
          sortedGroupNames.add('无分组');
        }
        
        return ListView.builder(
          itemCount: sortedGroupNames.length,
          padding: EdgeInsets.only(bottom: 80), // 为悬浮按钮留出空间
          itemBuilder: (context, groupIndex) {
            final groupName = sortedGroupNames[groupIndex];
            final groupSubscriptions = groupedSubscriptions[groupName] ?? [];
            
            // 如果正在搜索，过滤这个分组的订阅列表
            List<Subscription> filteredSubscriptions = groupSubscriptions;
            if (_isSearching && _searchController.text.isNotEmpty) {
              final searchText = _searchController.text.toLowerCase();
              filteredSubscriptions = groupSubscriptions.where((subscription) {
                return subscription.displayTitle.toLowerCase().contains(searchText);
              }).toList();
              
              // 如果过滤后没有订阅，跳过这个分组
              if (filteredSubscriptions.isEmpty) {
                return SizedBox.shrink();
              }
            }
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        groupName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      Text(
                        '${filteredSubscriptions.length}个订阅',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                ...filteredSubscriptions.map((subscription) {
                  return FeedCard(
                    subscription: subscription,
                    onTap: () {
                      // 导航到订阅源的文章列表
                      _navigateToFeedArticles(context, subscription);
                    },
                    onFavoriteTap: () {
                      // 切换订阅源的收藏状态
                      _toggleFeedFavorite(context, subscription);
                    },
                    onSettingsTap: () {
                      // 显示订阅源的设置菜单
                      _showFeedSettingsMenu(context, subscription);
                    },
                  );
                }).toList(),
              ],
            );
          },
        );
      },
      loading: () => Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Text('加载失败: $error'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.rss_feed,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            '没有订阅源',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            '点击下方按钮添加您的第一个订阅源',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _showAddSourceBottomSheet(context);
            },
            icon: Icon(Icons.add),
            label: Text('添加订阅源'),
          ),
        ],
      ),
    );
  }

  void _navigateToFeedArticles(BuildContext context, Subscription subscription) {
    // TODO: 实现导航到订阅源的文章列表
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('查看订阅源: ${subscription.displayTitle}')),
    );
  }

  void _toggleFeedFavorite(BuildContext context, Subscription subscription) async {
    try {
      final subscriptionService = SubscriptionService();
      await subscriptionService.updateSubscription(
        feedId: subscription.feedId,
        isFavorite: !subscription.isFavorite,
      );
      
      // 刷新数据
      ref.refresh(subscriptionsProvider);
      
      // 显示结果
      final message = !subscription.isFavorite ? '已添加到收藏' : '已从收藏中移除';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('操作失败: $e')),
      );
    }
  }

  void _showFeedSettingsMenu(BuildContext context, Subscription subscription) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.edit),
                title: Text('编辑名称'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditFeedNameDialog(context, subscription);
                },
              ),
              ListTile(
                leading: Icon(Icons.folder),
                title: Text('移动到分组'),
                onTap: () {
                  Navigator.pop(context);
                  _showMoveToGroupDialog(context, subscription);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_outline),
                title: Text('删除订阅'),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteFeedConfirmation(context, subscription);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditFeedNameDialog(BuildContext context, Subscription subscription) {
    final TextEditingController controller = TextEditingController(
      text: subscription.customTitle ?? subscription.feed?.title,
    );
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('编辑名称'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: '输入新名称',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                
                if (controller.text.isNotEmpty) {
                  try {
                    final subscriptionService = SubscriptionService();
                    await subscriptionService.updateSubscription(
                      feedId: subscription.feedId,
                      customTitle: controller.text,
                    );
                    
                    // 刷新数据
                    ref.refresh(subscriptionsProvider);
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('名称已更新')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('更新失败: $e')),
                    );
                  }
                }
              },
              child: Text('保存'),
            ),
          ],
        );
      },
    );
  }

  void _showMoveToGroupDialog(BuildContext context, Subscription subscription) {
    // TODO: 实现移动到分组的对话框
  }

  void _showDeleteFeedConfirmation(BuildContext context, Subscription subscription) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('删除订阅'),
          content: Text('确定要删除 "${subscription.displayTitle}" 吗？'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                
                try {
                  final subscriptionService = SubscriptionService();
                  await subscriptionService.removeSubscription(subscription.feedId);
                  
                  // 刷新数据
                  ref.refresh(subscriptionsProvider);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('订阅已删除')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('删除失败: $e')),
                  );
                }
              },
              child: Text('删除'),
            ),
          ],
        );
      },
    );
  }

  void _showAddSourceBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '添加订阅源',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  hintText: '输入网站或RSS链接',
                  prefixIcon: Icon(Icons.link),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // 处理添加URL
                  Navigator.pop(context);
                },
                child: Text('添加'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 24),
              Text(
                '浏览热门订阅源',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  children: [
                    _buildPopularSourceItem(
                      '科技',
                      Icons.devices,
                      Colors.blue,
                    ),
                    _buildPopularSourceItem(
                      '新闻',
                      Icons.newspaper,
                      Colors.red,
                    ),
                    _buildPopularSourceItem(
                      '娱乐',
                      Icons.movie,
                      Colors.purple,
                    ),
                    _buildPopularSourceItem(
                      '生活',
                      Icons.restaurant,
                      Colors.orange,
                    ),
                    _buildPopularSourceItem(
                      '音乐',
                      Icons.music_note,
                      Colors.green,
                    ),
                    _buildPopularSourceItem(
                      '更多分类',
                      Icons.more_horiz,
                      Colors.grey,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPopularSourceItem(
    String title,
    IconData icon,
    Color color,
  ) {
    return InkWell(
      onTap: () {
        // 导航到该分类的热门订阅源列表
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
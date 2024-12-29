import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lazyreader/models/CustomUser.dart';
import 'package:lazyreader/service/hottopic_service.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CustomUser? currentUser;
  final PageController _pageController = PageController(
    viewportFraction: 0.85,
  );

  bool isLoading = false;
  List<dynamic> hottopics = [];
  List<String> platforms = [];
  final HottopicService _hottopicService = HottopicService();

  // Daily summary card with "Coming Soon" message
  final Map<String, dynamic> summaryCard = {
    "title": "Your Daily Summary",
    "content": "Stay tuned! More exciting features coming soon...",
    "date": DateTime.now(),
    "color": Colors.grey.shade100, // Changed to light grey
  };

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchHotTopics();
  }

  Future<void> _loadUserData() async {
    final user = await CustomUser.getFromLocalStorage();
    if (user != null) {
      setState(() {
        currentUser = user;
      });
    }
  }

  Future<void> _fetchHotTopics() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await _hottopicService.getHottopicDaily();
      if (response['code'] == 200) {
        final data = response['data'];
        setState(() {
          platforms = List<String>.from(data['platforms']);
          // Convert the topics map to a list of platform data
          hottopics = platforms.map((platform) {
            return {
              'platform': platform,
              'topics': (data['topics'][platform] as List?) ?? []
            };
          }).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching hot topics: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _fetchHotTopics,
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _buildCardStack(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24.0, 12.0, 24.0, 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello,',
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.black87,
                  fontWeight: FontWeight.w400,
                  height: 1.2,
                ),
              ),
              Text(
                currentUser?.displayName ?? 'Guest',
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
            ],
          ),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[100],
            ),
            child: ClipOval(
              child: currentUser?.photoURL != null
                  ? CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage('assets/tony.png'),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardStack() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    // Combine summary card with platform cards
    final allCards = [summaryCard, ...hottopics];

    return PageView.builder(
      controller: _pageController,
      itemCount: allCards.length,
      itemBuilder: (context, index) {
        final card = allCards[index];
        return AnimatedBuilder(
          animation: _pageController,
          builder: (context, child) {
            double value = 1.0;
            if (_pageController.position.haveDimensions) {
              value = _pageController.page! - index;
              value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
            }
            return Center(
              child: SizedBox(
                height: Curves.easeOut.transform(value) * 620,
                child: child,
              ),
            );
          },
          child: _buildCard(card, index == 0),
        );
      },
    );
  }

  Widget _buildCard(Map<String, dynamic> card, bool isSummary) {
    final String platform =
        isSummary ? '' : (card['platform'] as String? ?? '');
    // Using a darker theme color for all cards
    final Color cardColor = Theme.of(context).primaryColor.withOpacity(0.15);

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 4.0, vertical: 16.0), // Reduced horizontal padding
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            color: cardColor, // Removed gradient, using solid color
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        isSummary ? card['title'] : platform,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  DateFormat('MMMM d, yyyy').format(DateTime.now()),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: 24),
                Expanded(
                  child: isSummary
                      ? _buildSummaryContent()
                      : _buildTopicsList(card['topics'] as List<dynamic>),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryContent() {
    return Center(
      child: Text(
        summaryCard['content'],
        style: TextStyle(
          fontSize: 18,
          color: Colors.black54,
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  void _handleTopicTap(String? url) {
    if (url != null && url.isNotEmpty) {
      // 处理跳转逻辑，可以使用 url_launcher 或自定义导航
      print('Navigate to: $url');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildTopicsList(List<dynamic> topics) {
    return ListView.builder(
      itemCount: topics.length,
      padding: EdgeInsets.zero, // Removed padding
      itemBuilder: (context, index) {
        final topic = topics[index];
        return Card(
          margin:
              EdgeInsets.symmetric(vertical: 4.0), // Reduced vertical margin
          elevation: 0,
          color: Colors.white.withOpacity(0.7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () => _handleTopicTap(topic['link']),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8.0), // Further reduced vertical padding
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 22, // Even smaller ranking number
                    height: 22,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _getRankingColor(index),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 8), // Reduced spacing
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          topic['title'] ?? '',
                          style: TextStyle(
                            fontSize: 14, // Even smaller font
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 2), // Reduced spacing
                        Row(
                          children: [
                            Icon(
                              Icons.local_fire_department,
                              size: 14,
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.6),
                            ),
                            SizedBox(width: 4),
                            Text(
                              _formatHeat(topic['hot_value']),
                              style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.black26,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

// 根据排名返回不同的颜色
  Color _getRankingColor(int index) {
    switch (index) {
      case 0:
        return Colors.red.shade400;
      case 1:
        return Colors.orange.shade400;
      case 2:
        return Colors.amber.shade400;
      default:
        return Colors.grey.shade400;
    }
  }

// 优化热度值的格式化
  String _formatHeat(dynamic heat) {
    if (heat == null) return '0';

    num value = heat is num ? heat : num.tryParse(heat.toString()) ?? 0;

    if (value >= 100000000) {
      return '${(value / 100000000).toStringAsFixed(1)}亿';
    } else if (value >= 10000) {
      return '${(value / 10000).toStringAsFixed(1)}万';
    }
    return value.toString();
  }
}

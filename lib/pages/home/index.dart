import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lazyreader/models/CustomUser.dart';
import 'package:lazyreader/pages/mine/index.dart';
import 'package:lazyreader/service/hottopic_service.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  CustomUser? currentUser;
  bool isLoading = false;
  List<Map<String, dynamic>> allTopics = [];
  final HottopicService _hottopicService = HottopicService();
  bool isAISummaryExpanded = false;

  late AnimationController _arrowAnimationController;
  late Animation<double> _arrowAnimation;

  // Mock platforms
  final List<String> platforms = [
    'Weibo',
    'Zhihu',
    'Douyin',
    'Baidu',
    'Toutiao'
  ];

  // AI Summary mock data
  final Map<String, dynamic> aiSummary = {
    "title": "Today's AI Summary",
    "summary":
        "Today's hot topics primarily revolve around technology innovation, social issues, and entertainment. The most discussed topics include AI development, environmental protection, and trending social media events.",
    "insights": [
      "Tech Trend: Growing discussion about AI integration in daily life",
      "Social Focus: Environmental protection initiatives gaining attention",
      "Entertainment: New social media trends emerging across platforms"
    ],
    "date": DateTime.now(),
  };

  // Mock topics data
  final List<Map<String, dynamic>> mockTopics = [
    {
      "title": "OpenAI Announces GPT-5 Development",
      "platforms": ["Weibo", "Zhihu"],
      "hot_value": 8750000,
      "link": "https://example.com/1",
      "description": "Latest breakthrough in AI technology development",
    },
    {
      "title": "New Environmental Protection Policy Released",
      "platforms": ["Toutiao", "Baidu"],
      "hot_value": 6520000,
      "link": "https://example.com/2",
      "description": "Government announces new green initiatives",
    },
    {
      "title": "Global Technology Conference 2024",
      "platforms": ["Zhihu", "Douyin", "Weibo"],
      "hot_value": 5430000,
      "link": "https://example.com/3",
      "description": "Major tech companies reveal future plans",
    },
    {
      "title": "Viral Social Media Challenge Trends",
      "platforms": ["Douyin", "Weibo"],
      "hot_value": 4820000,
      "link": "https://example.com/4",
      "description": "New dance challenge goes viral",
    },
    {
      "title": "Space Exploration Breakthrough",
      "platforms": ["Zhihu", "Toutiao"],
      "hot_value": 3950000,
      "link": "https://example.com/5",
      "description": "Scientists discover new exoplanet",
    },
    {
      "title": "Digital Currency Innovation",
      "platforms": ["Baidu", "Zhihu"],
      "hot_value": 2840000,
      "link": "https://example.com/6",
      "description": "New developments in cryptocurrency",
    },
    {
      "title": "Healthcare Technology Innovation",
      "platforms": ["Toutiao", "Zhihu", "Baidu"],
      "hot_value": 2350000,
      "link": "https://example.com/7",
      "description": "AI applications in medical diagnosis",
    },
    {
      "title": "Educational Reform Initiative",
      "platforms": ["Weibo", "Toutiao"],
      "hot_value": 1980000,
      "link": "https://example.com/8",
      "description": "New policies in education system",
    },
  ];

  @override
/*************  ✨ Codeium Command ⭐  *************/
  /// Initializes the state for the home page by loading user data and mock data,
  /// and sets up the animation controller and tween animation for arrow animations.

/******  0762e9fc-68cf-4aa9-b9b7-2709af844c57  *******/
  void initState() {
    super.initState();
    _loadUserData();
    _loadMockData();
    _arrowAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _arrowAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _arrowAnimationController,
      curve: Curves.easeInOutBack,
    ));
  }

  @override
  void dispose() {
    _arrowAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = await CustomUser.getFromLocalStorage();
    if (user != null) {
      setState(() {
        currentUser = user;
      });
    }
  }

  void _loadMockData() {
    setState(() {
      allTopics = mockTopics;
      isLoading = false;
    });
  }

  Future<void> _refreshData() async {
    setState(() {
      isLoading = true;
    });
    await Future.delayed(Duration(seconds: 1));
    _loadMockData();
  }

  PreferredSizeWidget _buildAppBar() {
    final now = DateTime.now();
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: 80,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Welcome and Date Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Welcome message
                Row(
                  children: [
                    Text(
                      'Welcome ',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.5,
                        height: 1.2,
                      ),
                    ),
                    Text(
                      currentUser?.displayName ?? 'Guest',
                      style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.5,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                // Date display - using abbreviated format
                Row(
                  children: [
                    Text(
                      DateFormat('E').format(now),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      ', ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    Text(
                      DateFormat('MMM d').format(now),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Avatar section
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/profile'); // 跳转到个人中心页面
            },
            child: Container(
              margin: EdgeInsets.only(left: 16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MineMainPage(),
                      ),
                    ); // 跳转到个人中心页面
                  },
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    backgroundImage: currentUser?.photoURL != null
                        ? AssetImage('assets/tony.png')
                        : null,
                    child: currentUser?.photoURL == null
                        ? Icon(
                            Icons.person_outline_rounded,
                            size: 28,
                            color: Theme.of(context).primaryColor,
                          )
                        : null,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (isAISummaryExpanded) {
          setState(() {
            isAISummaryExpanded = false;
            _arrowAnimationController.reverse();
          });
          return false;
        }
        return true;
      },
      child: isAISummaryExpanded
          ? Scaffold(
              backgroundColor: Colors.white,
              body: Stack(
                children: [
                  SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        SafeArea(child: _buildExpandedSummaryContent()),
                        SizedBox(height: 60),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      color: Colors.white,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isAISummaryExpanded = false;
                            _arrowAnimationController.reverse();
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: Colors.grey.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.keyboard_arrow_up,
                                color: Theme.of(context).primaryColor,
                                size: 28,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Scaffold(
              backgroundColor: Colors.grey[50],
              appBar: _buildAppBar(),
              body: RefreshIndicator(
                onRefresh: _refreshData,
                child: CustomScrollView(
                  slivers: [
                    _buildAISummary(),
                    _buildHotTopicsList(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildAISummaryCard() {
    if (isAISummaryExpanded) {
      return SafeArea(
          child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.white,
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildExpandedSummaryContent(),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    isAISummaryExpanded = false;
                    _arrowAnimationController.reverse();
                  });
                },
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      SizedBox(height: 8),
                      Icon(
                        Icons.keyboard_arrow_up,
                        color: Theme.of(context).primaryColor,
                        size: 28,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ));
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          isAISummaryExpanded = !isAISummaryExpanded;
          if (isAISummaryExpanded) {
            _arrowAnimationController.forward();
          } else {
            _arrowAnimationController.reverse();
          }
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        margin: isAISummaryExpanded
            ? EdgeInsets.zero
            : EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isAISummaryExpanded ? 0 : 16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        constraints: BoxConstraints(
          minHeight: isAISummaryExpanded
              ? MediaQuery.of(context).size.height -
                  kToolbarHeight -
                  MediaQuery.of(context).padding.top
              : 0,
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: Theme.of(context).primaryColor,
                        size: isAISummaryExpanded ? 28 : 24,
                      ),
                      SizedBox(width: 8),
                      Text(
                        aiSummary['title'],
                        style: TextStyle(
                          fontSize: isAISummaryExpanded ? 24 : 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isAISummaryExpanded ? 16 : 12),
                  Text(
                    aiSummary['summary'],
                    style: TextStyle(
                      fontSize: isAISummaryExpanded ? 18 : 16,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                    maxLines: isAISummaryExpanded ? null : 3,
                    overflow:
                        isAISummaryExpanded ? null : TextOverflow.ellipsis,
                  ),
                  SizedBox(height: isAISummaryExpanded ? 24 : 16),
                  ...aiSummary['insights']
                      .map<Widget>((insight) => Padding(
                            padding: EdgeInsets.only(
                                bottom: isAISummaryExpanded ? 16 : 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.arrow_right,
                                    size: isAISummaryExpanded ? 24 : 20,
                                    color: Theme.of(context).primaryColor),
                                SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    insight,
                                    style: TextStyle(
                                      fontSize: isAISummaryExpanded ? 16 : 14,
                                      color: Colors.black54,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: RotationTransition(
                turns: _arrowAnimation,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _arrowAnimationController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(
                              0,
                              sin(_arrowAnimationController.value * 3 * pi) *
                                  3),
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            color: Theme.of(context).primaryColor,
                            size: 28,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedSummaryContent() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: Theme.of(context).primaryColor,
                size: 32,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  aiSummary['title'],
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          Text(
            aiSummary['summary'],
            style: TextStyle(
              fontSize: 18,
              color: Colors.black87,
              height: 1.6,
              letterSpacing: 0.2,
            ),
          ),
          SizedBox(height: 32),
          Text(
            'Key Insights',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          ...aiSummary['insights']
              .map<Widget>((insight) => Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: Theme.of(context).primaryColor,
                            size: 24,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              insight,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ))
              .toList(),
          SizedBox(height: 100), // Bottom padding for scroll space
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildAISummary() {
    return SliverToBoxAdapter(
      child: _buildAISummaryCard(),
    );
  }

  Widget _buildHotTopicsHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Row(
        children: [
          Icon(Icons.local_fire_department, color: Colors.redAccent),
          SizedBox(width: 8),
          Text(
            'Trending Topics',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Spacer(),
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  SliverList _buildHotTopicsList() {
    if (isLoading) {
      return SliverList(
        delegate: SliverChildListDelegate([
          Center(child: CircularProgressIndicator()),
        ]),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == 0) {
            return _buildHotTopicsHeader();
          }

          final topicIndex = index - 1;
          if (topicIndex >= allTopics.length) return null;

          final topic = allTopics[topicIndex];
          return _buildTopicItem(topic, topicIndex);
        },
        childCount: allTopics.length + 1,
      ),
    );
  }

  Widget _buildTopicItem(Map<String, dynamic> topic, int index) {
    List<String> platforms = List<String>.from(topic['platforms']);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _handleTopicTap(topic['link']),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _getRankingColor(index),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      topic['title'] ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.local_fire_department,
                    size: 14,
                    color: Colors.redAccent,
                  ),
                  SizedBox(width: 4),
                  Text(
                    _formatHeat(topic['hot_value']),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                  Spacer(),
                  Text(
                    'Trending on:',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black45,
                    ),
                  ),
                  SizedBox(width: 4),
                ],
              ),
              SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: platforms
                    .map((platform) => Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getPlatformColor(platform).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color:
                                  _getPlatformColor(platform).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            platform,
                            style: TextStyle(
                              fontSize: 12,
                              color: _getPlatformColor(platform),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ))
                    .toList(),
              ),
              if (topic['description'] != null) ...[
                SizedBox(height: 8),
                Text(
                  topic['description'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getPlatformColor(String platform) {
    switch (platform) {
      case 'Weibo':
        return Colors.red;
      case 'Zhihu':
        return Colors.blue;
      case 'Douyin':
        return Colors.purple;
      case 'Baidu':
        return Colors.blue.shade700;
      case 'Toutiao':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _handleTopicTap(String? url) {
    if (url != null && url.isNotEmpty) {
      print('Navigate to: $url');
    }
  }

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

  String _formatHeat(dynamic heat) {
    if (heat == null) return '0';
    num value = heat is num ? heat : num.tryParse(heat.toString()) ?? 0;
    if (value >= 100000000) {
      return '${(value / 100000000).toStringAsFixed(1)}B';
    } else if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toString();
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lazyreader/models/CustomUser.dart';

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

  final List<NewsCard> newsCards = [
    NewsCard(
      title: "Today's Highlights",
      content: "Major tech company announces new product line",
      date: DateTime.now(),
      color: Colors.blue.shade100,
    ),
    NewsCard(
      title: "Breaking News",
      content: "International peace talks make progress",
      date: DateTime.now().subtract(Duration(days: 1)),
      color: Colors.green.shade100,
    ),
    NewsCard(
      title: "Latest Updates",
      content: "Record-breaking heatwave affects multiple countries",
      date: DateTime.now().subtract(Duration(days: 2)),
      color: Colors.orange.shade100,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await CustomUser.getFromLocalStorage();
    if (user != null) {
      setState(() {
        currentUser = user;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildCardStack(),
            ),
          ],
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
                      radius: 30, // Adjust the size of the avatar
                      backgroundImage: AssetImage('assets/tony.png'),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  // Rest of the code remains the same...
  Widget _buildCardStack() {
    return PageView.builder(
      controller: _pageController,
      itemCount: newsCards.length,
      itemBuilder: (context, index) {
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
          child: _buildCard(newsCards[index]),
        );
      },
    );
  }

  Widget _buildCard(NewsCard card) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                card.color,
                card.color.withOpacity(0.7),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.title,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  DateFormat('MMMM d, yyyy').format(card.date),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: 24),
                Expanded(
                  child: Text(
                    card.content,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: TextButton(
                    onPressed: () {
                      // Handle read more action
                    },
                    child: Text(
                      'Read More',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NewsCard {
  final String title;
  final String content;
  final DateTime date;
  final Color color;

  NewsCard({
    required this.title,
    required this.content,
    required this.date,
    required this.color,
  });
}

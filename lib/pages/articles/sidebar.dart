import 'package:flutter/material.dart';
import 'package:lazyreader/pages/rss/index.dart';
import 'package:lazyreader/service/rss_service.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class FeedDrawer extends StatefulWidget {
  final Function(dynamic feed) onSelectFeed;
  final int selectedIndex;
  final Function(int) onSelectedIndexChange;

  const FeedDrawer({
    Key? key,
    required this.onSelectFeed,
    required this.selectedIndex,
    required this.onSelectedIndexChange,
  }) : super(key: key);

  @override
  _FeedDrawerState createState() => _FeedDrawerState();
}

class _FeedDrawerState extends State<FeedDrawer> {
  int selectedIndex = 0;
  List<Map<String, dynamic>> subscribedUnRead = [];

  @override
  void initState() {
    super.initState();

    initData();
  }

  Future<void> initData() async {
    RssService rssService = RssService();
    try {
      var result = await rssService.getUserSubScribedUnRead();
      List<Map<String, dynamic>> data =
          List<Map<String, dynamic>>.from(result['data']);

      setState(() {
        subscribedUnRead = data;
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate the total number of unread articles
    int totalUnread = subscribedUnRead.fold<int>(
        0,
        (int previousValue, element) =>
            previousValue + (element['unread_articles_count'] as int? ?? 0));

    return Drawer(
        child: Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 30,
          ),
          ListTile(
            title: Text(
              'Feeds',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            trailing: IconButton(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.zero,
              icon: Icon(
                Icons.add_circle_sharp,
                color: Theme.of(context).primaryColor,
              ),
              onPressed: () {
                showBarModalBottomSheet(
                  expand: true,
                  context: context,
                  builder: (context) => RSS(),
                );
              },
            ),
          ),
          Container(
            color: widget.selectedIndex == 0
                ? Theme.of(context).primaryColor
                : Colors.transparent, // Change color based on selection
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                      width: 24,
                      height: 24), // Placeholder to maintain alignment
                  title: Text(
                    'All Articles',
                    style: TextStyle(
                      fontSize: widget.selectedIndex == 0 ? 16 : 14,
                      color: widget.selectedIndex == 0
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  trailing: Container(
                    padding: EdgeInsets.all(6),
                    child: Text(
                      totalUnread.toString(),
                      style: TextStyle(
                        fontSize: widget.selectedIndex == 0 ? 16 : 14,
                        color: widget.selectedIndex == 0
                            ? Colors.white
                            : Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      widget.onSelectedIndexChange(0);
                      widget.onSelectFeed(null);
                      Navigator.of(context).pop();
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: subscribedUnRead.length,
              itemBuilder: (context, index) {
                bool isSelected = widget.selectedIndex == index + 1;
                return Container(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.transparent,
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 14,
                      backgroundImage: NetworkImage(
                          subscribedUnRead[index]['rss_feed']['logo']),
                    ),
                    title: Text(
                      subscribedUnRead[index]['rss_feed']['title'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 14,
                          color: isSelected ? Colors.white : Colors.black),
                    ),
                    trailing: subscribedUnRead[index]['unread_articles_count'] >
                            0
                        ? Container(
                            padding: EdgeInsets.all(6),
                            child: Text(
                              subscribedUnRead[index]['unread_articles_count']
                                  .toString(),
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Theme.of(context).primaryColor,
                                fontSize: 14,
                              ),
                            ),
                          )
                        : SizedBox(),
                    onTap: () {
                      widget.onSelectedIndexChange(index + 1);
                      widget.onSelectFeed(subscribedUnRead[index]);
                      Navigator.of(context).pop();
                    },
                  ),
                );
              },
            ),
          ),
          SizedBox(
            height: 30,
          ),
        ],
      ),
    ));
  }
}

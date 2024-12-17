import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lazyreader/pages/articles/details.dart';

class ArticleCard extends StatelessWidget {
  final Map<String, dynamic> article;
  String formatPublishedDate(String publishedDateStr) {
    // Convert the provided date string into a DateTime object
    DateTime publishedDate = DateTime.parse(publishedDateStr);
    DateTime now = DateTime.now();
    Duration difference = now.difference(publishedDate);

    // Calculate and return the corresponding string
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      // If more than a week ago, return the specific time, this can be adjusted as needed
      return '${publishedDate.year}-${publishedDate.month}-${publishedDate.day}';
    }
  }

  const ArticleCard({
    Key? key,
    required this.article,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isRead =
        article.containsKey('is_read') ? article['is_read'] ?? false : false;
    Color summaryColor = isRead ? Colors.grey[500]! : Colors.grey[600]!;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewsDetails(
              detailId: article['id'],
            ),
          ),
        );
      },
      child: Opacity(
        opacity: 1,
        child: Container(
          padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (article['thumbnail_url'] != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6.0),
                        child: CachedNetworkImage(
                          imageUrl: article['thumbnail_url'].toString(),
                          placeholder: (context, url) => Padding(
                            padding: EdgeInsets.all(30.0),
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                              color: Theme.of(context).secondaryHeaderColor,
                            ),
                          ),
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          article['title'],
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 6),
                        Text(
                          article['summary'] ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            color: summaryColor,
                            height: 1.2,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    article['feed_title'],
                    style: TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                  Text(
                    formatPublishedDate(article['published_date']),
                    style: TextStyle(fontSize: 12, color: summaryColor),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

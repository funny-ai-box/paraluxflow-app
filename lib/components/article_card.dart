import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lazyreader/pages/articles/details.dart';

class ArticleCard extends StatelessWidget {
  final Map<String, dynamic> article;

  String formatPublishedDate(String publishedDateStr) {
    DateTime publishedDate = DateTime.parse(publishedDateStr);
    DateTime now = DateTime.now();
    Duration difference = now.difference(publishedDate);

    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return '${publishedDate.year}-${publishedDate.month.toString().padLeft(2, '0')}-${publishedDate.day.toString().padLeft(2, '0')}';
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
    String? feedTitle = article['feed_title'];
    Color summaryColor = isRead ? Colors.grey[400]! : Colors.grey[600]!;
    Color titleColor = isRead ? Colors.grey[600]! : Colors.black87;

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
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (article['thumbnail_url'] != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: article['thumbnail_url'].toString(),
                      placeholder: (context, url) => Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: Colors.grey[400],
                          size: 32,
                        ),
                      ),
                      width: 110,
                      height: 110,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article['title'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                          color: titleColor,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (article['summary']?.isNotEmpty ?? false) ...[
                        const SizedBox(height: 8),
                        Text(
                          article['summary'] ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: summaryColor,
                            height: 1.4,
                            letterSpacing: 0.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (feedTitle?.isNotEmpty ?? false)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        feedTitle!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                if (feedTitle?.isNotEmpty ?? false) const SizedBox(width: 12),
                Text(
                  formatPublishedDate(article['published_date']),
                  style: TextStyle(
                    fontSize: 12,
                    color: summaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

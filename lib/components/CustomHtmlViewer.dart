import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:html/parser.dart' as htmlparser;
import 'package:html/dom.dart' as dom;
import 'package:cached_network_image/cached_network_image.dart';

class CustomImageExtension extends HtmlExtension {
  final double maxImageWidth;
  final double? fixedImageHeight;
  final BoxFit imageFit;

  CustomImageExtension({
    this.maxImageWidth = 1.0,
    this.fixedImageHeight,
    this.imageFit = BoxFit.contain,
  });

  @override
  Set<String> get supportedTags => {"img"};

  @override
  bool matches(ExtensionContext context) {
    return context.elementName == "img";
  }

  @override
  InlineSpan build(ExtensionContext context) {
    final attributes = context.element?.attributes ?? {};
    final String? url = attributes['src'];

    if (url == null || url.isEmpty) {
      return const TextSpan(text: '');
    }

    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: Builder(builder: (context) {
        return Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final availableWidth = constraints.maxWidth;
                return Container(
                  width: availableWidth,
                  constraints: BoxConstraints(
                    maxHeight: fixedImageHeight ?? double.infinity,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: url,
                      fit: imageFit,
                      width: availableWidth,
                      errorWidget: (context, url, error) => Container(
                        width: availableWidth,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline,
                                color: Colors.red[300], size: 32),
                            const SizedBox(height: 8),
                            Text(
                              attributes['alt'] ?? 'Image load failed',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      placeholder: (context, url) => Container(
                        width: availableWidth,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      }),
    );
  }
}

class CustomHtmlViewer extends StatelessWidget {
  final String htmlContent;
  final OnTap? onLinkTap;
  final double? fontSize;
  final String? fontFamily;
  final Color? linkColor;
  final double maxImageWidth;
  final double? fixedImageHeight;
  final BoxFit imageFit;

  const CustomHtmlViewer({
    Key? key,
    required this.htmlContent,
    this.onLinkTap,
    this.fontSize = 14.0,
    this.fontFamily,
    this.linkColor,
    this.maxImageWidth = 0.8,
    this.fixedImageHeight,
    this.imageFit = BoxFit.contain,
  }) : super(key: key);

  String _sanitizeHtml(String html) {
    try {
      if (html.isEmpty) {
        return '';
      }

      // 先移除所有style标签和内容
      html = html.replaceAll(
          RegExp(r'<style\b[^<]*(?:(?!<\/style>)<[^<]*)*<\/style>',
              multiLine: true),
          '');

      // 移除所有class和style属性
      html = html
          .replaceAll(RegExp(r'\s+class="[^"]*"'), '')
          .replaceAll(RegExp(r'\s+style="[^"]*"'), '');

      // 移除所有HTML注释
      html = html.replaceAll(RegExp(r'<!--[\s\S]*?-->'), '');

      var cleanHtml = html.trim();

      // 确保有基本的HTML结构
      if (!cleanHtml.startsWith('<')) {
        cleanHtml = '<div>' + cleanHtml + '</div>';
      }

      var document = htmlparser.parse(cleanHtml);
      var body = document.body;
      if (body == null) {
        return '<div>' + cleanHtml + '</div>';
      }

      // 处理图片标签
      body.querySelectorAll('img').forEach((img) {
        img.attributes
            .removeWhere((key, value) => !['src', 'alt'].contains(key));
        if (!img.attributes.containsKey('alt')) {
          img.attributes['alt'] = 'image';
        }
      });

      // 创建新的document以确保干净的HTML结构
      var processedHtml = body.innerHtml;
      return processedHtml;
    } catch (e) {
      debugPrint('Error sanitizing HTML: $e');
      // 基础清理
      return html.replaceAll(
          RegExp(r'<(style|script)[^>]*>.*?</(style|script)>',
              multiLine: true, dotAll: true),
          '');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ErrorBoundary(
      child: Builder(
        builder: (context) {
          final cleanedHtml = _sanitizeHtml(htmlContent);

          return SingleChildScrollView(
            child: Html(
              data: cleanedHtml,
              extensions: [
                CustomImageExtension(
                  maxImageWidth: maxImageWidth,
                  fixedImageHeight: fixedImageHeight,
                  imageFit: imageFit,
                ),
              ],
              style: {
                "*": Style(
                  margin: Margins.zero,
                  padding: HtmlPaddings.zero,
                  display: Display.block,
                ),
                "body": Style(
                  fontSize: FontSize(fontSize!),
                  lineHeight: LineHeight.number(1.6),
                  fontFamily: fontFamily ?? GoogleFonts.inter().fontFamily,
                  color: Colors.black87,
                  margin: Margins.zero,
                  padding: HtmlPaddings.zero,
                ),
                "p": Style(
                  margin: Margins(bottom: Margin(20)),
                  fontSize: FontSize(fontSize! * 1.1),
                ),
                "h2": Style(
                  fontSize: FontSize(fontSize! * 1.6),
                  margin: Margins(top: Margin(32), bottom: Margin(16)),
                  fontWeight: FontWeight.w600,
                ),
                "img": Style(
                  margin: Margins(top: Margin(24), bottom: Margin(24)),
                ),
                "em": Style(
                  fontStyle: FontStyle.italic,
                ),
                "strong": Style(
                  fontWeight: FontWeight.bold,
                ),
                "a": Style(
                  color: linkColor ?? Theme.of(context).primaryColor,
                  textDecoration: TextDecoration.underline,
                ),
              },
              onAnchorTap: onLinkTap,
              shrinkWrap: true,
              doNotRenderTheseTags: {
                "script",
                "style",
                "svg",
                "meta",
                "link",
                "title",
                "noscript",
              },
            ),
          );
        },
      ),
    );
  }
}

class ErrorBoundary extends StatefulWidget {
  final Widget child;

  const ErrorBoundary({Key? key, required this.child}) : super(key: key);

  @override
  ErrorBoundaryState createState() => ErrorBoundaryState();
}

class ErrorBoundaryState extends State<ErrorBoundary> {
  bool hasError = false;

  @override
  Widget build(BuildContext context) {
    if (hasError) {
      return const Center(
        child: Text(
          'Error rendering content',
          style: TextStyle(color: Colors.red),
        ),
      );
    }
    return widget.child;
  }

  @override
  void didCatch(dynamic error, StackTrace stackTrace) {
    setState(() {
      hasError = true;
    });
    debugPrint('Error in HTML rendering: $error\n$stackTrace');
  }
}

import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // 引入flutter_svg
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';

class AdvancedTimeoutImage extends StatefulWidget {
  final String imageUrl;
  final String? errorImageUrl; // 可选的错误图片URL
  final double width;
  final double? height;
  final Duration timeoutDuration;
  final BoxFit fit;

  const AdvancedTimeoutImage({
    Key? key,
    required this.imageUrl,
    this.errorImageUrl,
    required this.width,
    this.height,
    this.timeoutDuration = const Duration(seconds: 10),
    this.fit = BoxFit.cover,
  }) : super(key: key);

  @override
  State<AdvancedTimeoutImage> createState() => _AdvancedTimeoutImageState();
}

// class _AdvancedTimeoutImageState extends State<AdvancedTimeoutImage> {
class _AdvancedTimeoutImageState extends State<AdvancedTimeoutImage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // 添加这行

  late Future<Uint8List?> _imageFuture;

  @override
  void initState() {
    super.initState();
    print('加载图片');
    if (widget.imageUrl.isEmpty) {
      _imageFuture = Future.value(null);
    } else {
      _imageFuture = _downloadImage(widget.imageUrl, widget.timeoutDuration);
    }
  }

  Future<Uint8List?> _downloadImage(String url, Duration timeout) async {
    try {
      final response = await http.get(Uri.parse(url)).timeout(timeout);
      print("0----------${response.statusCode}");
      print("0----------${response.bodyBytes}");
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
      return null;
    } on TimeoutException catch (error) {
      print(error);
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder<Uint8List?>(
      future: _imageFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: widget.width,
              height: widget.height ?? 100,
              color: Colors.grey[200],
            ),
          );
        } else if (snapshot.hasError || snapshot.data == null) {
          return widget.errorImageUrl != null
              ? Image.asset(
                  widget.errorImageUrl!,
                  width: widget.width,
                  height: widget.height,
                  fit: widget.fit,
                )
              : Image.asset(
                  'images/error-img.webp',
                  width: widget.width,
                  height: widget.height,
                  fit: widget.fit,
                );
        } else {
          // 检查图片URL后缀，以判断是否为SVG
          if (widget.imageUrl.endsWith('.svg')) {
            return SvgPicture.memory(
              snapshot.data!,
              width: widget.width,
              height: widget.height ?? widget.width,
              fit: widget.fit,
            );
          } else {
            return Image.memory(
              snapshot.data!,
              width: widget.width,
              height: widget.height,
              fit: widget.fit,
            );
          }
        }
      },
    );
  }
}

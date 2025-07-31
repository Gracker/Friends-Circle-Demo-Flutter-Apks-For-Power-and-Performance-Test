import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../utils/asset_generator.dart';

/// 图片网格组件
class ImageGrid extends StatelessWidget {
  final List<String> imageUrls;

  const ImageGrid({
    Key? key,
    required this.imageUrls,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 根据图片数量确定网格布局
    int crossAxisCount = _getCrossAxisCount(imageUrls.length);
    double ratio = _getAspectRatio(imageUrls.length);
    
    return Container(
      constraints: BoxConstraints(
        maxHeight: imageUrls.length == 1 ? 250 : 400,
      ),
      child: StaggeredGrid.count(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        children: List.generate(
          imageUrls.length,
          (index) => _buildImageItem(context, index),
        ),
      ),
    );
  }

  /// 构建单个图片项
  Widget _buildImageItem(BuildContext context, int index) {
    return AspectRatio(
      aspectRatio: _getAspectRatio(imageUrls.length),
      child: GestureDetector(
        onTap: () => _showImageGallery(context, index),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: AssetGenerator().generateImageWidget(
            'image_${imageUrls[index]}_$index',
            width: double.infinity,
            height: double.infinity,
          ),
        ),
      ),
    );
  }

  /// 显示图片画廊
  void _showImageGallery(BuildContext context, int initialIndex) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.zero,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black,
          child: Stack(
            children: [
              // 图片显示
              Center(
                child: AssetGenerator().generateImageWidget(
                  'image_${imageUrls[initialIndex]}_$initialIndex',
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width,
                ),
              ),
              
              // 关闭按钮
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                right: 10,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              
              // 图片索引
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    '${initialIndex + 1}/${imageUrls.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 根据图片数量确定网格列数
  int _getCrossAxisCount(int imageCount) {
    if (imageCount == 1) return 1;
    if (imageCount <= 4) return 2;
    return 3;
  }
  
  /// 根据图片数量获取图片的宽高比
  double _getAspectRatio(int imageCount) {
    if (imageCount == 1) return 16 / 9;
    return 1.0;
  }
} 
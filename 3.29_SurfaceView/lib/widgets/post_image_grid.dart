import 'package:flutter/material.dart';
import '../utils/asset_generator.dart';

/// 朋友圈九宫格图片组件 - 1:1 还原微信朋友圈的九宫格布局
class PostImageGrid extends StatelessWidget {
  /// 图片URL列表
  final List<String>? imageUrls;
  
  /// 帖子ID (用于生成图片)
  final String postId;
  
  /// 图片间距 (对应NineGridView的ITEM_GAP = 6dp)
  final double spacing;
  
  /// 构造函数
  const PostImageGrid({
    Key? key,
    this.imageUrls,
    required this.postId,
    this.spacing = 6.0,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // 如果没有图片，返回空组件
    if (imageUrls == null || imageUrls!.isEmpty) {
      return const SizedBox.shrink();
    }
    
    // 确保图片URL列表不超过9张 (与NineGridView一致)
    final List<String> displayUrls = imageUrls!.length > 9 
      ? imageUrls!.sublist(0, 9) 
      : imageUrls!;
    
    final int itemCount = displayUrls.length;
    
    // 确定列数 (与NineGridView完全一致)
    // 如果是4张图片，使用2列；否则最多3列
    final int columns = itemCount == 4 ? 2 : Math.min(3, itemCount);
    
    // 计算行数 (使用ceil确保有足够的行)
    final int rows = (itemCount / columns).ceil();
    
    // 计算可用宽度 (减去左边的头像和间距，大约70-80px)
    final double availableWidth = MediaQuery.of(context).size.width - 80;
    
    // 重要修复：计算单个图片的宽度
    // 微信的做法是：先算出3列时的单个宽度，然后用这个宽度来布局所有图片
    // 这样无论显示多少列，每张图片的宽度都是一样的
    final double threeColumnsWidth = (availableWidth - (3 - 1) * spacing) / 3;
    final double singleWidth = threeColumnsWidth;
    
    // 计算整个网格的宽度和高度
    // 宽度应该是实际列数乘以单个图片宽度，再加上间距
    final double gridWidth = columns * singleWidth + (columns - 1) * spacing;
    final double gridHeight = rows * singleWidth + (rows - 1) * spacing;
    
    // 构建九宫格
    return Container(
      width: gridWidth,
      height: gridHeight,
      child: _buildGridItems(displayUrls, columns, singleWidth),
    );
  }
  
  /// 构建网格项 - 不使用GridView，而是手动排列，更接近原生实现
  Widget _buildGridItems(List<String> imageUrls, int columns, double singleWidth) {
    return Stack(
      children: List.generate(imageUrls.length, (index) {
        // 计算行列位置 (与NineGridView的onLayout方法一致)
        final int row = index ~/ columns;
        final int col = index % columns;
        
        // 计算位置
        final double left = col * (singleWidth + spacing);
        final double top = row * (singleWidth + spacing);
        
        return Positioned(
          left: left,
          top: top,
          width: singleWidth,
          height: singleWidth,
          child: GestureDetector(
            onTap: () {
              // 可以在这里添加点击事件处理
              print('Tapped image at index $index');
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: AssetGenerator().generateImageWidget(
                "$postId-$index", 
                width: singleWidth,
                height: singleWidth,
              ),
            ),
          ),
        );
      }),
    );
  }
}

class Math {
  static int min(int a, int b) => a < b ? a : b;
} 
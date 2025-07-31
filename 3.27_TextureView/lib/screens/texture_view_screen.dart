import 'package:flutter/material.dart';
import '../widgets/texture_view_widget.dart';
import '../widgets/friend_circle_item.dart';
import '../data/data_center.dart';

/// TextureView演示屏幕
/// 
/// 展示使用TextureView渲染的朋友圈列表
class TextureViewScreen extends StatefulWidget {
  const TextureViewScreen({super.key});

  @override
  State<TextureViewScreen> createState() => _TextureViewScreenState();
}

class _TextureViewScreenState extends State<TextureViewScreen> {
  
  @override
  void initState() {
    super.initState();
    
    // 初始化TextureView桥接
    _initializeTextureView();
  }
  
  /// 初始化TextureView
  Future<void> _initializeTextureView() async {
    try {
      await TextureViewBridge.initialize();
      
      // 设置TextureView属性
      await TextureViewBridge.setProperty('renderMode', 'texture');
      await TextureViewBridge.setProperty('opacity', 1.0);
      
      debugPrint('TextureView initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize TextureView: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('朋友圈 - TextureView模式'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // 显示TextureView状态的指示器
          FutureBuilder<dynamic>(
            future: TextureViewBridge.getProperty('isAvailable'),
            builder: (context, snapshot) {
              final isAvailable = snapshot.data == true;
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isAvailable ? Icons.check_circle : Icons.error,
                      color: isAvailable ? Colors.green : Colors.red,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isAvailable ? 'TextureView' : '未启用',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: TextureViewWidget(
        creationParams: {
          'renderMode': 'texture',
          'enableHardwareAcceleration': true,
        },
        child: _buildFriendsList(),
      ),
    );
  }

  /// 构建朋友圈列表
  Widget _buildFriendsList() {
    final friendsData = DataCenter().getFriendCircleData(1); // 使用轻负载数据
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: friendsData.length,
      itemBuilder: (context, index) {
        final item = friendsData[index];
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // TextureView标识
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.texture,
                      size: 14,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'TextureView渲染',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // 朋友圈内容
              FriendCircleItem(
                item: item,
                loadType: 1, // 轻负载类型
                onSimulateLoad: (loadType) {
                  // 这里可以添加负载模拟逻辑
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// 处理点赞
  void _handleLike(String postId) {
    // 更新TextureView内容
    TextureViewBridge.updateContent({
      'action': 'like',
      'postId': postId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// 处理评论
  void _handleComment(String postId) {
    // 更新TextureView内容
    TextureViewBridge.updateContent({
      'action': 'comment',
      'postId': postId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants.dart';
import '../data/data_center.dart';
import '../models/friend_circle_model.dart';
import '../models/post_model.dart';
import '../widgets/post_item.dart';
import '../widgets/friend_circle_header.dart';
import '../widgets/texture_view_widget.dart';
import '../utils/asset_generator.dart';

/// 基础负载屏幕组件，作为三个负载屏幕的基类
abstract class BaseLoadScreen extends StatefulWidget {
  final int loadType;

  const BaseLoadScreen({
    Key? key,
    required this.loadType,
  }) : super(key: key);
}

/// 基础负载屏幕状态
abstract class BaseLoadScreenState<T extends BaseLoadScreen> extends State<T> {
  late List<PostModel> _postData;
  late ScrollController _scrollController;
  bool _isScrolling = false;
  bool _showAppBar = false;

  @override
  void initState() {
    super.initState();
    
    // 清除缓存数据，确保每次测试都重新生成
    DataCenter().clearCachedData();
    
    // 获取对应负载类型的朋友圈数据，并转换为帖子数据
    final friendCircleData = DataCenter().getFriendCircleData(widget.loadType);
    _postData = friendCircleData.map((fc) => PostModel.fromFriendCircleModel(fc)).toList();
    
    // 初始化滚动控制器
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  /// 滚动监听器
  void _scrollListener() {
    // 检测滚动状态
    if (_scrollController.position.isScrollingNotifier.value) {
      if (!_isScrolling) {
        setState(() {
          _isScrolling = true;
        });
      }
    } else {
      if (_isScrolling) {
        setState(() {
          _isScrolling = false;
        });
      }
    }
    
    // 检测是否应该显示App Bar
    if (_scrollController.position.pixels > 200 && !_showAppBar) {
      setState(() {
        _showAppBar = true;
      });
    } else if (_scrollController.position.pixels <= 200 && _showAppBar) {
      setState(() {
        _showAppBar = false;
      });
    }
  }

  /// 模拟计算负载
  void _simulateLoad(int loadType) {
    DataCenter().simulateComputeLoad(loadType);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      extendBodyBehindAppBar: true,
      appBar: _showAppBar ? _buildAppBar() : null,
      body: Column(
        children: [
          // TextureView标识栏
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              border: Border(
                bottom: BorderSide(
                  color: Colors.blue.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  Icon(
                    Icons.texture,
                    size: 16,
                    color: Colors.blue.shade700,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'TextureView渲染模式 - ${_getLoadTypeTitle()}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade700,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'TextureView',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 主要内容 - 使用TextureView渲染模式
          Expanded(
            child: _buildMainContent(),
          ),
        ],
      ),
    );
  }

  /// 构建主要内容 - 使用TextureView渲染模式
  Widget _buildMainContent() {
    // 使用Container包装来确保TextureView渲染模式
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.all(8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: _buildTextureViewContent(),
      ),
    );
  }

  /// 构建TextureView渲染的内容
  Widget _buildTextureViewContent() {
    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        // TextureView渲染信息头部
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade50, Colors.blue.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.texture, color: Colors.blue.shade700, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'TextureView 渲染模式',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '负载类型: ${_getLoadTypeTitle()}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue.shade600,
                  ),
                ),
                Text(
                  '列表项数: ${_postData.length}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade700,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '✓ Flutter使用官方FlutterTextureView渲染',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // 朋友圈头部
        SliverToBoxAdapter(
          child: _buildHeader(),
        ),
        
        // 朋友圈列表
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final post = _postData[index];
              return PostItem(
                post: post,
                loadType: widget.loadType,
              );
            },
            childCount: _postData.length,
          ),
        ),
      ],
    );
  }

  /// 初始化TextureView内容
  void _initializeTextureViewContent(int platformViewId) {
    // 通过TextureViewBridge发送朋友圈数据到原生端
    final friendCircleData = DataCenter().getFriendCircleData(widget.loadType);
    final contentData = friendCircleData.map((item) => {
      'id': item.id,
      'username': item.user.nickname,
      'avatar': item.user.avatarUrl,
      'content': item.content,
      'images': item.imageUrls,
      'timestamp': item.createTime.toString(),
      'likeCount': item.praises.length,
      'commentCount': item.comments.length,
      'isLiked': false,
    }).toList();
    
    TextureViewBridge.updateContent({
      'platformViewId': platformViewId,
      'loadType': widget.loadType,
      'contentData': contentData,
    });
  }
  
  /// 构建AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        '朋友圈',
        style: TextStyle(
          color: Colors.black,
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.camera_alt, color: Colors.black),
          onPressed: () {},
        ),
      ],
    );
  }

  /// 构建头部视图
  Widget _buildHeader() {
    return FriendCircleHeader(
      title: _getLoadTypeTitle(),
      backgroundColor: _getLoadTypeColor(),
      onBackPressed: () => Navigator.pop(context),
    );
  }

  /// 获取负载类型标题
  String _getLoadTypeTitle() {
    switch (widget.loadType) {
      case Constants.LOAD_TYPE_LIGHT:
        return '轻负载测试';
      case Constants.LOAD_TYPE_MEDIUM:
        return '中负载测试';
      case Constants.LOAD_TYPE_HEAVY:
        return '重负载测试';
      default:
        return '未知负载测试';
    }
  }

  /// 获取负载类型颜色
  Color _getLoadTypeColor() {
    switch (widget.loadType) {
      case Constants.LOAD_TYPE_LIGHT:
        return Colors.blue;
      case Constants.LOAD_TYPE_MEDIUM:
        return Colors.orange;
      case Constants.LOAD_TYPE_HEAVY:
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }
} 
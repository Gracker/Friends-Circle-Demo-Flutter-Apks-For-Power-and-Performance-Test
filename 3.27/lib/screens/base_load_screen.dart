import 'package:flutter/material.dart';
import '../constants.dart';
import '../data/data_center.dart';
import '../models/friend_circle_model.dart';
import '../models/post_model.dart';
import '../widgets/post_item.dart';
import '../widgets/friend_circle_header.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      extendBodyBehindAppBar: true,
      appBar: _showAppBar ? _buildAppBar() : null,
      body: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.zero,
        itemCount: _postData.length + 1, // +1 是因为有头部
        itemBuilder: (context, index) {
          if (index == 0) {
            // 头部
            return _buildHeader();
          } else {
            // 列表项 - 传递负载类型给PostItem，让它在内部处理负载逻辑
            final post = _postData[index - 1];
            return PostItem(
              post: post,
              loadType: widget.loadType, // 传递负载类型
            );
          }
        },
      ),
    );
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
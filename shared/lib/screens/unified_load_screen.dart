import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import '../constants.dart';
import '../data/data_center.dart';
import '../models/post_model.dart';
import '../widgets/post_item.dart';
import '../widgets/friend_circle_header.dart';
import '../widgets/paint_load_painter.dart';
import '../utils/load_calculator.dart';

const String _renderMode =
    String.fromEnvironment('RENDER_MODE', defaultValue: 'SurfaceView');

/// Unified Load Test Screen
///
/// 对齐原生 LoadScheduler:
/// 1. 滚动阶段感知 - 按压拖动不加负载，仅惯性滑动执行负载
/// 2. 生命周期管理 - 恢复时重置随机状态
/// 3. PostFrame 负载通过 addPostFrameCallback 持续调度
class UnifiedLoadScreen extends StatefulWidget {
  final int loadType;

  const UnifiedLoadScreen({
    Key? key,
    required this.loadType,
  }) : super(key: key);

  @override
  State<UnifiedLoadScreen> createState() => _UnifiedLoadScreenState();
}

class _UnifiedLoadScreenState extends State<UnifiedLoadScreen> {
  late List<PostModel> _postData;
  late ScrollController _scrollController;
  final LoadCalculator _loadCalculator = LoadCalculator();
  bool _showAppBar = false;
  bool _isPostFrameScheduled = false;

  @override
  void initState() {
    super.initState();

    // 每次进入重置随机状态（对齐原生 onResume 重置）
    _loadCalculator.resetState();

    // Clear cached data to ensure fresh generation for each test
    DataCenter().clearCachedData();

    // Get friend circle data for the load type
    final friendCircleData =
        DataCenter().getFriendCircleDataForLoadType(widget.loadType);
    _postData = friendCircleData
        .map((fc) => PostModel.fromFriendCircleModel(fc))
        .toList();

    // Initialize scroll controller
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);

    // Start PostFrame load if needed
    _schedulePostFrameLoadIfNeeded();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _isPostFrameScheduled = false;
    // 退出时重置滚动阶段
    _loadCalculator.setScrollPhase(LoadScrollPhase.idle);
    super.dispose();
  }

  /// Schedule PostFrame load if needed
  void _schedulePostFrameLoadIfNeeded() {
    if (_isPostFrameScheduled) return;

    final isPostFrameType =
        widget.loadType >= Constants.LOAD_TYPE_POSTFRAME_LIGHT &&
            widget.loadType <= Constants.LOAD_TYPE_POSTFRAME_HEAVY;
    final isMixedType = widget.loadType >= Constants.LOAD_TYPE_MIXED_LIGHT &&
        widget.loadType <= Constants.LOAD_TYPE_MIXED_HEAVY;

    if (isPostFrameType || isMixedType) {
      _isPostFrameScheduled = true;
      _scheduleNextPostFrameLoad();
    }
  }

  /// Schedule next frame's PostFrame load
  void _scheduleNextPostFrameLoad() {
    if (!_isPostFrameScheduled || !mounted) return;

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // 负载执行（内部已包含惯性滑动 gating + 概率触发 + 帧间隔控制）
      _loadCalculator.performPostFrameLoad(widget.loadType);

      // Continue scheduling next frame
      _scheduleNextPostFrameLoad();
    });
  }

  /// Scroll listener - 只负责 UI 展示，不参与负载阶段判断
  void _scrollListener() {
    // Check if AppBar should be shown
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

  void _setLoadScrollPhase(LoadScrollPhase phase) {
    final wasLoadActive = _loadCalculator.isInertialScrolling;
    final changed = _loadCalculator.setScrollPhase(phase);
    final isLoadActive = _loadCalculator.isInertialScrolling;
    if (changed &&
        wasLoadActive != isLoadActive &&
        mounted &&
        _loadCalculator.isPaintLoadType(widget.loadType)) {
      setState(() {});
    }
  }

  /// 处理滚动通知：按压拖动阶段不加负载，松手后的惯性滑动才加负载
  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is UserScrollNotification &&
        notification.direction == ScrollDirection.idle) {
      _setLoadScrollPhase(LoadScrollPhase.idle);
      return false;
    }

    if (notification is ScrollStartNotification) {
      _setLoadScrollPhase(
        notification.dragDetails == null
            ? LoadScrollPhase.inertial
            : LoadScrollPhase.dragging,
      );
    } else if (notification is ScrollUpdateNotification) {
      _setLoadScrollPhase(
        notification.dragDetails == null
            ? LoadScrollPhase.inertial
            : LoadScrollPhase.dragging,
      );
    } else if (notification is OverscrollNotification) {
      _setLoadScrollPhase(
        notification.dragDetails == null
            ? LoadScrollPhase.inertial
            : LoadScrollPhase.dragging,
      );
    } else if (notification is ScrollEndNotification) {
      _setLoadScrollPhase(LoadScrollPhase.idle);
    }
    return false; // 不拦截通知
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      extendBodyBehindAppBar: true,
      appBar: _showAppBar ? _buildAppBar() : null,
      body: Column(
        children: [
          // Load type indicator bar
          _buildLoadTypeIndicator(),
          // Main content
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: _handleScrollNotification,
              child: _buildMainContent(),
            ),
          ),
        ],
      ),
    );
  }

  /// Build load type indicator bar
  Widget _buildLoadTypeIndicator() {
    final loadTypeName = Constants.getLoadTypeName(widget.loadType);
    final categoryName = Constants.getLoadCategoryName(widget.loadType);
    final color = Color(Constants.getLoadTypeColor(widget.loadType));

    IconData icon;
    if (widget.loadType == Constants.LOAD_TYPE_MINIMAL) {
      icon = Icons.speed;
    } else if (_loadCalculator.isPaintLoadType(widget.loadType)) {
      icon = Icons.brush;
    } else if (widget.loadType >= Constants.LOAD_TYPE_POSTFRAME_LIGHT &&
        widget.loadType <= Constants.LOAD_TYPE_POSTFRAME_HEAVY) {
      icon = Icons.schedule;
    } else if (_loadCalculator.isMixedLoadType(widget.loadType)) {
      icon = Icons.merge_type;
    } else {
      icon = Icons.memory;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    loadTypeName,
                    style: TextStyle(
                      fontSize: 14,
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    categoryName,
                    style: TextStyle(
                      fontSize: 11,
                      color: color.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                _renderMode,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build main content
  Widget _buildMainContent() {
    Widget content = ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.zero,
      itemCount: _postData.length + 1, // +1 for header
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildHeader();
        } else {
          final post = _postData[index - 1];
          return _buildPostItem(post, index - 1);
        }
      },
    );

    // Add Paint load layer for Paint load types
    if (_loadCalculator.isPaintLoadType(widget.loadType)) {
      content = AnimatedPaintLoadWidget(
        loadType: widget.loadType,
        isActive: _loadCalculator.isInertialScrolling,
        child: content,
      );
    }

    return content;
  }

  /// Build post item (with load calculation)
  Widget _buildPostItem(PostModel post, int index) {
    // For Build and Mixed load types, use PostItem with load
    if (_loadCalculator.isBuildLoadType(widget.loadType)) {
      return PostItemWithLoad(
        post: post,
        loadType: widget.loadType,
      );
    } else {
      // Other types use regular PostItem
      return PostItem(
        post: post,
        loadType: null, // No load in PostItem
      );
    }
  }

  /// Build AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        Constants.getLoadTypeName(widget.loadType),
        style: const TextStyle(
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

  /// Build header view
  Widget _buildHeader() {
    return FriendCircleHeader(
      title: Constants.getLoadTypeName(widget.loadType),
      backgroundColor: Color(Constants.getLoadTypeColor(widget.loadType)),
      onBackPressed: () => Navigator.pop(context),
    );
  }
}

/// PostItem with load calculation
class PostItemWithLoad extends StatelessWidget {
  final PostModel post;
  final int loadType;

  const PostItemWithLoad({
    Key? key,
    required this.post,
    required this.loadType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 执行 Build 负载（内部已包含惯性滑动 gating + 概率触发 + 帧间隔控制）
    LoadCalculator().performBuildLoad(loadType);

    // Use PostItem for rendering
    return PostItem(
      post: post,
      loadType: null,
    );
  }
}

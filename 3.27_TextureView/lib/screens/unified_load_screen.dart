import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../constants.dart';
import '../data/data_center.dart';
import '../models/post_model.dart';
import '../widgets/post_item.dart';
import '../widgets/friend_circle_header.dart';
import '../widgets/paint_load_painter.dart';
import '../utils/load_calculator.dart';

/// Unified Load Test Screen (TextureView Version)
/// 
/// Supports all 13 load types:
/// - Minimal: No load
/// - Build (Light/Medium/Heavy): In-frame Build phase CPU load
/// - Paint (Light/Medium/Heavy): In-frame Paint phase GPU load
/// - PostFrame (Light/Medium/Heavy): Between-frame CPU load
/// - Mixed (Light/Medium/Heavy): Combined load (Build + PostFrame)
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
    
    // Clear cached data to ensure fresh generation for each test
    DataCenter().clearCachedData();
    
    // Get friend circle data for the load type
    final friendCircleData = DataCenter().getFriendCircleDataForLoadType(widget.loadType);
    _postData = friendCircleData.map((fc) => PostModel.fromFriendCircleModel(fc)).toList();
    
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
    super.dispose();
  }

  /// Schedule PostFrame load if needed
  void _schedulePostFrameLoadIfNeeded() {
    if (_isPostFrameScheduled) return;
    
    final isPostFrameType = widget.loadType >= Constants.LOAD_TYPE_POSTFRAME_LIGHT &&
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
      
      // Execute PostFrame load calculation
      _loadCalculator.performPostFrameLoad(widget.loadType);
      
      // Continue scheduling next frame
      _scheduleNextPostFrameLoad();
    });
  }

  /// Scroll listener
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
            child: _buildMainContent(),
          ),
        ],
      ),
    );
  }

  /// Build load type indicator bar - TextureView version
  Widget _buildLoadTypeIndicator() {
    final loadTypeName = Constants.getLoadTypeName(widget.loadType);
    final categoryName = Constants.getLoadCategoryName(widget.loadType);
    
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
        color: Colors.blue.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: Colors.blue.withOpacity(0.3),
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    loadTypeName,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '$categoryName | TextureView Rendering',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.blue.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue.shade700,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'TextureView',
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
    // Execute load calculation during build
    LoadCalculator().performBuildLoad(loadType);
    
    // Use PostItem for rendering, load already executed here
    return PostItem(
      post: post,
      loadType: null, // Don't pass loadType to avoid duplicate calculation
    );
  }
}

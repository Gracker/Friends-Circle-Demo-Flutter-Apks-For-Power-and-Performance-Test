/// 定义应用中使用的常量
class Constants {
  /// 负载类型常量
  static const int LOAD_TYPE_LIGHT = 0;  // 轻负载
  static const int LOAD_TYPE_MEDIUM = 1; // 中负载
  static const int LOAD_TYPE_HEAVY = 2;  // 重负载

  /// 颜色常量
  static const int COLOR_PRIMARY = 0xFF1976D2; // 主题色
  static const int COLOR_ACCENT = 0xFF009688;  // 强调色
  static const int COLOR_HEAVY = 0xFF673AB7;   // 重负载色
  static const int COLOR_BACKGROUND = 0xFFF2F2F2; // 背景色
  static const int COLOR_TEXT_PRIMARY = 0xFF333333; // 主文本色
  static const int COLOR_TEXT_SECONDARY = 0xFF666666; // 次文本色
  static const int COLOR_TEXT_HINT = 0xFF999999; // 提示文本色

  /// 列表项数量常量
  static const int FRIEND_CIRCLE_COUNT = 100; // 朋友圈数据条数
  
  /// 列表滑动负载相关常量
  static const int LIGHT_LOAD_COMMENT_MAX = 3;    // 轻负载评论最大数量
  static const int MEDIUM_LOAD_COMMENT_MAX = 12;  // 中负载评论最大数量
  static const int HEAVY_LOAD_COMMENT_MAX = 25;   // 重负载评论最大数量
  
  static const int LIGHT_LOAD_PRAISE_MAX = 5;    // 轻负载点赞最大数量
  static const int MEDIUM_LOAD_PRAISE_MAX = 15;   // 中负载点赞最大数量
  static const int HEAVY_LOAD_PRAISE_MAX = 30;    // 重负载点赞最大数量
  
  static const int LIGHT_LOAD_COMPUTE_ITERATIONS = 5000;     // 轻负载计算迭代次数
  static const int MEDIUM_LOAD_COMPUTE_ITERATIONS = 50000;   // 中负载计算迭代次数
  static const int HEAVY_LOAD_COMPUTE_ITERATIONS = 500000;   // 重负载计算迭代次数
  
  /// 随机数种子常量，确保每次生成相同的随机数
  static const int RANDOM_SEED = 42;
  
  /// 图片相关常量
  static const int LIGHT_LOAD_IMAGE_MAX = 4;    // 轻负载图片最大数量 
  static const int MEDIUM_LOAD_IMAGE_MAX = 6;   // 中负载图片最大数量
  static const int HEAVY_LOAD_IMAGE_MAX = 9;    // 重负载图片最大数量
} 
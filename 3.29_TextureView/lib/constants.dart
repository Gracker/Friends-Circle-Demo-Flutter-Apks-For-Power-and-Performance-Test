/// Constants used throughout the application
class Constants {
  /// ========== Load Type Constants ==========
  /// 
  /// Load type categories:
  /// 1. Minimal Load - No extra computation, serves as performance baseline
  /// 2. Build Load (In-Frame) - Computation in Widget.build(), affects UI thread
  /// 3. Paint Load (In-Frame) - Computation in CustomPainter.paint(), generates GPU load
  /// 4. PostFrame Load (Between-Frames) - Computation after frame rendering
  /// 5. Mixed Load - Combines Build and PostFrame loads
  
  // Minimal Load
  static const int LOAD_TYPE_MINIMAL = 0;      // Minimal load - no extra computation
  
  // Build Phase Load (In-Frame - executed during Widget building)
  static const int LOAD_TYPE_BUILD_LIGHT = 1;   // Build light load
  static const int LOAD_TYPE_BUILD_MEDIUM = 2;  // Build medium load
  static const int LOAD_TYPE_BUILD_HEAVY = 3;   // Build heavy load
  
  // Paint Phase Load (In-Frame - executed during painting, GPU load)
  static const int LOAD_TYPE_PAINT_LIGHT = 4;   // Paint light load
  static const int LOAD_TYPE_PAINT_MEDIUM = 5;  // Paint medium load
  static const int LOAD_TYPE_PAINT_HEAVY = 6;   // Paint heavy load
  
  // PostFrame Load (Between-Frames - executed after frame rendering)
  static const int LOAD_TYPE_POSTFRAME_LIGHT = 7;   // PostFrame light load
  static const int LOAD_TYPE_POSTFRAME_MEDIUM = 8;  // PostFrame medium load
  static const int LOAD_TYPE_POSTFRAME_HEAVY = 9;   // PostFrame heavy load
  
  // Mixed Load (Combines Build and PostFrame loads)
  static const int LOAD_TYPE_MIXED_LIGHT = 10;   // Mixed light load
  static const int LOAD_TYPE_MIXED_MEDIUM = 11;  // Mixed medium load
  static const int LOAD_TYPE_MIXED_HEAVY = 12;   // Mixed heavy load

  /// Legacy compatibility (mapped to new Build load types)
  static const int LOAD_TYPE_LIGHT = LOAD_TYPE_BUILD_LIGHT;
  static const int LOAD_TYPE_MEDIUM = LOAD_TYPE_BUILD_MEDIUM;
  static const int LOAD_TYPE_HEAVY = LOAD_TYPE_BUILD_HEAVY;

  /// ========== Color Constants ==========
  static const int COLOR_PRIMARY = 0xFF1976D2;      // Primary color - Blue
  static const int COLOR_ACCENT = 0xFF009688;       // Accent color - Teal
  static const int COLOR_HEAVY = 0xFF673AB7;        // Heavy load color - Purple
  static const int COLOR_BACKGROUND = 0xFFF2F2F2;   // Background color
  static const int COLOR_TEXT_PRIMARY = 0xFF333333; // Primary text color
  static const int COLOR_TEXT_SECONDARY = 0xFF666666; // Secondary text color
  static const int COLOR_TEXT_HINT = 0xFF999999;    // Hint text color
  
  // New load type colors
  static const int COLOR_MINIMAL = 0xFF9E9E9E;      // Minimal load - Gray
  static const int COLOR_PAINT = 0xFFE91E63;        // Paint load - Pink
  static const int COLOR_POSTFRAME = 0xFFFF9800;    // PostFrame load - Orange
  static const int COLOR_MIXED = 0xFF795548;        // Mixed load - Brown

  /// ========== List Item Count Constants ==========
  static const int FRIEND_CIRCLE_COUNT = 100; // Number of friend circle items
  
  /// ========== Build Load Constants ==========
  static const int BUILD_LIGHT_ITERATIONS = 10;        // Build light load iterations
  static const int BUILD_MEDIUM_ITERATIONS = 2000;     // Build medium load iterations
  static const int BUILD_HEAVY_ITERATIONS = 20000;     // Build heavy load iterations
  
  /// ========== Paint Load Constants ==========
  static const int PAINT_LIGHT_SHAPES = 50;           // Paint light load shape count
  static const int PAINT_MEDIUM_SHAPES = 200;         // Paint medium load shape count
  static const int PAINT_HEAVY_SHAPES = 800;          // Paint heavy load shape count
  
  static const int PAINT_LIGHT_PATH_POINTS = 10;      // Paint light load path points
  static const int PAINT_MEDIUM_PATH_POINTS = 50;     // Paint medium load path points
  static const int PAINT_HEAVY_PATH_POINTS = 200;     // Paint heavy load path points
  
  /// ========== PostFrame Load Constants ==========
  static const int POSTFRAME_LIGHT_ITERATIONS = 5000;     // PostFrame light load iterations
  static const int POSTFRAME_MEDIUM_ITERATIONS = 50000;   // PostFrame medium load iterations
  static const int POSTFRAME_HEAVY_ITERATIONS = 200000;   // PostFrame heavy load iterations
  
  /// ========== Mixed Load Constants ==========
  // Mixed Load = Build Load (50%) + PostFrame Load (50%)
  static const int MIXED_BUILD_LIGHT_ITERATIONS = 5;          // Mixed-Build light load
  static const int MIXED_BUILD_MEDIUM_ITERATIONS = 1000;      // Mixed-Build medium load
  static const int MIXED_BUILD_HEAVY_ITERATIONS = 10000;      // Mixed-Build heavy load
  
  static const int MIXED_POSTFRAME_LIGHT_ITERATIONS = 2500;   // Mixed-PostFrame light load
  static const int MIXED_POSTFRAME_MEDIUM_ITERATIONS = 25000; // Mixed-PostFrame medium load
  static const int MIXED_POSTFRAME_HEAVY_ITERATIONS = 100000; // Mixed-PostFrame heavy load
  
  /// ========== List Scroll Load Constants (for data generation) ==========
  static const int LIGHT_LOAD_COMMENT_MAX = 3;    // Light load max comments
  static const int MEDIUM_LOAD_COMMENT_MAX = 12;  // Medium load max comments
  static const int HEAVY_LOAD_COMMENT_MAX = 25;   // Heavy load max comments
  
  static const int LIGHT_LOAD_PRAISE_MAX = 5;     // Light load max likes
  static const int MEDIUM_LOAD_PRAISE_MAX = 15;   // Medium load max likes
  static const int HEAVY_LOAD_PRAISE_MAX = 30;    // Heavy load max likes
  
  static const int LIGHT_LOAD_COMPUTE_ITERATIONS = 5000;     // Light load compute iterations
  static const int MEDIUM_LOAD_COMPUTE_ITERATIONS = 50000;   // Medium load compute iterations
  static const int HEAVY_LOAD_COMPUTE_ITERATIONS = 500000;   // Heavy load compute iterations
  
  /// ========== Random Seed Constants ==========
  static const int RANDOM_SEED = 42; // Ensures consistent random number generation
  
  /// ========== Image Constants ==========
  static const int LIGHT_LOAD_IMAGE_MAX = 4;    // Light load max images
  static const int MEDIUM_LOAD_IMAGE_MAX = 6;   // Medium load max images
  static const int HEAVY_LOAD_IMAGE_MAX = 9;    // Heavy load max images
  
  /// ========== Helper Methods ==========
  
  /// Get load type display name
  static String getLoadTypeName(int loadType) {
    switch (loadType) {
      case LOAD_TYPE_MINIMAL:
        return 'Minimal';
      case LOAD_TYPE_BUILD_LIGHT:
        return 'Build Light';
      case LOAD_TYPE_BUILD_MEDIUM:
        return 'Build Medium';
      case LOAD_TYPE_BUILD_HEAVY:
        return 'Build Heavy';
      case LOAD_TYPE_PAINT_LIGHT:
        return 'Paint Light';
      case LOAD_TYPE_PAINT_MEDIUM:
        return 'Paint Medium';
      case LOAD_TYPE_PAINT_HEAVY:
        return 'Paint Heavy';
      case LOAD_TYPE_POSTFRAME_LIGHT:
        return 'PostFrame Light';
      case LOAD_TYPE_POSTFRAME_MEDIUM:
        return 'PostFrame Medium';
      case LOAD_TYPE_POSTFRAME_HEAVY:
        return 'PostFrame Heavy';
      case LOAD_TYPE_MIXED_LIGHT:
        return 'Mixed Light';
      case LOAD_TYPE_MIXED_MEDIUM:
        return 'Mixed Medium';
      case LOAD_TYPE_MIXED_HEAVY:
        return 'Mixed Heavy';
      default:
        return 'Unknown';
    }
  }
  
  /// Get load type short name (for ADB launch)
  static String getLoadTypeShortName(int loadType) {
    switch (loadType) {
      case LOAD_TYPE_MINIMAL:
        return 'minimal';
      case LOAD_TYPE_BUILD_LIGHT:
        return 'build_light';
      case LOAD_TYPE_BUILD_MEDIUM:
        return 'build_medium';
      case LOAD_TYPE_BUILD_HEAVY:
        return 'build_heavy';
      case LOAD_TYPE_PAINT_LIGHT:
        return 'paint_light';
      case LOAD_TYPE_PAINT_MEDIUM:
        return 'paint_medium';
      case LOAD_TYPE_PAINT_HEAVY:
        return 'paint_heavy';
      case LOAD_TYPE_POSTFRAME_LIGHT:
        return 'postframe_light';
      case LOAD_TYPE_POSTFRAME_MEDIUM:
        return 'postframe_medium';
      case LOAD_TYPE_POSTFRAME_HEAVY:
        return 'postframe_heavy';
      case LOAD_TYPE_MIXED_LIGHT:
        return 'mixed_light';
      case LOAD_TYPE_MIXED_MEDIUM:
        return 'mixed_medium';
      case LOAD_TYPE_MIXED_HEAVY:
        return 'mixed_heavy';
      default:
        return 'unknown';
    }
  }
  
  /// Parse load type from short name
  static int parseLoadType(String? shortName) {
    switch (shortName) {
      case 'minimal':
        return LOAD_TYPE_MINIMAL;
      case 'build_light':
      case 'light':  // Legacy compatibility
        return LOAD_TYPE_BUILD_LIGHT;
      case 'build_medium':
      case 'medium':  // Legacy compatibility
        return LOAD_TYPE_BUILD_MEDIUM;
      case 'build_heavy':
      case 'heavy':  // Legacy compatibility
        return LOAD_TYPE_BUILD_HEAVY;
      case 'paint_light':
        return LOAD_TYPE_PAINT_LIGHT;
      case 'paint_medium':
        return LOAD_TYPE_PAINT_MEDIUM;
      case 'paint_heavy':
        return LOAD_TYPE_PAINT_HEAVY;
      case 'postframe_light':
        return LOAD_TYPE_POSTFRAME_LIGHT;
      case 'postframe_medium':
        return LOAD_TYPE_POSTFRAME_MEDIUM;
      case 'postframe_heavy':
        return LOAD_TYPE_POSTFRAME_HEAVY;
      case 'mixed_light':
        return LOAD_TYPE_MIXED_LIGHT;
      case 'mixed_medium':
        return LOAD_TYPE_MIXED_MEDIUM;
      case 'mixed_heavy':
        return LOAD_TYPE_MIXED_HEAVY;
      default:
        return -1;  // Return -1 for unknown, show home page
    }
  }
  
  /// Get load type color
  static int getLoadTypeColor(int loadType) {
    switch (loadType) {
      case LOAD_TYPE_MINIMAL:
        return COLOR_MINIMAL;
      case LOAD_TYPE_BUILD_LIGHT:
      case LOAD_TYPE_BUILD_MEDIUM:
      case LOAD_TYPE_BUILD_HEAVY:
        return COLOR_PRIMARY;
      case LOAD_TYPE_PAINT_LIGHT:
      case LOAD_TYPE_PAINT_MEDIUM:
      case LOAD_TYPE_PAINT_HEAVY:
        return COLOR_PAINT;
      case LOAD_TYPE_POSTFRAME_LIGHT:
      case LOAD_TYPE_POSTFRAME_MEDIUM:
      case LOAD_TYPE_POSTFRAME_HEAVY:
        return COLOR_POSTFRAME;
      case LOAD_TYPE_MIXED_LIGHT:
      case LOAD_TYPE_MIXED_MEDIUM:
      case LOAD_TYPE_MIXED_HEAVY:
        return COLOR_MIXED;
      default:
        return COLOR_PRIMARY;
    }
  }
  
  /// Get load category name
  static String getLoadCategoryName(int loadType) {
    if (loadType == LOAD_TYPE_MINIMAL) {
      return 'Baseline';
    } else if (loadType >= LOAD_TYPE_BUILD_LIGHT && loadType <= LOAD_TYPE_BUILD_HEAVY) {
      return 'Build Load (In-Frame)';
    } else if (loadType >= LOAD_TYPE_PAINT_LIGHT && loadType <= LOAD_TYPE_PAINT_HEAVY) {
      return 'Paint Load (In-Frame GPU)';
    } else if (loadType >= LOAD_TYPE_POSTFRAME_LIGHT && loadType <= LOAD_TYPE_POSTFRAME_HEAVY) {
      return 'PostFrame Load (Between-Frames)';
    } else if (loadType >= LOAD_TYPE_MIXED_LIGHT && loadType <= LOAD_TYPE_MIXED_HEAVY) {
      return 'Mixed Load (Combined)';
    }
    return 'Unknown Category';
  }
}

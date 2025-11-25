import 'package:flutter/material.dart';
import '../constants.dart';
import '../data/data_center.dart';
import 'unified_load_screen.dart';

/// Home screen for selecting different load levels (TextureView Version)
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              
              // Title
              const Text(
                'Flutter V3.27',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
                textAlign: TextAlign.center,
              ),
              const Text(
                'Performance & Power Test Demo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF666666),
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 8),
              
              // Version info - TextureView
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.texture, size: 14, color: Colors.blue.shade700),
                    const SizedBox(width: 4),
                    Text(
                      '13 Load Types | TextureView Rendering',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // ========== Baseline Load ==========
              _buildSectionTitle('Baseline Load', Icons.speed, const Color(0xFF9E9E9E)),
              _buildLoadCard(
                context,
                loadTypes: [Constants.LOAD_TYPE_MINIMAL],
                description: 'No extra computation, serves as performance baseline',
              ),
              
              const SizedBox(height: 16),
              
              // ========== Build Load (In-Frame) ==========
              _buildSectionTitle('Build Load (In-Frame)', Icons.memory, const Color(0xFF1976D2)),
              _buildLoadCard(
                context,
                loadTypes: [
                  Constants.LOAD_TYPE_BUILD_LIGHT,
                  Constants.LOAD_TYPE_BUILD_MEDIUM,
                  Constants.LOAD_TYPE_BUILD_HEAVY,
                ],
                description: 'CPU computation during Widget.build() phase',
              ),
              
              const SizedBox(height: 16),
              
              // ========== Paint Load (In-Frame GPU) ==========
              _buildSectionTitle('Paint Load (In-Frame GPU)', Icons.brush, const Color(0xFFE91E63)),
              _buildLoadCard(
                context,
                loadTypes: [
                  Constants.LOAD_TYPE_PAINT_LIGHT,
                  Constants.LOAD_TYPE_PAINT_MEDIUM,
                  Constants.LOAD_TYPE_PAINT_HEAVY,
                ],
                description: 'Complex shape drawing in CustomPainter.paint() phase',
              ),
              
              const SizedBox(height: 16),
              
              // ========== PostFrame Load (Between-Frames) ==========
              _buildSectionTitle('PostFrame Load (Between-Frames)', Icons.schedule, const Color(0xFFFF9800)),
              _buildLoadCard(
                context,
                loadTypes: [
                  Constants.LOAD_TYPE_POSTFRAME_LIGHT,
                  Constants.LOAD_TYPE_POSTFRAME_MEDIUM,
                  Constants.LOAD_TYPE_POSTFRAME_HEAVY,
                ],
                description: 'Computation via callback after frame rendering',
              ),
              
              const SizedBox(height: 16),
              
              // ========== Mixed Load (Combined) ==========
              _buildSectionTitle('Mixed Load (Combined)', Icons.merge_type, const Color(0xFF795548)),
              _buildLoadCard(
                context,
                loadTypes: [
                  Constants.LOAD_TYPE_MIXED_LIGHT,
                  Constants.LOAD_TYPE_MIXED_MEDIUM,
                  Constants.LOAD_TYPE_MIXED_HEAVY,
                ],
                description: 'Combines Build and PostFrame loads',
              ),
              
              const SizedBox(height: 24),
              
              // Info card
              _buildInfoCard(),
              
              const SizedBox(height: 16),
              
              // Copyright
              const Text(
                '© 2025 Friends Circle Performance Test',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF999999),
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  /// Build section title
  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// Build load card
  Widget _buildLoadCard(
    BuildContext context, {
    required List<int> loadTypes,
    required String description,
  }) {
    final color = Color(Constants.getLoadTypeColor(loadTypes.first));
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Description text
            Text(
              description,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF666666),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Load buttons
            if (loadTypes.length == 1)
              // Single button (Minimal)
              _buildSingleButton(context, loadTypes.first, color)
            else
              // Multiple buttons (Light/Medium/Heavy)
              Row(
                children: [
                  Expanded(
                    child: _buildLevelButton(context, loadTypes[0], 'Light', color.withOpacity(0.7)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildLevelButton(context, loadTypes[1], 'Medium', color),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildLevelButton(context, loadTypes[2], 'Heavy', color.withOpacity(1.3).withRed((color.red * 0.8).toInt())),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  /// Build single button
  Widget _buildSingleButton(BuildContext context, int loadType, Color color) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () => _navigateToLoadScreen(context, loadType),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 1,
        ),
        child: Text(
          Constants.getLoadTypeName(loadType),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// Build level button
  Widget _buildLevelButton(BuildContext context, int loadType, String level, Color color) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: () => _navigateToLoadScreen(context, loadType),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 1,
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
        child: Text(
          level,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Build info card
  Widget _buildInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.texture, size: 20, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  'TextureView Rendering Mode',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'This version uses Flutter official FlutterTextureView rendering, '
              'based on Android TextureView, allowing free composition with other View hierarchies.',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Build Load', 'CPU computation during Widget build phase'),
            _buildInfoRow('Paint Load', 'Complex drawing in paint phase, generates GPU load'),
            _buildInfoRow('PostFrame Load', 'Executes after frame rendering'),
            _buildInfoRow('Mixed Load', 'Combines Build(50%)+PostFrame(50%) loads'),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'ADB Quick Launch:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'adb shell am start -n com.example.friendscircle.v27.textureview/.MainActivity -e "load" "build_heavy"',
                style: TextStyle(
                  fontSize: 10,
                  fontFamily: 'monospace',
                  color: Color(0xFF666666),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build info row
  Widget _buildInfoRow(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$title:',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF333333),
              ),
            ),
          ),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF666666),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Navigate to load test screen
  void _navigateToLoadScreen(BuildContext context, int loadType) {
    // Clear cached data to ensure fresh generation for each test
    DataCenter().clearCachedData();
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UnifiedLoadScreen(loadType: loadType),
      ),
    );
  }
}

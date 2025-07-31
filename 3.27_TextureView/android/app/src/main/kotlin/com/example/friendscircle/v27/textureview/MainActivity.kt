package com.example.friendscircle.v27.textureview

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.RenderMode
import io.flutter.embedding.engine.FlutterEngine

/**
 * 使用TextureView渲染模式的MainActivity
 * 
 * 关键实现：
 * 1. 重写getRenderMode()返回RenderMode.texture
 * 2. 这样Flutter会使用FlutterTextureView而不是FlutterSurfaceView进行渲染
 * 3. FlutterTextureView继承自Android原生TextureView，在SurfaceTexture上绘制Flutter UI
 */
class MainActivity: FlutterActivity() {
    
    /**
     * 重写getRenderMode方法，指定使用TextureView渲染模式
     * 
     * 根据Flutter官方文档：
     * - RenderMode.surface：使用FlutterSurfaceView（基于SurfaceView，默认模式）
     * - RenderMode.texture：使用FlutterTextureView（基于TextureView）
     * 
     * FlutterTextureView的特点：
     * - 继承自TextureView，在SurfaceTexture上绘制Flutter UI
     * - 可以像普通View一样参与View层级、动画、变换等
     * - 图像数据会被重新绘制到Canvas上，多了一个渲染步骤
     * - 适合复杂视图层级和动画场景
     */
    override fun getRenderMode(): RenderMode {
        return RenderMode.texture
    }
}

package io.flutter.plugin.common;

import io.flutter.embedding.engine.plugins.FlutterPlugin;

/**
 * 兼容性接口，用于处理高德地图SDK中的PluginRegistry.Registrar引用
 * 这是因为在较新版本的Flutter中，此接口的实现已更改
 */
public interface PluginRegistry {
    
    /**
     * 兼容性内部接口
     */
    interface Registrar {
        FlutterPlugin.FlutterPluginBinding getFlutterPluginBinding();
    }
} 
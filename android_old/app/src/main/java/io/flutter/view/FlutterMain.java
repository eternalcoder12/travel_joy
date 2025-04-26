package io.flutter.view;

import io.flutter.FlutterInjector;

/**
 * 兼容性类，用于处理高德地图SDK中的FlutterMain引用
 * 这是因为在较新版本的Flutter中，FlutterMain已被移除
 */
public class FlutterMain {
    
    public static String getLookupKeyForAsset(String asset) {
        return FlutterInjector.instance().flutterLoader().getLookupKeyForAsset(asset);
    }
    
    public static String getLookupKeyForAsset(String asset, String packageName) {
        return FlutterInjector.instance().flutterLoader().getLookupKeyForAsset(asset, packageName);
    }
} 
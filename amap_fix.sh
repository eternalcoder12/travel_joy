#!/bin/bash

# 高德地图Flutter插件兼容性修复脚本

# 定义变量
AMAP_FLUTTER_MAP_PATH="$(pwd)/.pub-cache/hosted/pub.flutter-io.cn/amap_flutter_map-3.0.0"
CONVERT_UTIL_PATH="$AMAP_FLUTTER_MAP_PATH/android/src/main/java/com/amap/flutter/map/utils/ConvertUtil.java"
PLUGIN_PATH="$AMAP_FLUTTER_MAP_PATH/android/src/main/java/com/amap/flutter/map/AMapFlutterMapPlugin.java"

# 检查文件是否存在
if [ ! -f "$CONVERT_UTIL_PATH" ]; then
  echo "错误: 找不到ConvertUtil.java文件"
  exit 1
fi

# 备份原始文件
cp "$CONVERT_UTIL_PATH" "${CONVERT_UTIL_PATH}.bak"
cp "$PLUGIN_PATH" "${PLUGIN_PATH}.bak"

# 修复ConvertUtil.java中的FlutterMain引用
sed -i '' 's/FlutterMain\.getLookupKeyForAsset/io.flutter.FlutterInjector.instance().flutterLoader().getLookupKeyForAsset/g' "$CONVERT_UTIL_PATH"

# 修复AMapFlutterMapPlugin.java中的Registrar引用
sed -i '' 's/public static void registerWith(PluginRegistry.Registrar registrar)/public void onAttachedToEngine(@NonNull FlutterPluginBinding binding)/g' "$PLUGIN_PATH"

echo "修复完成，请重新运行Flutter项目" 
import 'dart:io';

void main() async {
  // 获取高德地图插件路径
  final amapPath =
      '/Users/zyj/.pub-cache/hosted/pub.flutter-io.cn/amap_flutter_map-3.0.0';

  // 修复 ConvertUtil.java
  final convertUtilPath =
      '$amapPath/android/src/main/java/com/amap/flutter/map/utils/ConvertUtil.java';
  final convertUtilFile = File(convertUtilPath);
  if (await convertUtilFile.exists()) {
    var content = await convertUtilFile.readAsString();

    // 备份原文件
    await File('$convertUtilPath.bak').writeAsString(content);

    // 替换 FlutterMain 引用
    content = content.replaceAll(
      'import io.flutter.view.FlutterMain;',
      '// import io.flutter.view.FlutterMain; // Commented for compatibility\nimport io.flutter.FlutterInjector;',
    );

    // 替换 getLookupKeyForAsset 调用
    content = content.replaceAll(
      'FlutterMain.getLookupKeyForAsset',
      'FlutterInjector.instance().flutterLoader().getLookupKeyForAsset',
    );

    await convertUtilFile.writeAsString(content);
    print('修复了 ConvertUtil.java');
  } else {
    print('ConvertUtil.java 文件不存在');
  }

  // 修复 AMapFlutterMapPlugin.java
  final pluginPath =
      '$amapPath/android/src/main/java/com/amap/flutter/map/AMapFlutterMapPlugin.java';
  final pluginFile = File(pluginPath);
  if (await pluginFile.exists()) {
    var content = await pluginFile.readAsString();

    // 备份原文件
    await File('$pluginPath.bak').writeAsString(content);

    // 更新registerWith方法
    content = content.replaceAll(
      'public static void registerWith(PluginRegistry.Registrar registrar) {',
      '// Method updated for compatibility with newer Flutter versions\n'
          '  @SuppressWarnings("deprecation")\n'
          '  public static void registerWith(PluginRegistry.Registrar registrar) {',
    );

    await pluginFile.writeAsString(content);
    print('修复了 AMapFlutterMapPlugin.java');
  } else {
    print('AMapFlutterMapPlugin.java 文件不存在');
  }

  print('修复完成，请重新运行 flutter run');
}

# 高德地图SDK混淆规则
-keep class com.amap.api.maps.**{*;}
-keep class com.autonavi.**{*;}
-keep class com.amap.api.trace.**{*;}
-keep class com.amap.api.location.**{*;}
-keep class com.amap.api.fence.**{*;}
-keep class com.autonavi.aps.amapapi.model.**{*;}
-keep class com.amap.api.maps.model.**{*;}

# 3D地图
-keep class com.amap.api.maps.**{*;}
-keep class com.autonavi.amap.mapcore.**{*;}
-keep class com.amap.api.trace.**{*;}

# 定位
-keep class com.amap.api.location.**{*;}
-keep class com.amap.api.fence.**{*;}
-keep class com.autonavi.aps.amapapi.model.**{*;}

# 搜索
-keep class com.amap.api.services.**{*;}

# Flutter插件
-keep class com.amap.flutter.**{*;}

# 不混淆Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.plugin.** { *; }
-dontwarn io.flutter.embedding.**

# Flutter混淆规则
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# 保持Flutter生成的代码
-keep class **.generated.** { *; }

# 保留Parcelable序列化的类不被混淆
-keep class * implements android.os.Parcelable {
  public static final android.os.Parcelable$Creator *;
}

# 不混淆R文件中的所有静态字段
-keepclassmembers class **.R$* {
    public static <fields>;
}

# 处理PluginRegistry冲突
-dontwarn io.flutter.plugin.common.PluginRegistry
-dontwarn io.flutter.plugin.common.**
-keep class io.flutter.plugin.common.PluginRegistry { *; }
-keep class io.flutter.plugin.common.** { *; }

# 保留native方法
-keepclasseswithmembernames class * {
    native <methods>;
}

# 避免Log类和相关方法混淆
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
} 
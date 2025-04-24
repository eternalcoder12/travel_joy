# Travel Joy - 旅行社交应用

一款美观、功能丰富的旅行社交应用，帮助用户发现旅行目的地、分享旅行经历并与其他旅行爱好者建立联系。

![应用截图](screenshots/app_preview.png)

## 功能特点

- 精美的 UI 设计，带有流畅动画和过渡效果
- 个性化的旅行推荐
- 实时消息和通知系统
- 用户社区和分享功能
- 旅行计划和行程管理

## 安装与运行

### 前提条件

- Flutter SDK (最新稳定版)
- Dart SDK
- Android Studio / Xcode
- 支持的设备或模拟器

### 获取源代码

```bash
git clone https://github.com/yourusername/travel_joy.git
cd travel_joy
```

### 安装依赖

```bash
flutter pub get
```

### 运行应用

```bash
# 运行在连接的设备上
flutter run

# 或指定设备
flutter run -d "iPhone"
flutter run -d "Android Device"
```

## 开发指南

### 项目结构

```
lib/
├── app_theme.dart         # 应用主题定义
├── main.dart              # 应用入口
├── models/                # 数据模型
├── screens/               # 屏幕/页面
│   ├── home/              # 首页相关
│   ├── message/           # 消息页面
│   ├── chat/              # 聊天页面
│   ├── explore/           # 探索页面
│   └── profile/           # 个人资料页面
├── widgets/               # 可复用组件
├── services/              # 服务和API交互
└── utils/                 # 工具类
    └── navigation_utils.dart  # 页面导航动画工具
```

### 编码规范

- 遵循 [Effective Dart](https://dart.dev/guides/language/effective-dart) 编码规范
- 使用驼峰命名法 (camelCase) 命名变量和函数
- 类名使用大写字母开头的驼峰命名法 (PascalCase)
- 使用 `_` 前缀表示私有成员
- 保持代码整洁，添加必要的注释

### 特色工具

#### 导航动画工具 (NavigationUtils)

提供多种精美的页面切换动画效果，包括：

- 淡入淡出 (Fade)
- 滑动 (Slide)
- 缩放 (Scale)
- 旋转 (Rotation)
- 组合效果 (滑动+淡入淡出)
- 发光效果 (Glowing)
- 翻转效果 (水平/垂直)
- 模糊过渡 (Blur)

使用示例：

```dart
// 基本使用
NavigationUtils.navigateTo(
  context: context,
  page: DetailPage(),
  animationType: NavigationAnimationType.fade,
);

// 使用特定效果
NavigationUtils.fadeNavigateTo(
  context: context,
  page: DetailPage(),
);

NavigationUtils.glowingNavigateTo(
  context: context,
  page: DetailPage(),
);
```

## 发布指南

### Android 应用打包

1. 更新版本号：
   在 `pubspec.yaml` 文件中更新 `version` 字段。

2. 创建签名密钥库（如果尚未创建）：

   ```bash
   keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

3. 配置签名：
   在 `android/key.properties` 文件中配置您的签名信息。

4. 构建 APK：

   ```bash
   flutter build apk --release
   ```

   或构建 App Bundle：

   ```bash
   flutter build appbundle --release
   ```

5. 生成的 APK 位于：
   `build/app/outputs/flutter-apk/app-release.apk`

### iOS 应用打包

1. 更新版本号：
   在 `pubspec.yaml` 文件中更新 `version` 字段。

2. 构建 iOS 应用：

   ```bash
   flutter build ios --release
   ```

3. 使用 Xcode 打开项目：

   ```bash
   open ios/Runner.xcworkspace
   ```

4. 在 Xcode 中配置签名身份，选择"Product > Archive"创建归档文件。

5. 使用 Xcode 的"Distribute App"选项上传到 App Store Connect。

### 发布到 GitHub

1. 提交代码更改：

   ```bash
   git add .
   git commit -m "准备发布v1.0.0"
   git push origin main
   ```

2. 创建发布标签：

   ```bash
   git tag -a v1.0.0 -m "版本1.0.0"
   git push origin v1.0.0
   ```

3. 在 GitHub 上创建 Release，上传构建的 APK/IPA 文件。

## 贡献

欢迎提交问题(Issues)和拉取请求(Pull Requests)！

## 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件。

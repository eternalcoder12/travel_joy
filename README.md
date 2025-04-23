# Travel Joy 旅行应用

![Travel Joy](https://img.shields.io/badge/Travel%20Joy-1.0.0-blue)
![Flutter](https://img.shields.io/badge/Flutter-2.0+-blue)
![License](https://img.shields.io/badge/License-MIT-green)

一款为旅行爱好者提供景点发现、地图导航和预订服务的 Flutter 应用。

<p align="center">
  <img src="https://github.com/eternalcoder12/travel_joy/raw/main/screenshots/home.png" width="200" alt="首页预览"/>
  <img src="https://github.com/eternalcoder12/travel_joy/raw/main/screenshots/explore.png" width="200" alt="探索页预览"/>
  <img src="https://github.com/eternalcoder12/travel_joy/raw/main/screenshots/detail.png" width="200" alt="详情页预览"/>
</p>

## 📱 应用特性

Travel Joy 具有以下特性:

- 🏠 **首页**: 展示热门景点和各种功能入口，动画效果流畅
- 🔍 **探索页**: 固定顶部搜索区域，可滚动景点列表，一键切换地图视图
- 🏞️ **景点详情**: 高质量图片画廊、详细景点信息、设施服务和用户评论
- 🗺️ **地图功能**: 查看景点位置，支持地图/列表视图切换
- 📱 **预订功能**: 多种预订方式，包括地图导航、浏览器查询、微信小程序和第三方旅行应用
- ❤️ **收藏功能**: 一键收藏您喜欢的景点
- 🌙 **精美 UI**: 深色主题设计，流畅的动画效果，精心设计的细节

## 📲 安装指南

### Android 安装

1. 从 [Releases 页面](https://github.com/eternalcoder12/travel_joy/releases) 下载最新的 APK 文件
2. 在 Android 设备上打开 APK 文件进行安装
3. 如提示"未知来源"，请在设置中允许安装

### iOS 安装

1. 从 [Releases 页面](https://github.com/eternalcoder12/travel_joy/releases) 下载最新的 IPA 文件
2. 使用 TestFlight 安装测试版本（推荐）
3. 或使用开发者账号通过 Xcode 安装到设备上

### 从源码构建

```bash
# 克隆项目
git clone https://github.com/eternalcoder12/travel_joy.git

# 进入项目目录
cd travel_joy

# 获取依赖
flutter pub get

# 运行应用
flutter run
```

## ⚠️ 安装常见问题与解决方案

### Android 安装问题

1. **"未知来源"安装限制**

   - 问题：安装时提示"出于安全原因，您的手机已设置为禁止安装来自此来源的应用"
   - 解决方案：进入设置 > 安全 > 允许安装未知来源应用，或点击提示中的"设置"按钮直接进入相关选项

2. **"应用未经验证"警告**

   - 问题：安装时提示"此应用未经 Google Play 保护机制验证"
   - 解决方案：点击"仍然安装"继续安装过程

3. **安装失败或闪退**
   - 问题：应用安装后无法打开或频繁闪退
   - 解决方案：
     - 确保您的 Android 系统版本为 6.0 或更高版本
     - 卸载旧版本后重新安装
     - 清除手机存储空间确保有足够空间（至少需要 100MB 可用空间）

### iOS 安装问题

1. **无法下载或安装 IPA 文件**

   - 问题：普通用户无法直接安装 IPA 文件
   - 解决方案：
     - 推荐使用 TestFlight 安装，请联系开发者获取 TestFlight 邀请链接
     - 如有开发者账号，可通过 Xcode 安装 ß

2. **信任开发者证书**

   - 问题：首次安装后提示"未受信任的企业级开发者"
   - 解决方案：前往设置 > 通用 > 描述文件与设备管理，找到相应开发者证书并点击"信任"

3. **无法下载应用或提示"无法验证应用"**
   - 问题：安装过程中出现验证错误
   - 解决方案：
     - 确保您的 iOS 系统为 13.0 或更高版本
     - 检查设备是否有足够的存储空间（建议至少有 200MB 可用空间）
     - 确保设备已连接到稳定的网络
     - 尝试重启设备后再次安装

### 构建问题

1. **Android NDK 版本问题**

   - 问题：构建 Android APK 时提示 NDK 版本不兼容
   - 解决方案：
     - 在 `android/app/build.gradle.kts` 文件中的 `android` 部分添加 `ndkVersion = "27.0.12077973"`
     - 或者在 Android Studio 中安装 27.0.12077973 版本的 NDK

2. **iOS 签名问题**

   - 问题：构建 iOS 版本时出现签名错误
   - 解决方案：
     - 使用 `--no-codesign` 参数进行构建：`flutter build ios --release --no-codesign`
     - 或者在 Xcode 中配置正确的签名信息后构建

3. **依赖项冲突**
   - 问题：构建时提示依赖冲突
   - 解决方案：
     - 运行 `flutter clean` 后重新 `flutter pub get`
     - 检查 `pubspec.yaml` 中的依赖版本是否兼容
     - 如有必要，更新或降级冲突的依赖项

### 通用问题

1. **应用闪退或卡顿**

   - 问题：使用过程中应用崩溃或性能不佳
   - 解决方案：
     - 确保使用最新版本的应用
     - 清除应用缓存和数据
     - 重启设备
     - 如问题持续，请通过 GitHub Issues 报告问题

2. **图片或地图加载失败**

   - 问题：图片无法显示或地图不加载
   - 解决方案：
     - 检查网络连接是否正常
     - 确保允许应用使用数据流量或 WiFi
     - 如使用移动网络，确保应用有网络权限

3. **定位功能不可用**
   - 问题：地图上无法显示当前位置
   - 解决方案：
     - 检查是否已授予应用位置权限
     - 确保设备 GPS 已开启
     - 在设备设置中重新启用位置服务

如果您遇到以上未列出的问题，请通过 [GitHub Issues](https://github.com/eternalcoder12/travel_joy/issues) 联系我们，并提供详细的问题描述和复现步骤。

## 🛠️ 技术栈

- **Flutter**: UI 框架
- **Dart**: 编程语言
- **Material Design**: UI 设计风格
- **Animation**: 流畅的动画效果

## 🔄 已实现功能

- [x] 首页布局和动画效果
- [x] 探索页面的景点列表
- [x] 景点详情页面
- [x] 图片画廊
- [x] 收藏功能
- [x] 用户评论展示
- [x] 地图页面和景点标记
- [x] 预订方式抽屉
- [x] URL 跳转功能（地图、浏览器等）

## 📝 待实现功能

- [ ] 用户登录和注册功能
- [ ] 评论发布功能
- [ ] 收藏列表持久化存储
- [ ] 景点搜索功能
- [ ] 个人中心完善
- [ ] 实际集成地图 API
- [ ] 实际预订功能实现
- [ ] 多语言支持
- [ ] 主题切换功能

## 👨‍💻 贡献指南

欢迎贡献代码或提出建议！请按以下步骤操作：

1. Fork 项目
2. 创建您的特性分支 (`git checkout -b feature/amazing-feature`)
3. 提交您的修改 (`git commit -m 'Add some amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 创建 Pull Request

## 📄 许可证

该项目使用 MIT 许可证 - 详情请见 [LICENSE](LICENSE) 文件

## 📱 联系方式

如有任何问题或建议，请通过 GitHub Issues 联系我们。

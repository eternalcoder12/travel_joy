# Travel Joy 旅行应用

![Travel Joy](https://img.shields.io/badge/Travel%20Joy-1.0.1-blue)
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
2. 使用 Xcode 或其他工具安装到 iOS 设备
3. 或使用 TestFlight 安装测试版本

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

## ⚠️ 安装常见问题

### Android 安装问题

1. **"未知来源"安装限制**

   - **问题**: 安装时提示"未知来源应用"无法安装
   - **解决方案**: 进入 设置 > 安全 > 未知来源应用，开启允许安装

2. **应用崩溃或白屏**

   - **问题**: 首次启动应用后立即崩溃或显示白屏
   - **解决方案**: 确保您的 Android 系统版本不低于 6.0 (API 23)，并检查是否已授予应用必要权限

3. **网络功能无法使用**
   - **问题**: 应用内网络相关功能无法正常使用
   - **解决方案**: 确保您已授予应用网络权限，并检查网络连接是否正常

### iOS 安装问题

1. **无法验证应用**

   - **问题**: 显示"无法验证应用"或"未受信任的企业级开发者"
   - **解决方案**: 进入 设置 > 通用 > 描述文件与设备管理，找到相应的描述文件并信任

2. **CocoaPods 相关错误**

   - **问题**: 构建时出现 CocoaPods 相关错误
   - **解决方案**:
     ```bash
     cd ios
     pod repo update
     pod install --repo-update
     ```

3. **URL 跳转功能异常**
   - **问题**: 无法正常打开外部应用(微信、地图等)
   - **解决方案**: 确保在 Info.plist 中已配置 LSApplicationQueriesSchemes 以及对应的 URL Schemes

### 通用问题

1. **依赖包冲突**

   - **问题**: 构建时出现依赖包冲突
   - **解决方案**:
     ```bash
     flutter clean
     flutter pub get
     ```

2. **应用卡顿或动画不流畅**

   - **问题**: 应用运行缓慢或动画效果不流畅
   - **解决方案**: 检查设备性能，可以在应用设置中尝试关闭部分动画效果

3. **图片加载失败**
   - **问题**: 应用内图片无法正常加载
   - **解决方案**: 检查网络连接状况，若是在中国大陆使用，部分图片服务器可能需要代理访问

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

## 🔄 版本更新

### V1.0.1 (2024-09-19)

- 优化底部抽屉动画效果，更加流畅自然
- 修复主题配色问题，移除硬编码颜色
- 优化用户操作手势响应
- 修复已知 bug

### V1.0.0 (2024-09-01)

- 首次发布
- 实现景点详情页面和地图功能
- 添加基础预订功能

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

# TravelJoy 图片加载指南

## 概述

本指南介绍了 TravelJoy 项目中用于加载图片的网络图片加载方案。为了方便开发和测试，应用使用了 Lorem Picsum API 来替代本地图片资源，提供了稳定可靠的图片数据。

## 图片工具类

应用中新增了两个关键组件：

1. **ImageProviderHelper**: 工具类，负责映射资源路径到 Picsum 图片 ID，并提供图片 URL 生成功能。
2. **NetworkImage (自定义)**: 包装组件，用于在 UI 中简化网络图片的使用。

## 使用方法

### 1. 导入自定义组件

```dart
import 'package:travel_joy/widgets/network_image.dart' as network;
```

> 注意：我们使用了别名 `network` 来避免与 Flutter 原生的 `NetworkImage` 冲突。

### 2. 替换现有图片

将原有的 `Image.asset()` 替换为自定义组件：

**原代码:**

```dart
Image.asset(
  'assets/images/tokyo.jpg',
  width: 100,
  height: 100,
  fit: BoxFit.cover,
)
```

**新代码:**

```dart
network.NetworkImage(
  imageUrl: 'assets/images/tokyo.jpg',
  width: 100,
  height: 100,
  fit: BoxFit.cover,
)
```

### 3. 支持的属性

`NetworkImage` 组件支持以下属性：

- `imageUrl`: 图片路径(必填)
- `width`: 图片宽度
- `height`: 图片高度
- `fit`: 图片适应方式(默认 BoxFit.cover)
- `placeholder`: 加载占位 Widget
- `errorWidget`: 加载错误占位 Widget
- `borderRadius`: 边框圆角

### 4. 直接使用 Picsum ID

除了使用映射的本地资源路径，您也可以直接使用 Picsum 的特定图片 ID:

```dart
network.NetworkImage(
  imageUrl: 'https://picsum.photos/id/237/300/200',
  width: 100,
  height: 100,
)
```

## 图片映射表

`ImageProviderHelper` 中包含一个映射表，将本地资源路径映射到特定的 Picsum 图片 ID。这确保了同一个资源路径总是加载相同的图片。

如需添加新的映射，请在 `ImageProviderHelper` 类的 `_imageMap` 中添加新条目。

## Picsum API 参考

- 获取特定 ID 的图片: `https://picsum.photos/id/{image_id}/{width}/{height}`
- 获取随机图片: `https://picsum.photos/{width}/{height}`
- 获取灰度图片: `https://picsum.photos/{width}/{height}?grayscale`
- 获取模糊图片: `https://picsum.photos/{width}/{height}?blur=5`

更多 API 用法请参考: [Picsum Photos](https://picsum.photos/)

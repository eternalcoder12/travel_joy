import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui';

enum NavigationAnimationType {
  fade,
  slide,
  scale,
  rotation,
  slideAndFade,
  scaleAndFade,
  glowing,
  flipHorizontal,
  flipVertical,
  blur,
}

class NavigationUtils {
  /// 使用自定义动画导航到新页面
  static Future<T?> navigateTo<T>({
    required BuildContext context,
    required Widget page,
    NavigationAnimationType animationType = NavigationAnimationType.fade,
    Duration duration = const Duration(milliseconds: 300),
    bool replace = false,
    bool removeUntil = false,
    RoutePredicate? predicate,
  }) {
    final route = _createAnimatedRoute<T>(
      page: page,
      animationType: animationType,
      duration: duration,
    );

    if (removeUntil) {
      return Navigator.of(
        context,
      ).pushAndRemoveUntil(route, predicate ?? (route) => false);
    }

    if (replace) {
      return Navigator.of(context).pushReplacement(route);
    }

    return Navigator.of(context).push(route);
  }

  /// 使用淡入淡出动画导航
  static Future<T?> fadeNavigateTo<T>({
    required BuildContext context,
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
    bool replace = false,
    bool removeUntil = false,
    RoutePredicate? predicate,
  }) {
    return navigateTo<T>(
      context: context,
      page: page,
      animationType: NavigationAnimationType.fade,
      duration: duration,
      replace: replace,
      removeUntil: removeUntil,
      predicate: predicate,
    );
  }

  /// 使用滑动动画导航
  static Future<T?> slideNavigateTo<T>({
    required BuildContext context,
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
    bool replace = false,
    bool removeUntil = false,
    RoutePredicate? predicate,
  }) {
    return navigateTo<T>(
      context: context,
      page: page,
      animationType: NavigationAnimationType.slide,
      duration: duration,
      replace: replace,
      removeUntil: removeUntil,
      predicate: predicate,
    );
  }

  /// 缩放动画导航
  static Future<T?> scaleNavigateTo<T>({
    required BuildContext context,
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
    bool replace = false,
    bool removeUntil = false,
    RoutePredicate? predicate,
  }) {
    return navigateTo<T>(
      context: context,
      page: page,
      animationType: NavigationAnimationType.scale,
      duration: duration,
      replace: replace,
      removeUntil: removeUntil,
      predicate: predicate,
    );
  }

  /// 旋转动画导航
  static Future<T?> rotationNavigateTo<T>({
    required BuildContext context,
    required Widget page,
    Duration duration = const Duration(milliseconds: 400),
    bool replace = false,
    bool removeUntil = false,
    RoutePredicate? predicate,
  }) {
    return navigateTo<T>(
      context: context,
      page: page,
      animationType: NavigationAnimationType.rotation,
      duration: duration,
      replace: replace,
      removeUntil: removeUntil,
      predicate: predicate,
    );
  }

  /// 滑动+淡入淡出组合动画导航
  static Future<T?> slideAndFadeNavigateTo<T>({
    required BuildContext context,
    required Widget page,
    Duration duration = const Duration(milliseconds: 350),
    bool replace = false,
    bool removeUntil = false,
    RoutePredicate? predicate,
  }) {
    return navigateTo<T>(
      context: context,
      page: page,
      animationType: NavigationAnimationType.slideAndFade,
      duration: duration,
      replace: replace,
      removeUntil: removeUntil,
      predicate: predicate,
    );
  }

  /// 霓虹光效果动画导航（模拟发光边缘的效果）
  static Future<T?> glowingNavigateTo<T>({
    required BuildContext context,
    required Widget page,
    Duration duration = const Duration(milliseconds: 500),
    bool replace = false,
    bool removeUntil = false,
    RoutePredicate? predicate,
  }) {
    return navigateTo<T>(
      context: context,
      page: page,
      animationType: NavigationAnimationType.glowing,
      duration: duration,
      replace: replace,
      removeUntil: removeUntil,
      predicate: predicate,
    );
  }

  /// 翻转动画导航（水平方向）
  static Future<T?> flipHorizontalNavigateTo<T>({
    required BuildContext context,
    required Widget page,
    Duration duration = const Duration(milliseconds: 450),
    bool replace = false,
    bool removeUntil = false,
    RoutePredicate? predicate,
  }) {
    return navigateTo<T>(
      context: context,
      page: page,
      animationType: NavigationAnimationType.flipHorizontal,
      duration: duration,
      replace: replace,
      removeUntil: removeUntil,
      predicate: predicate,
    );
  }

  /// 模糊过渡导航
  static Future<T?> blurNavigateTo<T>({
    required BuildContext context,
    required Widget page,
    Duration duration = const Duration(milliseconds: 400),
    bool replace = false,
    bool removeUntil = false,
    RoutePredicate? predicate,
  }) {
    return navigateTo<T>(
      context: context,
      page: page,
      animationType: NavigationAnimationType.blur,
      duration: duration,
      replace: replace,
      removeUntil: removeUntil,
      predicate: predicate,
    );
  }

  /// 创建动画路由
  static Route<T> _createAnimatedRoute<T>({
    required Widget page,
    required NavigationAnimationType animationType,
    required Duration duration,
  }) {
    switch (animationType) {
      case NavigationAnimationType.fade:
        return PageRouteBuilder<T>(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
      case NavigationAnimationType.slide:
        return PageRouteBuilder<T>(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            final tween = Tween(
              begin: begin,
              end: end,
            ).chain(CurveTween(curve: Curves.easeInOut));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );
      case NavigationAnimationType.scale:
        return PageRouteBuilder<T>(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final scaleAnimation = Tween<double>(
              begin: 0.8,
              end: 1.0,
            ).chain(CurveTween(curve: Curves.easeInOut)).animate(animation);

            return ScaleTransition(scale: scaleAnimation, child: child);
          },
        );
      case NavigationAnimationType.rotation:
        return PageRouteBuilder<T>(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final rotationAnimation = Tween<double>(
              begin: math.pi / 12,
              end: 0.0,
            ).chain(CurveTween(curve: Curves.easeOut)).animate(animation);
            final scaleAnimation = Tween<double>(
              begin: 0.88,
              end: 1.0,
            ).chain(CurveTween(curve: Curves.easeOut)).animate(animation);
            final opacityAnimation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).chain(CurveTween(curve: Curves.easeOut)).animate(animation);

            return FadeTransition(
              opacity: opacityAnimation,
              child: ScaleTransition(
                scale: scaleAnimation,
                child: Transform.rotate(
                  angle: rotationAnimation.value,
                  child: child,
                ),
              ),
            );
          },
        );
      case NavigationAnimationType.slideAndFade:
        return PageRouteBuilder<T>(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.05, 0.05);
            const end = Offset.zero;
            final tween = Tween(
              begin: begin,
              end: end,
            ).chain(CurveTween(curve: Curves.easeInOut));

            final fadeAnimation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).chain(CurveTween(curve: Curves.easeIn)).animate(animation);

            return FadeTransition(
              opacity: fadeAnimation,
              child: SlideTransition(
                position: animation.drive(tween),
                child: child,
              ),
            );
          },
        );
      case NavigationAnimationType.scaleAndFade:
        return PageRouteBuilder<T>(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final scaleAnimation = Tween<double>(
              begin: 0.9,
              end: 1.0,
            ).chain(CurveTween(curve: Curves.easeOut)).animate(animation);

            final fadeAnimation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).chain(CurveTween(curve: Curves.easeOut)).animate(animation);

            return FadeTransition(
              opacity: fadeAnimation,
              child: ScaleTransition(scale: scaleAnimation, child: child),
            );
          },
        );
      case NavigationAnimationType.glowing:
        return PageRouteBuilder<T>(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final fadeAnimation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).chain(CurveTween(curve: Curves.easeOut)).animate(animation);

            final scaleAnimation = Tween<double>(
              begin: 0.92,
              end: 1.0,
            ).chain(CurveTween(curve: Curves.easeOut)).animate(animation);

            // 发光效果
            return Stack(
              children: [
                // 背景发光层 (将在子页面后面)
                if (animation.value > 0.2)
                  Positioned.fill(
                    child: Opacity(
                      opacity: math.min(1, (animation.value - 0.2) / 0.6),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: const Alignment(0.0, 0.0),
                            radius: 1.5 * (1 - animation.value),
                            colors: const [
                              Colors.white,
                              Colors.white12,
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.3, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),

                // 主内容
                FadeTransition(
                  opacity: fadeAnimation,
                  child: ScaleTransition(scale: scaleAnimation, child: child),
                ),
              ],
            );
          },
        );
      case NavigationAnimationType.flipHorizontal:
        return PageRouteBuilder<T>(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                // 在动画的50%进行翻转的变化
                var value = animation.value;
                var flipValue = math.sin(value * math.pi);

                return Transform(
                  transform:
                      Matrix4.identity()
                        ..setEntry(3, 2, 0.001) // 添加透视效果
                        ..rotateY(flipValue * math.pi / 2), // 旋转效果
                  alignment: Alignment.center,
                  child: Opacity(
                    opacity:
                        value < 0.5
                            ? math.cos(value * math.pi)
                            : math.sin(value * math.pi),
                    child: child,
                  ),
                );
              },
              child: child,
            );
          },
        );
      case NavigationAnimationType.flipVertical:
        return PageRouteBuilder<T>(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                var value = animation.value;
                var flipValue = math.sin(value * math.pi);

                return Transform(
                  transform:
                      Matrix4.identity()
                        ..setEntry(3, 2, 0.001) // 添加透视效果
                        ..rotateX(flipValue * math.pi / 2), // 垂直旋转效果
                  alignment: Alignment.center,
                  child: Opacity(
                    opacity:
                        value < 0.5
                            ? math.cos(value * math.pi)
                            : math.sin(value * math.pi),
                    child: child,
                  ),
                );
              },
              child: child,
            );
          },
        );
      case NavigationAnimationType.blur:
        return PageRouteBuilder<T>(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final fadeAnimation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).chain(CurveTween(curve: Curves.easeOut)).animate(animation);

            return FadeTransition(
              opacity: fadeAnimation,
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 10 * (1 - animation.value),
                  sigmaY: 10 * (1 - animation.value),
                ),
                child: child,
              ),
            );
          },
        );
      default:
        return MaterialPageRoute<T>(builder: (context) => page);
    }
  }
}

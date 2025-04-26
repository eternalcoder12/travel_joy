import 'package:flutter/material.dart';
import '../app_theme.dart';

/// 统一的动画元素封装组件
/// 支持多种动画效果，每个页面元素都可以使用此组件来获得一致的动画效果
class AnimatedItem extends StatefulWidget {
  /// 子组件
  final Widget child;

  /// 动画类型
  final AnimationType type;

  /// 动画延迟（毫秒）
  final int delay;

  /// 动画持续时间（毫秒）
  final int duration;

  /// 动画曲线
  final Curve curve;

  const AnimatedItem({
    Key? key,
    required this.child,
    this.type = AnimationType.fadeSlideUp,
    this.delay = 0,
    this.duration = 600,
    this.curve = Curves.easeOutCubic,
  }) : super(key: key);

  @override
  _AnimatedItemState createState() => _AnimatedItemState();
}

class _AnimatedItemState extends State<AnimatedItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.duration),
    );

    _animation = CurvedAnimation(parent: _controller, curve: widget.curve);

    if (widget.delay == 0) {
      _controller.forward();
    } else {
      Future.delayed(Duration(milliseconds: widget.delay), () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.type) {
      case AnimationType.fadeSlideUp:
        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Opacity(
              opacity: _animation.value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - _animation.value)),
                child: child,
              ),
            );
          },
          child: widget.child,
        );

      case AnimationType.fadeSlideDown:
        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Opacity(
              opacity: _animation.value,
              child: Transform.translate(
                offset: Offset(0, -20 * (1 - _animation.value)),
                child: child,
              ),
            );
          },
          child: widget.child,
        );

      case AnimationType.fadeSlideLeft:
        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Opacity(
              opacity: _animation.value,
              child: Transform.translate(
                offset: Offset(20 * (1 - _animation.value), 0),
                child: child,
              ),
            );
          },
          child: widget.child,
        );

      case AnimationType.fadeSlideRight:
        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Opacity(
              opacity: _animation.value,
              child: Transform.translate(
                offset: Offset(-20 * (1 - _animation.value), 0),
                child: child,
              ),
            );
          },
          child: widget.child,
        );

      case AnimationType.scale:
        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Opacity(
              opacity: _animation.value,
              child: Transform.scale(
                scale: 0.8 + (0.2 * _animation.value),
                child: child,
              ),
            );
          },
          child: widget.child,
        );

      case AnimationType.fadeIn:
      default:
        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Opacity(opacity: _animation.value, child: child);
          },
          child: widget.child,
        );
    }
  }
}

/// 动画类型枚举
enum AnimationType {
  /// 淡入 + 从下往上滑动
  fadeSlideUp,

  /// 淡入 + 从上往下滑动
  fadeSlideDown,

  /// 淡入 + 从右往左滑动
  fadeSlideLeft,

  /// 淡入 + 从左往右滑动
  fadeSlideRight,

  /// 缩放动画
  scale,

  /// 仅淡入效果
  fadeIn,
}

/// 用于创建连续动画的封装类
class AnimatedItemSequence extends StatelessWidget {
  /// 需要添加动画的子组件列表
  final List<Widget> children;

  /// 每个子组件的动画类型
  final AnimationType type;

  /// 每个子组件之间的动画延迟（毫秒）
  final int staggerDelay;

  /// 每个子组件的初始延迟（毫秒）
  final int initialDelay;

  /// 每个子组件的动画持续时间（毫秒）
  final int duration;

  /// 动画曲线
  final Curve curve;

  /// 子组件之间的间隔组件
  final Widget? separator;

  /// 是否跳过动画
  final bool skipAnimation;

  const AnimatedItemSequence({
    Key? key,
    required this.children,
    this.type = AnimationType.fadeSlideUp,
    this.staggerDelay = 100,
    this.initialDelay = 0,
    this.duration = 600,
    this.curve = Curves.easeOutCubic,
    this.separator,
    this.skipAnimation = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Widget> animatedChildren = [];

    for (int i = 0; i < children.length; i++) {
      // 如果跳过动画，直接添加子组件
      if (skipAnimation) {
        animatedChildren.add(children[i]);
      } else {
        // 添加动画子组件
        animatedChildren.add(
          AnimatedItem(
            delay: initialDelay + (i * staggerDelay),
            duration: duration,
            type: type,
            curve: curve,
            child: children[i],
          ),
        );
      }

      // 如果不是最后一个，并且有分隔符，则添加分隔符
      if (separator != null && i < children.length - 1) {
        animatedChildren.add(separator!);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: animatedChildren,
    );
  }
}

/// 从底部滑入的动画组件
class AnimatedItemSlideInFromBottom extends StatelessWidget {
  final AnimationController animationController;
  final double animationStart;
  final double animationEnd;
  final Widget child;

  const AnimatedItemSlideInFromBottom({
    Key? key,
    required this.animationController,
    required this.animationStart,
    required this.animationEnd,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Interval(animationStart, animationEnd, curve: Curves.easeOut),
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0.0, 50.0 * (1.0 - animation.value)),
          child: Opacity(opacity: animation.value, child: child),
        );
      },
      child: child,
    );
  }
}

/// 从顶部滑入的动画组件
class AnimatedItemSlideInFromTop extends StatelessWidget {
  final AnimationController animationController;
  final double animationStart;
  final double animationEnd;
  final Widget child;

  const AnimatedItemSlideInFromTop({
    Key? key,
    required this.animationController,
    required this.animationStart,
    required this.animationEnd,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Interval(animationStart, animationEnd, curve: Curves.easeOut),
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0.0, -50.0 * (1.0 - animation.value)),
          child: Opacity(opacity: animation.value, child: child),
        );
      },
      child: child,
    );
  }
}

/// 从左侧滑入的动画组件
class AnimatedItemSlideInFromLeft extends StatelessWidget {
  final AnimationController animationController;
  final double animationStart;
  final double animationEnd;
  final Widget child;

  const AnimatedItemSlideInFromLeft({
    Key? key,
    required this.animationController,
    required this.animationStart,
    required this.animationEnd,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Interval(animationStart, animationEnd, curve: Curves.easeOut),
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(-50.0 * (1.0 - animation.value), 0.0),
          child: Opacity(opacity: animation.value, child: child),
        );
      },
      child: child,
    );
  }
}

/// 从右侧滑入的动画组件
class AnimatedItemSlideInFromRight extends StatelessWidget {
  final AnimationController animationController;
  final double animationStart;
  final double animationEnd;
  final Widget child;

  const AnimatedItemSlideInFromRight({
    Key? key,
    required this.animationController,
    required this.animationStart,
    required this.animationEnd,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Interval(animationStart, animationEnd, curve: Curves.easeOut),
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(50.0 * (1.0 - animation.value), 0.0),
          child: Opacity(opacity: animation.value, child: child),
        );
      },
      child: child,
    );
  }
}

/// 弹出动画组件
class AnimatedItemPop extends StatelessWidget {
  final AnimationController animationController;
  final double animationStart;
  final double animationEnd;
  final Widget child;

  const AnimatedItemPop({
    Key? key,
    required this.animationController,
    required this.animationStart,
    required this.animationEnd,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Interval(animationStart, animationEnd, curve: Curves.elasticOut),
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          scale: animation.value,
          child: Opacity(opacity: animation.value, child: child),
        );
      },
      child: child,
    );
  }
}

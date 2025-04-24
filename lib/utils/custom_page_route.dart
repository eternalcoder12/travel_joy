import 'package:flutter/material.dart';

class CustomPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final bool fadeIn;
  final bool slideFromRight;
  final Duration duration;

  CustomPageRoute({
    required this.page,
    RouteSettings? settings,
    this.fadeIn = true,
    this.slideFromRight = true,
    this.duration = const Duration(milliseconds: 300),
  }) : super(
         settings: settings,
         pageBuilder:
             (
               BuildContext context,
               Animation<double> animation,
               Animation<double> secondaryAnimation,
             ) => page,
         transitionsBuilder: (
           BuildContext context,
           Animation<double> animation,
           Animation<double> secondaryAnimation,
           Widget child,
         ) {
           var curve = Curves.easeOutCubic;
           var curvedAnimation = CurvedAnimation(
             parent: animation,
             curve: curve,
           );

           List<Widget> effectWidgets = [child];

           // 淡入效果
           if (fadeIn) {
             effectWidgets = [
               FadeTransition(opacity: curvedAnimation, child: child),
             ];
           }

           // 滑动效果
           if (slideFromRight) {
             effectWidgets = [
               SlideTransition(
                 position: Tween<Offset>(
                   begin: const Offset(0.3, 0.0),
                   end: Offset.zero,
                 ).animate(curvedAnimation),
                 child: effectWidgets[0],
               ),
             ];
           }

           return effectWidgets[0];
         },
         transitionDuration: duration,
       );
}

class FadeRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  FadeRoute({required this.page, RouteSettings? settings})
    : super(
        settings: settings,
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      );
}

class SlideRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Offset beginOffset;

  SlideRoute({
    required this.page,
    RouteSettings? settings,
    this.beginOffset = const Offset(1.0, 0.0),
  }) : super(
         settings: settings,
         pageBuilder: (context, animation, secondaryAnimation) => page,
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           var curve = Curves.easeOutCubic;
           var curvedAnimation = CurvedAnimation(
             parent: animation,
             curve: curve,
           );

           return SlideTransition(
             position: Tween<Offset>(
               begin: beginOffset,
               end: Offset.zero,
             ).animate(curvedAnimation),
             child: FadeTransition(opacity: curvedAnimation, child: child),
           );
         },
         transitionDuration: const Duration(milliseconds: 300),
       );
}

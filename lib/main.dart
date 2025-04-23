import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_theme.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/home/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 应用入口函数
void main() {
  // 捕获所有异常并记录
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    print('Flutter错误: ${details.exception}');
  };

  // 确保Flutter绑定已初始化
  WidgetsFlutterBinding.ensureInitialized();

  // 处理应用程序初始化
  initApp();
}

// 应用程序初始化函数，处理异步操作
Future<void> initApp() async {
  try {
    // 设置屏幕方向为竖屏
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // 获取首选项
    final prefs = await SharedPreferences.getInstance();
    final bool hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

    // 使用FutureBuilder启动应用
    runApp(TravelJoyApp(hasSeenOnboarding: hasSeenOnboarding));
  } catch (e) {
    print('应用初始化错误: $e');
    // 启动一个最小的错误应用
    runApp(
      MaterialApp(home: Scaffold(body: Center(child: Text('应用启动失败，请重试: $e')))),
    );
  }
}

// 将应用名称改为更明确的名称，避免命名冲突
class TravelJoyApp extends StatefulWidget {
  final bool hasSeenOnboarding;

  const TravelJoyApp({super.key, this.hasSeenOnboarding = false});

  @override
  State<TravelJoyApp> createState() => _TravelJoyAppState();
}

class _TravelJoyAppState extends State<TravelJoyApp> {
  // 使用静态常量作为全局key，确保全局唯一性
  static final GlobalKey<NavigatorState> _navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    // 配置是否使用导航栏的条件
    final useBottomNavBar = widget.hasSeenOnboarding;

    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'Travel Joy',
      theme: AppTheme.getTheme(),
      debugShowCheckedModeBanner: false, // 移除调试标记
      initialRoute: widget.hasSeenOnboarding ? '/home' : '/onboarding',
      routes: {
        '/':
            (context) =>
                widget.hasSeenOnboarding
                    ? const HomeScreen()
                    : const OnboardingScreen(),
        '/home': (context) => const HomeScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot_password': (context) => const ForgotPasswordScreen(),
      },
    );
  }
}

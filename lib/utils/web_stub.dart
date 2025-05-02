/// Web平台的Platform替代类
/// 
/// 提供与dart:io的Platform类相同的属性和方法的存根实现，
/// 用于在web平台编译时替代dart:io
class Platform {
  /// 判断当前平台是否为Android
  static bool get isAndroid => false;

  /// 判断当前平台是否为iOS
  static bool get isIOS => false;

  /// 判断当前平台是否为macOS
  static bool get isMacOS => false;

  /// 判断当前平台是否为Windows
  static bool get isWindows => false;

  /// 判断当前平台是否为Linux
  static bool get isLinux => false;

  /// 判断当前平台是否为Fuchsia
  static bool get isFuchsia => false;

  /// 获取操作系统版本
  static String get operatingSystemVersion => 'web';

  /// 获取操作系统类型
  static String get operatingSystem => 'web';

  /// 获取本地主机名
  static String get localHostname => 'web';

  /// 获取环境变量
  static Map<String, String> get environment => {};

  /// 获取可执行文件路径
  static String get executable => '';

  /// 获取可执行文件参数
  static List<String> get executableArguments => [];

  /// 获取进程ID
  static int get numberOfProcessors => 1;

  /// 获取处理器核心数
  static String get pathSeparator => '/';

  /// 获取本地化名称
  static String get localeName => 'en_US';
} 
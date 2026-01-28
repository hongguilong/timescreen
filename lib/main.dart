import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:window_manager/window_manager.dart';
import 'flip_widget.dart';

/// 程序入口
void main(List<String> args) async {
  // 简单的文件日志记录，用于调试启动问题
  try {
    final logFile = File('${Directory.systemTemp.path}\\timescreen_debug.log');
    final timestamp = DateTime.now().toIso8601String();
    logFile.writeAsStringSync('[$timestamp] Started with args: $args\n',
        mode: FileMode.append);
  } catch (e) {
    // 忽略日志错误
  }

  // Windows 屏保参数处理
  if (args.isNotEmpty) {
    String cmd = args[0].toLowerCase().trim();
    // /p: 预览模式 - 暂时不支持，直接退出以免全屏覆盖
    // /c: 配置模式 - 暂时不支持
    // 注意：Windows 有时会传入 /p:123456 这样的格式，所以用 startsWith
    if (cmd.startsWith('/p') || cmd.startsWith('/c')) {
      try {
        final logFile =
            File('${Directory.systemTemp.path}\\timescreen_debug.log');
        logFile.writeAsStringSync('Exiting due to preview/config mode: $cmd\n',
            mode: FileMode.append);
      } catch (e) {}
      exit(0);
    }
  }

  WidgetsFlutterBinding.ensureInitialized();
  // 初始化日期格式化数据
  await initializeDateFormatting('zh_CN', null);
  // 初始化窗口管理器
  await windowManager.ensureInitialized();

  // 配置窗口选项：居中、黑底、跳过任务栏、隐藏标题栏
  WindowOptions windowOptions = const WindowOptions(
    center: true,
    backgroundColor: Colors.black,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );

  // 等待窗口准备就绪并显示
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
    await windowManager.setFullScreen(true); // 设置全屏
  });

  runApp(const MyApp());
}

/// 自定义滚动行为，禁用所有平台的滚动条
class NoScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };

  @override
  Widget buildScrollbar(
      BuildContext context, Widget child, ScrollableDetails details) {
    // 禁用所有滚动条
    return child;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Time Screen',
      debugShowCheckedModeBanner: false,
      scrollBehavior: NoScrollBehavior(), // 禁用全局滚动条
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        primarySwatch: Colors.blue,
        // 确保 ScrollbarTheme 也是透明的，双重保险
        scrollbarTheme: const ScrollbarThemeData(
          thumbColor: MaterialStatePropertyAll(Colors.transparent),
          trackColor: MaterialStatePropertyAll(Colors.transparent),
          thickness: MaterialStatePropertyAll(0),
        ),
      ),
      home: const ClockScreen(),
    );
  }
}

/// 时钟主屏幕
class ClockScreen extends StatefulWidget {
  const ClockScreen({super.key});

  @override
  State<ClockScreen> createState() => _ClockScreenState();
}

class _ClockScreenState extends State<ClockScreen> {
  late Timer _timer;
  late DateTime _currentTime;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    // 每秒更新一次时间
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  /// 双击退出程序
  void _handleDoubleTap() {
    windowManager.close();
    exit(0);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // 动态计算数字宽度，使用屏幕宽度的 1/8 作为基准
    double digitWidth = size.width / 8;

    // 限制最大和最小宽度
    if (digitWidth > 400) digitWidth = 400;
    if (digitWidth < 50) digitWidth = 50;

    double digitHeight = digitWidth * 1.6;
    double fontSize = digitHeight * 0.75;

    // 格式化日期字符串
    final dateString =
        DateFormat('yyyy年MM月dd日 EEEE', 'zh_CN').format(_currentTime);

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false, // 防止键盘弹出导致的挤压
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onDoubleTap: _handleDoubleTap, // 绑定双击退出事件
        child: Container(
          color: Colors.black,
          width: double.infinity,
          height: double.infinity,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min, // 最小尺寸包裹
              children: [
                // 使用 FittedBox 确保时钟在极端情况下也不会溢出屏幕
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: FlipClock(
                      time: _currentTime,
                      width: digitWidth,
                      height: digitHeight,
                      digitSize: fontSize,
                      digitColor: const Color(0xFFE0E0E0),
                      backgroundColor: const Color(0xFF202020),
                      separatorColor: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 60),
                // 日期显示
                Text(
                  dateString,
                  style: TextStyle(
                    color: const Color(0xFFBDC3C7),
                    fontSize: size.height * 0.035,
                    fontWeight: FontWeight.w300,
                    fontFamily: 'Microsoft YaHei UI',
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

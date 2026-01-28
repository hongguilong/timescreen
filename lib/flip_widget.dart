import 'dart:math';
import 'package:flutter/material.dart';

/// 翻页时钟组件
/// 显示小时、分钟、秒，并带有翻页动画效果
class FlipClock extends StatelessWidget {
  final DateTime time;
  final double digitSize;
  final double width;
  final double height;
  final Color digitColor;
  final Color backgroundColor;
  final Color separatorColor;

  const FlipClock({
    Key? key,
    required this.time,
    required this.digitSize,
    required this.width,
    required this.height,
    required this.digitColor,
    required this.backgroundColor,
    this.separatorColor = Colors.grey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildDigitGroup(time.hour),
        _buildSeparator(),
        _buildDigitGroup(time.minute),
        _buildSeparator(),
        _buildDigitGroup(time.second),
      ],
    );
  }

  /// 构建数字组（十位和个位）
  Widget _buildDigitGroup(int value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FlipDigit(
          value: value ~/ 10,
          width: width,
          height: height,
          fontSize: digitSize,
          color: digitColor,
          backgroundColor: backgroundColor,
        ),
        SizedBox(width: width * 0.05), // 数字间距
        FlipDigit(
          value: value % 10,
          width: width,
          height: height,
          fontSize: digitSize,
          color: digitColor,
          backgroundColor: backgroundColor,
        ),
      ],
    );
  }

  /// 构建分隔符（冒号）
  Widget _buildSeparator() {
    return SizedBox(
      width: width * 0.3,
      height: height,
      child: Center(
        child: Padding(
          padding: EdgeInsets.only(bottom: height * 0.15),
          child: Text(
            ":",
            style: TextStyle(
              fontSize: digitSize * 0.5,
              color: separatorColor,
              fontWeight: FontWeight.bold,
              height: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}

/// 单个翻页数字组件
/// 包含翻页动画逻辑
class FlipDigit extends StatefulWidget {
  final int value;
  final double width;
  final double height;
  final double fontSize;
  final Color color;
  final Color backgroundColor;

  const FlipDigit({
    Key? key,
    required this.value,
    required this.width,
    required this.height,
    required this.fontSize,
    required this.color,
    required this.backgroundColor,
  }) : super(key: key);

  @override
  State<FlipDigit> createState() => _FlipDigitState();
}

class _FlipDigitState extends State<FlipDigit> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _currentValue = 0;
  int _nextValue = 0;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
    _nextValue = widget.value;
    // 动画时长 600ms
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          setState(() {
            _currentValue = _nextValue;
            _controller.reset();
          });
        }
      }
    });
  }

  @override
  void didUpdateWidget(covariant FlipDigit oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当数值发生变化时，触发动画
    if (widget.value != oldWidget.value) {
      _nextValue = widget.value;
      // 如果正在动画中，重置并重新开始
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 静态背景：始终显示新值的下半部分和上半部分（作为底衬）
          _buildHalfDigit(_nextValue, false),
          _buildHalfDigit(_nextValue, true),

          // 如果没有动画，显示当前值（覆盖在上面）
          if (!_controller.isAnimating) ...[
             _buildHalfDigit(_currentValue, false),
             _buildHalfDigit(_currentValue, true),
          ],

          // 动画层
          if (_controller.isAnimating) ...[
             // 1. 旧值的下半部分（一直静止，直到被覆盖）
             if (_animation.value <= 0.5)
               _buildHalfDigit(_currentValue, false),
             
             // 2. 旧值的上半部分（向下翻转）
             if (_animation.value <= 0.5)
               Transform(
                 transform: Matrix4.identity()
                   ..setEntry(3, 2, 0.002)
                   ..rotateX(-pi * _animation.value),
                 alignment: Alignment.bottomCenter,
                 child: _buildHalfDigit(_currentValue, true),
               ),

             // 3. 新值的下半部分（从上翻下来）
             if (_animation.value > 0.5)
               Transform(
                 transform: Matrix4.identity()
                   ..setEntry(3, 2, 0.002)
                   ..rotateX(pi / 2 * (1 - (_animation.value - 0.5) * 2)), // 90 -> 0
                 alignment: Alignment.topCenter,
                 child: _buildHalfDigit(_nextValue, false),
               ),
          ],

          // 中间分割线
          Center(
            child: Container(
              height: 2,
              width: widget.width,
              color: Colors.black.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建半个数字（上半部分或下半部分）
  /// isTop: true 表示上半部分，false 表示下半部分
  Widget _buildHalfDigit(int value, bool isTop) {
    return Align(
      alignment: isTop ? Alignment.topCenter : Alignment.bottomCenter,
      child: ClipRect(
        child: Align(
          alignment: isTop ? Alignment.topCenter : Alignment.bottomCenter,
          heightFactor: 0.5,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.vertical(
                top: isTop ? const Radius.circular(12) : Radius.zero,
                bottom: isTop ? Radius.zero : const Radius.circular(12),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              value.toString(),
              style: TextStyle(
                fontSize: widget.fontSize,
                color: widget.color,
                fontWeight: FontWeight.bold,
                height: 1.0,
                // fontFamily: 'Roboto', 
              ),
            ),
          ),
        ),
      ),
    );
  }
}

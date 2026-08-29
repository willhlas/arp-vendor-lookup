import 'dart:math';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    this.width = 25,
    this.height = 30,
    super.key,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 40,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          gradient: const LinearGradient(
            colors: [Color(0xFF5B7FE0), Color(0xFF3E5FC4)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xs),
          child: Align(
            child: CustomPaint(
              size: Size(width, height),
              painter: const AppLogoPainter(),
            ),
          ),
        ),
      ),
    );
  }
}

class AppLogoPainter extends CustomPainter {
  const AppLogoPainter();

  static const _defaultSize = Size(45, 50);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(
      min(size.width / _defaultSize.width, size.height / _defaultSize.height),
    );

    final pathOne = Path()
      ..moveTo(4.757, 22.057)
      ..arcToPoint(
        const Offset(0, 33.633),
        radius: const Radius.elliptical(16.43, 16.43),

        clockwise: false,
      )
      ..cubicTo(0, 37.973, 1.714, 42.137, 4.762, 45.207)
      ..arcToPoint(
        const Offset(16.253, 50),
        radius: const Radius.elliptical(16.2, 16.2),

        clockwise: false,
      )
      ..arcToPoint(
        const Offset(27.744, 45.205),
        radius: const Radius.elliptical(16.2, 16.2),

        clockwise: false,
      )
      ..arcToPoint(
        const Offset(32.504, 33.629999999999995),
        radius: const Radius.elliptical(16.43, 16.43),

        clockwise: false,
      )
      ..cubicTo(
        32.504,
        29.288999999999994,
        30.793999999999997,
        25.124999999999993,
        27.746,
        22.054999999999996,
      )
      ..arcToPoint(
        const Offset(16.256, 17.258999999999997),
        radius: const Radius.elliptical(16.2, 16.2),

        clockwise: false,
      )
      ..arcToPoint(
        const Offset(4.763, 22.050999999999995),
        radius: const Radius.elliptical(16.2, 16.2),

        clockwise: false,
      )
      ..close()
      ..moveTo(7.773999999999999, 25.095)
      ..arcToPoint(
        const Offset(16.25, 21.561999999999998),
        radius: const Radius.elliptical(11.94, 11.94),
      )
      ..cubicTo(
        19.428,
        21.561999999999998,
        22.476,
        22.834999999999997,
        24.723,
        25.098999999999997,
      )
      ..arcToPoint(
        const Offset(28.232999999999997, 33.635999999999996),
        radius: const Radius.elliptical(12.12, 12.12),
      )
      ..cubicTo(
        28.232999999999997,
        36.837999999999994,
        26.97,
        39.907999999999994,
        24.721999999999998,
        42.172,
      )
      ..arcToPoint(
        const Offset(16.247999999999998, 45.708999999999996),
        radius: const Radius.elliptical(11.94, 11.94),
      )
      ..arcToPoint(
        const Offset(7.772999999999998, 42.17399999999999),
        radius: const Radius.elliptical(11.94, 11.94),
      )
      ..arcToPoint(
        const Offset(4.259999999999998, 33.63799999999999),
        radius: const Radius.elliptical(12.12, 12.12),
      )
      ..cubicTo(
        4.259999999999998,
        30.43699999999999,
        5.520999999999998,
        27.365999999999993,
        7.767999999999998,
        25.100999999999992,
      )
      ..close();

    final paintOne = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xff9baee5);

    canvas.drawPath(pathOne, paintOne);

    final pathTwo = Path()
      ..moveTo(10.77, 10.074)
      ..cubicTo(13.532, 10.074, 15.771, 7.819, 15.771, 5.037)
      ..cubicTo(15.771, 2.255, 13.532, 0, 10.771, 0)
      ..cubicTo(8.010000000000002, 0, 5.77, 2.255, 5.77, 5.037)
      ..cubicTo(5.77, 7.819, 8.009, 10.074, 10.77, 10.074);

    final paintTwo = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xffffffff);
    canvas.drawPath(pathTwo, paintTwo);

    final pathThree = Path()
      ..moveTo(17.251, 11.58)
      ..arcToPoint(
        const Offset(12.495000000000001, 23.156),
        radius: const Radius.elliptical(16.43, 16.43),

        clockwise: false,
      )
      ..arcToPoint(
        const Offset(17.258000000000003, 34.73),
        radius: const Radius.elliptical(16.43, 16.43),

        clockwise: false,
      )
      ..arcToPoint(
        const Offset(28.749000000000002, 39.522),
        radius: const Radius.elliptical(16.2, 16.2),

        clockwise: false,
      )
      ..cubicTo(
        33.059000000000005,
        39.522,
        37.192,
        37.797,
        40.239000000000004,
        34.727,
      )
      ..arcToPoint(
        const Offset(45, 23.153),
        radius: const Radius.elliptical(16.43, 16.43),
        clockwise: false,
      )
      ..cubicTo(
        45,
        18.811999999999998,
        43.289,
        14.647999999999998,
        40.242,
        11.578,
      )
      ..arcToPoint(
        const Offset(28.751999999999995, 6.781),
        radius: const Radius.elliptical(16.2, 16.2),
        clockwise: false,
      )
      ..arcToPoint(
        const Offset(17.259999999999994, 11.571),
        radius: const Radius.elliptical(16.2, 16.2),
        clockwise: false,
      )
      ..close()
      ..moveTo(23.218, 17.59)
      ..arcToPoint(
        const Offset(28.744, 15.29),
        radius: const Radius.elliptical(7.8, 7.8),
      )
      ..arcToPoint(
        const Offset(34.266, 17.596999999999998),
        radius: const Radius.elliptical(7.8, 7.8),
      )
      ..arcToPoint(
        const Offset(36.553, 23.162),
        radius: const Radius.elliptical(7.9, 7.9),
      )
      ..arcToPoint(
        const Offset(34.263, 28.726),
        radius: const Radius.elliptical(7.9, 7.9),
      )
      ..arcToPoint(
        const Offset(28.74, 31.031),
        radius: const Radius.elliptical(7.8, 7.8),
      )
      ..arcToPoint(
        const Offset(23.215999999999998, 28.727999999999998),
        radius: const Radius.elliptical(7.8, 7.8),
      )
      ..arcToPoint(
        const Offset(20.926, 23.165),
        radius: const Radius.elliptical(7.9, 7.9),
      )
      ..arcToPoint(
        const Offset(23.209, 17.599999999999998),
        radius: const Radius.elliptical(7.9, 7.9),
      )
      ..close();

    final paintThree = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xffe4eaf9);
    canvas.drawPath(pathThree, paintThree);
  }

  @override
  bool shouldRepaint(covariant AppLogoPainter oldDelegate) => false;
}

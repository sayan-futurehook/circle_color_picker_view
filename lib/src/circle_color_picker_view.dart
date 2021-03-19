import 'dart:math';

import 'package:flutter/material.dart';

class ColorPickerView extends StatefulWidget {
  ColorPickerView(
      {this.radius = 120,
      this.thumbRadius = 10,
      this.initialColor = const Color(0xffff0000),
      required this.colorListener});

  final double radius;
  final double thumbRadius;
  final ValueChanged<Color>? colorListener;
  final Color initialColor;

  @override
  _ColorPickerViewState createState() => _ColorPickerViewState();
}

class _ColorPickerViewState extends State<ColorPickerView> {
  static const List<Color> colors = [
    Color(0xffff0000),
    Color(0xffff00ff),
    Color(0xff0000ff),
    Color(0xff00ffff),
    Color(0xff00ff00),
    Color(0xffffff00),
    Color(0xffff0000)
  ];

  double thumbDistanceToCenter = 0;
  double thumbRadians = 0;
  double barWidth = 0;
  double barHeight = 0;

  Color? mixedColor;
  Color? baseColor;
  double rate = 0;

  @override
  void initState() {
    super.initState();

    mixedColor = widget.initialColor;
    baseColor = widget.initialColor;

    barWidth = widget.radius * 2;
    barHeight = widget.thumbRadius * 2;
    rate = HSVColor.fromColor(widget.initialColor).value;

    thumbDistanceToCenter = widget.radius - widget.thumbRadius;
    thumbRadians =
        degreesToRadians(270 - HSVColor.fromColor(widget.initialColor).hue);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(20),
          child: _wheelArea(),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: _barArea(),
        ),
      ],
    );
  }

  Widget _thumb(double left, double top) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: widget.thumbRadius * 2,
        height: widget.thumbRadius * 2,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(widget.thumbRadius)),
          boxShadow: <BoxShadow>[
            BoxShadow(color: Colors.black, spreadRadius: 0.1),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: mixedColor,
            borderRadius: BorderRadius.all(Radius.circular(widget.thumbRadius)),
          ),
        ),
      ),
    );
  }

  Widget _wheelArea() {
    final double radius = widget.radius;
    final double thumbRadius = widget.thumbRadius;
    final double thumbCenterX =
        widget.radius + thumbDistanceToCenter * sin(thumbRadians);
    final double thumbCenterY =
        widget.radius + thumbDistanceToCenter * cos(thumbRadians);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanDown: (details) => handleTouchWheel(details.globalPosition, context),
      onPanStart: (details) =>
          handleTouchWheel(details.globalPosition, context),
      onPanUpdate: (details) =>
          handleTouchWheel(details.globalPosition, context),
      child: Stack(
        children: <Widget>[
          SizedBox(
              width: (radius + thumbRadius) * 2,
              height: (radius + thumbRadius) * 2),
          Positioned(
            left: thumbRadius,
            top: thumbRadius,
            child: Container(
              width: radius * 2,
              height: radius * 2,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(radius)),
                gradient: SweepGradient(colors: colors),
              ),
            ),
          ),
          Positioned(
            left: thumbRadius,
            top: thumbRadius,
            child: Container(
              width: radius * 2,
              height: radius * 2,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(radius)),
                  gradient: RadialGradient(colors: <Color>[
                    Colors.white,
                    Color(0x00ffffff),
                  ], stops: [
                    0.0,
                    1.0
                  ])),
            ),
          ),
          Positioned(
            left: thumbRadius,
            top: thumbRadius,
            child: Container(
              width: radius * 2,
              height: radius * 2,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(radius)),
                color: Color.fromARGB(((1 - rate) * 255).toInt(), 1, 1, 1),
              ),
            ),
          ),
          _thumb(thumbCenterX, thumbCenterY),
        ],
      ),
    );
  }

  Widget _barArea() {
    final thumbRadius = widget.thumbRadius;
    final thumbLeft = barWidth * rate - widget.thumbRadius < 0
        ? 0.0
        : barWidth * rate - widget.thumbRadius;
    final thumbTop = 0.0;

    Widget frame = Positioned(
      left: thumbRadius,
      top: (thumbRadius * 2 - barHeight) / 2,
      child: Container(
        width: barWidth,
        height: barHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(thumbRadius * 2)),
          color: baseColor,
        ),
      ),
    );

    Widget content = Positioned(
      left: thumbRadius,
      top: (thumbRadius * 2 - barHeight) / 2,
      child: Container(
        width: barWidth,
        height: barHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(thumbRadius * 2)),
          gradient: LinearGradient(colors: [Colors.black, Colors.transparent]),
        ),
      ),
    );

    return GestureDetector(
      onPanDown: (details) => handleTouchBar(details.globalPosition, context),
      onPanStart: (details) => handleTouchBar(details.globalPosition, context),
      onPanUpdate: (details) => handleTouchBar(details.globalPosition, context),
      child: SizedBox(
        width: barWidth + thumbRadius * 2,
        height: barHeight,
        child: Stack(
          children: [
            frame,
            content,
            _thumb(thumbLeft, thumbTop),
          ],
        ),
      ),
    );
  }

  void handleTouchWheel(Offset globalPosition, BuildContext context) {
    RenderBox box = context.findRenderObject() as RenderBox;
    Offset localPosition = box.globalToLocal(globalPosition);
    final double centerX = box.size.width / 2;
    final double centerY = box.size.height / 2;
    final double deltaX = localPosition.dx - centerX;
    final double deltaY = localPosition.dy - centerY;
    final double distanceToCenter = sqrt(deltaX * deltaX + deltaY * deltaY);
    final double dist = distanceToCenter / widget.radius > 1
        ? 1
        : distanceToCenter / widget.radius;
    double theta = atan2(deltaX, deltaY);
    double degree = radiansToDegrees(theta) + 90;
    if (degree < 0) degree += 360;
    if (degree > 360) degree -= 360;
    baseColor = HSVColor.fromAHSV(1, degree, dist, 1).toColor();
    mixColor();

    setState(() {
      thumbDistanceToCenter =
          min(distanceToCenter, widget.radius - widget.thumbRadius);
      thumbRadians = theta;
    });
  }

  double radiansToDegrees(double radians) {
    return (radians + pi) / pi * 180;
  }

  double degreesToRadians(double degrees) {
    return degrees / 180 * pi - pi;
  }

  void handleTouchBar(Offset globalPosition, BuildContext context) {
    RenderBox box = context.findRenderObject() as RenderBox;
    Offset localPosition = box.globalToLocal(globalPosition);
    double rate = (localPosition.dx - widget.thumbRadius) / barWidth;
    rate = min(max(0.0, rate), 1.0);
    setState(() {
      this.rate = rate;
    });
    mixColor();
  }

  void mixColor() {
    setState(() {
      mixedColor = HSVColor.fromColor(baseColor!).withValue(rate).toColor();
    });
    widget.colorListener!(mixedColor!);
  }
}

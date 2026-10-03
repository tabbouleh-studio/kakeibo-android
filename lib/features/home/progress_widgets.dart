import 'dart:math';

import 'package:flutter/material.dart';

/// A thin rounded progress bar. [value] is 0..1.
class ProgressBar extends StatelessWidget {
  const ProgressBar({super.key, required this.value, required this.color, this.height = 8});

  final double value;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(double.infinity, height),
      painter: _BarPainter(
        value: value.clamp(0, 1),
        color: color,
        track: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
    );
  }
}

class _BarPainter extends CustomPainter {
  _BarPainter({required this.value, required this.color, required this.track});

  final double value;
  final Color color;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = Radius.circular(size.height / 2);
    canvas.drawRRect(RRect.fromRectAndRadius(Offset.zero & size, radius), Paint()..color = track);
    if (value <= 0) return;
    final width = max(size.height, size.width * value);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, width, size.height), radius),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_BarPainter old) =>
      old.value != value || old.color != color || old.track != track;
}

/// A circular progress ring with a child in the middle. [value] is 0..1.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.value,
    required this.color,
    this.size = 96,
    this.strokeWidth = 10,
    this.child,
  });

  final double value;
  final Color color;
  final double size;
  final double strokeWidth;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _RingPainter(
          value: value.clamp(0, 1),
          color: color,
          track: Theme.of(context).colorScheme.surfaceContainerHighest,
          strokeWidth: strokeWidth,
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.value,
    required this.color,
    required this.track,
    required this.strokeWidth,
  });

  final double value;
  final Color color;
  final Color track;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(strokeWidth / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, 2 * pi, false, paint..color = track);
    if (value > 0) {
      canvas.drawArc(rect, -pi / 2, 2 * pi * value, false, paint..color = color);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value || old.color != color || old.track != track;
}

/// One segment of a [SegmentedBar].
typedef BarSegment = ({double value, Color color});

/// A bar made of coloured segments (values are fractions of the whole),
/// with an optional marker, e.g. how far through the month we are.
class SegmentedBar extends StatelessWidget {
  const SegmentedBar({
    super.key,
    required this.segments,
    required this.track,
    this.marker,
    this.markerColor,
    this.height = 12,
  });

  final List<BarSegment> segments;
  final Color track;
  final double? marker;
  final Color? markerColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(double.infinity, height + 8),
      painter: _SegmentedBarPainter(
        segments: segments,
        track: track,
        marker: marker,
        markerColor: markerColor ?? Theme.of(context).colorScheme.onSurface,
        barHeight: height,
      ),
    );
  }
}

class _SegmentedBarPainter extends CustomPainter {
  _SegmentedBarPainter({
    required this.segments,
    required this.track,
    required this.marker,
    required this.markerColor,
    required this.barHeight,
  });

  final List<BarSegment> segments;
  final Color track;
  final double? marker;
  final Color markerColor;
  final double barHeight;

  @override
  void paint(Canvas canvas, Size size) {
    final top = (size.height - barHeight) / 2;
    final bar = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, top, size.width, barHeight),
      Radius.circular(barHeight / 2),
    );
    canvas.drawRRect(bar, Paint()..color = track);

    // Scale down if the segments add up to more than the whole bar.
    final total = segments.fold<double>(0, (sum, s) => sum + s.value);
    final scale = total > 1 ? 1 / total : 1.0;
    canvas.save();
    canvas.clipRRect(bar);
    var x = 0.0;
    for (final s in segments) {
      final w = size.width * s.value * scale;
      if (w <= 0) continue;
      canvas.drawRect(Rect.fromLTWH(x, top, w, barHeight), Paint()..color = s.color);
      x += w;
      // Thin gap between segments.
      canvas.drawRect(Rect.fromLTWH(x - 1, top, 2, barHeight), Paint()..color = track);
    }
    canvas.restore();

    if (marker case final m?) {
      final mx = size.width * m.clamp(0.0, 1.0);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(mx, size.height / 2), width: 3, height: size.height),
          const Radius.circular(2),
        ),
        Paint()..color = markerColor,
      );
    }
  }

  @override
  bool shouldRepaint(_SegmentedBarPainter old) => true;
}

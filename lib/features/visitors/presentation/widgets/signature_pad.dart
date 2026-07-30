import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class SignaturePad extends StatefulWidget {
  final Function(ui.Image?) onChanged;
  final Color strokeColor;
  final double strokeWidth;

  const SignaturePad({
    super.key,
    required this.onChanged,
    this.strokeColor = Colors.black,
    this.strokeWidth = 3.0,
  });

  @override
  State<SignaturePad> createState() => SignaturePadState();
}

class SignaturePadState extends State<SignaturePad> {
  final List<Offset?> _points = <Offset?>[];

  void clear() {
    setState(() {
      _points.clear();
    });
    widget.onChanged(null);
  }

  Future<ui.Image?> exportSignature() async {
    if (_points.isEmpty) return null;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()
      ..color = widget.strokeColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = widget.strokeWidth;

    for (int i = 0; i < _points.length - 1; i++) {
      if (_points[i] != null && _points[i + 1] != null) {
        canvas.drawLine(_points[i]!, _points[i + 1]!, paint);
      }
    }

    final picture = recorder.endRecording();
    // We need to define a size for the image. 
    // This is a bit tricky without a fixed size, but we can use the bounding box or a standard size.
    return await picture.toImage(300, 150);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      height: 150,
      child: Stack(
        children: [
          GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                RenderBox renderBox = context.findRenderObject() as RenderBox;
                _points.add(renderBox.globalToLocal(details.globalPosition));
              });
            },
            onPanEnd: (details) async {
              _points.add(null);
              final image = await exportSignature();
              widget.onChanged(image);
            },
            child: CustomPaint(
              painter: SignaturePainter(points: _points, strokeColor: widget.strokeColor, strokeWidth: widget.strokeWidth),
              size: Size.infinite,
            ),
          ),
          Positioned(
            right: 8,
            top: 8,
            child: IconButton(
              icon: const Icon(Icons.clear, color: Colors.red),
              onPressed: clear,
            ),
          ),
          if (_points.isEmpty)
            const Center(
              child: Text(
                'Sign Here',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
        ],
      ),
    );
  }
}

class SignaturePainter extends CustomPainter {
  final List<Offset?> points;
  final Color strokeColor;
  final double strokeWidth;

  SignaturePainter({
    required this.points,
    required this.strokeColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = strokeColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(SignaturePainter oldDelegate) => oldDelegate.points != points;
}

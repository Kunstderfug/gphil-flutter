import 'package:flutter/material.dart';
import 'package:gphil/theme/constants.dart';

class PdfViewer extends StatefulWidget {
  const PdfViewer({super.key});

  @override
  State<PdfViewer> createState() => _PdfViewerState();
}

class _PdfViewerState extends State<PdfViewer> {
  double _height = 200.0;
  double _width = 200.0;
  double _left = 50.0;
  double _top = 0.0;

  void _updateSize(DragUpdateDetails details) {
    setState(() {
      _width += details.delta.dx;
      _height += details.delta.dy;
      _width = _width.clamp(
          150.0, MediaQuery.sizeOf(context).width); // Set min and max width
      _height = _height.clamp(100.0,
          MediaQuery.sizeOf(context).height - 120); // Set min and max height
    });
  }

  void updatePosition(DragUpdateDetails details) {
    setState(() {
      _left += details.delta.dx;
      _top += details.delta.dy;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _width,
      height: _height,
      child: Container(
        color: Colors.white10,
        child: GestureDetector(
          onPanUpdate: updatePosition,
          child: Stack(
            children: [
              Positioned(
                left: _left,
                top: _top,
                child: Container(
                  width: MediaQuery.sizeOf(context).width,
                  color: Colors.grey.shade900,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24.0, 8.0, 8.0, 8.0),
                    child: Text(
                      'PDF Viewer',
                      style: TextStyles().textMd,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 4,
                bottom: 4,
                child: GestureDetector(
                  onPanUpdate: _updateSize,
                  child: Transform.rotate(
                    angle: -90 * 3.14 / 180,
                    child: const Icon(
                      Icons.open_in_full,
                      size: 16.0,
                      color: Colors.white30,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

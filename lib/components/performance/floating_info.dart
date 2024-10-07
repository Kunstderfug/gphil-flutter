import 'package:flutter/material.dart';
import 'package:gphil/theme/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FloatingWindow extends StatefulWidget {
  final Widget child;
  final double initialWidth;
  final double initialHeight;

  const FloatingWindow({
    super.key,
    required this.child,
    this.initialWidth = 600,
    this.initialHeight = 300,
  });

  @override
  FloatingWindowState createState() => FloatingWindowState();
}

class FloatingWindowState extends State<FloatingWindow> {
  late double _width;
  late double _height;
  late double _bottom;
  late double _left;
  bool _isCollapsed = false;
  late double _opacity;
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    initializePrefs();
    _width = widget.initialWidth;
    _height = widget.initialHeight;
    _bottom = 50;
    _left = 50;
    _opacity = 0.8;
  }

  Future<void> initializePrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  void _updatePosition(DragUpdateDetails details) {
    setState(() {
      _left += details.delta.dx;
      _bottom += -details.delta.dy;
    });
  }

  void _updateSize(DragUpdateDetails details) {
    setState(() {
      _width += details.delta.dx;
      _height += -details.delta.dy;
      _width = _width.clamp(100, double.infinity);
      _height = _height.clamp(100, double.infinity);
    });
  }

  Future<void> saveSize() async {
    await prefs.setDouble('mixerInfoWidth', _width);
    await prefs.setDouble('mixerInfoHeight', _height);
  }

  void _toggleCollapse() {
    setState(() {
      _isCollapsed = !_isCollapsed;
    });

    void setOpacity(double value) {
      setState(() {
        _opacity = value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _left,
      bottom: _bottom,
      child: GestureDetector(
        onPanUpdate: _updatePosition,
        child: Container(
          width: _width - 40,
          height: _isCollapsed ? 40 : _height,
          decoration: BoxDecoration(
            color: AppColors().backroundColor(context).withOpacity(_opacity),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 5,
              ),
            ],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              if (!_isCollapsed) _buildResizeHandle(),
              if (!_isCollapsed)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(paddingLg),
                    child: widget.child,
                  ),
                ),
              _buildTitleBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleBar() {
    return GestureDetector(
      onTap: _toggleCollapse,
      child: Container(
        height: 40,
        padding: EdgeInsets.symmetric(horizontal: paddingMd),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Mixer Infor', style: TextStyle(color: Colors.white)),
            IconButton(
              icon: Icon(!_isCollapsed ? Icons.expand_more : Icons.expand_less,
                  color: Colors.white),
              onPressed: _toggleCollapse,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResizeHandle() {
    return GestureDetector(
      onPanUpdate: _updateSize,
      onPanEnd: (details) => saveSize,
      child: Container(
        height: 20,
        alignment: Alignment.bottomRight,
        child: Transform.rotate(
            angle: 45,
            child: Icon(Icons.arrow_drop_up, size: 20, color: Colors.grey)),
      ),
    );
  }
}

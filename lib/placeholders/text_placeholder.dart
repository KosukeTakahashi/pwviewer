import 'package:flutter/material.dart';

class TextPlaceholder extends StatefulWidget {
  @override
  _TextPlaceholderState createState() => _TextPlaceholderState();
}

class _TextPlaceholderState extends State<TextPlaceholder>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    setState(() {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      )..repeat(reverse: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller!.drive(Tween(begin: 0.6, end: 0.3)),
      child: Container(
        color: Colors.grey,
        child: Text('......'),
      ),
    );
  }
}

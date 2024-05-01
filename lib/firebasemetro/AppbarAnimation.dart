import 'package:flutter/material.dart';

class AnimatedAppBar extends StatefulWidget {
  final Function(bool) onOverflow;
  bool isOverflowed = false;
  AnimatedAppBar(
      {Key? key, required this.onOverflow, required this.isOverflowed})
      : super(key: key);

  @override
  _AnimatedAppBarState createState() => _AnimatedAppBarState();
}

class _AnimatedAppBarState extends State<AnimatedAppBar> {
  @override
  Widget build(BuildContext context) {
    return OverflowBox(
      maxWidth: double.infinity,
      child: AnimatedPositioned(
        duration: Duration(milliseconds: 300),
        left: widget.isOverflowed ? -50 : 0,
        right: widget.isOverflowed ? -50 : 0,
        top: 0,
        child: AppBar(
          title: const Row(
            children: [
              Text(
                'Long Text That Might Overflow',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ],
          ),
          backgroundColor: const Color.fromARGB(255, 14, 72, 171),
        ),
        onEnd: () {
          widget.onOverflow(widget.isOverflowed);
        },
      ),
    );
  }
}

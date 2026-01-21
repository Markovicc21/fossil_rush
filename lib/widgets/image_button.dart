import 'package:flutter/material.dart';

Widget imageButton({
  required String asset,
  required VoidCallback onPressed,
  double width = 260,
  double height = 100,
}) {
  bool isPressed = false;

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: StatefulBuilder(
      builder: (context, setState) {
        void setPressed(bool v) => setState(() => isPressed = v);

        return GestureDetector(
          onTap: onPressed,
          onTapDown: (_) => setPressed(true),
          onTapUp: (_) => setPressed(false),
          onTapCancel: () => setPressed(false),

          child: AnimatedContainer(
            duration: const Duration(milliseconds: 90),
            transform: Matrix4.translationValues(0, isPressed ? 3 : 0, 0),
            child: Image.asset(
              asset,
              width: width,
              height: height,
              filterQuality: FilterQuality.none,
            ),
          ),
        );
      },
    ),
  );
}

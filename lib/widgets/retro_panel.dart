import 'package:flutter/material.dart';

class RetroPanel extends StatelessWidget {
  final Widget child;
  final Color fill;
  final EdgeInsets padding;
  final double shadowOffset;
  final double radius;
  final bool simple;
  final Color borderColor;
  final double borderWidth;

  const RetroPanel({
    super.key,
    required this.child,
    required this.fill,
    this.padding = const EdgeInsets.all(12),
    this.shadowOffset = 4,
    this.radius = 0,
    this.simple = false,
    this.borderColor = const Color(0xFF2A1A12),
    this.borderWidth = 3,
  });

  @override
  Widget build(BuildContext contex) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A1A12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2A1A12),
            offset: Offset(shadowOffset, shadowOffset),
            blurRadius: 0,
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(3),
        color: fill,
        child: Container(
          margin: EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: fill,
            border: Border.all(color: const Color(0xFF7A4B2E), width: 2),
          ),
          child: Stack(
            children: [
              //highlight
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SizedBox(
                  height: 2,
                  child: ColoredBox(color: Color(0xFFFFE7C2)),
                ),
              ),
              const Positioned(
                top: 0,
                left: 0,
                bottom: 0,
                child: SizedBox(
                  width: 2,
                  child: ColoredBox(color: Color(0xFFFFE7C2)),
                ),
              ),

              //shade
              const Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SizedBox(
                  height: 2,
                  child: ColoredBox(color: Color(0xFF1B100C)),
                ),
              ),

              Padding(padding: padding, child: child),
            ],
          ),
        ),
      ),
    );
  }
}

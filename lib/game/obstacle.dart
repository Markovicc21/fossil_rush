import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Obstacle extends RectangleComponent {
  // OBSTACLE JE PROST RECTANGLE
  // kasnije ide sprite / animacija

  Obstacle({required Vector2 position, required Vector2 size})
    : super(
        position: position,
        size: size,
        paint: Paint()..color = const Color(0xFFFF4444),
      );
}

import 'package:flutter/material.dart';

Widget pixelInput({
  required String hint,
  bool obscure = false,
  required TextEditingController controller,
}) {
  return TextField(
    controller: controller,
    obscureText: obscure,
    style: const TextStyle(fontSize: 14, color: Color(0xFF2A1A12)),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF5C4033)),
      filled: true,
      fillColor: const Color(0xFFD6B48A),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFF2A1A12), width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFFFFA726), width: 2),
      ),
    ),
  );
}

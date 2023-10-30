import 'package:flutter/material.dart';
import 'package:light_shooter/shared/theme/game_colors.dart';

class GameTextField extends StatelessWidget {
  final String? hint;
  final bool enabled;
  final FormFieldValidator<String>? validator;
  final TextEditingController? controller;
  final ValueChanged<String>? onFieldSubmitted;
  const GameTextField({
    super.key,
    this.controller,
    this.hint,
    this.enabled = true,
    this.validator,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        contentPadding: const EdgeInsets.only(left: 16),
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(20),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: GameColors.primary, width: 2),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

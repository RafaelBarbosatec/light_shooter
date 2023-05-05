import 'package:flutter/material.dart';
import 'package:light_shooter/shared/theme/game_colors.dart';

class GameTextField extends StatelessWidget {
  final String? hint;
  const GameTextField({super.key, this.hint});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: TextFormField(
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
      ),
    );
  }
}

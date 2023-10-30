import 'package:flutter/material.dart';
import 'package:light_shooter/game/util/player_spritesheet.dart';
import 'package:light_shooter/shared/theme/game_colors.dart';

class GameColorSelector extends StatelessWidget {
  final PlayerColor? colorSelected;
  final ValueChanged<PlayerColor>? onChanged;
  const GameColorSelector({super.key, this.colorSelected, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: PlayerColor.values.map(_buildItem).toList(),
    );
  }

  Widget _buildItem(PlayerColor e) {
    return InkWell(
      onTap: () => onChanged?.call(e),
      child: Container(
        width: 40,
        height: 40,
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: e.getColor(),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: e == colorSelected ? Colors.white : GameColors.background,
            width: 4,
          ),
        ),
      ),
    );
  }
}

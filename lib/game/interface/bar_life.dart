// ignore_for_file: non_constant_identifier_names

import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:light_shooter/game/player/breaker.dart';
import 'package:light_shooter/game/player/weapons/breaker_cannon.dart';
import 'package:light_shooter/shared/theme/game_colors.dart';
import 'package:light_shooter/shared/widgets/change_notifier_builder.dart';

class BarLife extends StatefulWidget {
  static String name = 'Barlife';
  final BonfireGame game;
  const BarLife({super.key, required this.game});

  @override
  State<BarLife> createState() => _BarLifeState();
}

class _BarLifeState extends State<BarLife> {
  final double BAR_WIDTH = 100;
  final double BAR_HEIGHT = 20;
  final double BORDER_RADIUS = 10;

  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {});
    });
    super.initState();
  }

  Breaker? get player {
    return (widget.game.player as Breaker?);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        decoration: BoxDecoration(
          color: GameColors.background,
          borderRadius: BorderRadius.circular(BORDER_RADIUS),
        ),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (player?.gun != null) ...[
              ChangeNotifierBuilder<Breaker>(
                value: player!,
                builder: _buildLife,
              ),
              const SizedBox(height: 10),
              ChangeNotifierBuilder<BreakerCannon>(
                value: player!.gun!,
                builder: _buildCountBullet,
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildCountBullet(BuildContext context, BreakerCannon value) {
    double height = BAR_HEIGHT / 1.5;
    if (value.reloading) {
      double percent = value.currentTimeReload / value.timeToReload;
      return Container(
        width: BAR_WIDTH,
        height: height,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(BORDER_RADIUS),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.yellow,
            borderRadius: BorderRadius.circular(BORDER_RADIUS),
          ),
          margin: EdgeInsets.only(right: BAR_WIDTH * (1 - percent)),
        ),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(value.countBullet, (index) {
        return Container(
          width: BAR_HEIGHT / 4,
          height: height,
          margin: const EdgeInsets.only(right: 5),
          color: Colors.blue,
        );
      }),
    );
  }

  Widget _buildLife(BuildContext context, Breaker value) {
    double percent = value.life / Breaker.maxLive;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          height: BAR_HEIGHT,
          width: BAR_WIDTH,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(BORDER_RADIUS),
            border: Border.all(color: Colors.white),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(BORDER_RADIUS),
              color: _getColor(percent),
            ),
            height: BAR_HEIGHT,
            margin: EdgeInsets.only(right: BAR_WIDTH * (1 - percent)),
          ),
        ),
      ],
    );
  }

  Color _getColor(double percent) {
    if (percent > 0.8) {
      return Colors.green;
    }
    if (percent > 0.3) {
      return Colors.yellow;
    }

    return Colors.red;
  }
}

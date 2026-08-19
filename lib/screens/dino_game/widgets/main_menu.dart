import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:vn_template/common_widgets/common_text_widget.dart';
import 'package:vn_template/core/constant/app_string.dart';
import 'package:vn_template/core/constant/dino_game_asset_strings.dart';
import 'package:vn_template/screens/dino_game/game/dino_run.dart';
import 'package:vn_template/screens/dino_game/widgets/hud.dart';



// This represents the main menu overlay.
class MainMenu extends StatelessWidget {
  // An unique identified for this overlay.
  static const id = 'MainMenu';

  // Reference to parent game.
  final DinoRun game;

  const MainMenu(this.game, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: Colors.black.withAlpha(100),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 20,
                horizontal: 100,
              ),
              child: Wrap(
                direction: Axis.vertical,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10,
                children: [
                  const CommonTextWidget(
                    text: AppStrings.txtDinoRun,
                    textStyle: TextStyle(
                      fontSize: 50,
                      color: Colors.white,
                      fontFamily: DinoGameAssets.fontAudiowide,
                    ),
                  ),

                  ElevatedButton(
                    onPressed: () {
                      game.startGamePlay();
                      game.overlays.remove(MainMenu.id);
                      game.overlays.add(Hud.id);
                    },
                    child: CommonTextWidget(
                      text: AppStrings.txtPlay,
                      textStyle: const TextStyle(fontSize: 30),
                    ),
                  ),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:ui';
import 'package:flame/camera.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vn_template/screens/dino_game/game/audio_manager.dart';
import 'package:vn_template/screens/dino_game/game/dino_run.dart';
import 'package:vn_template/screens/dino_game/widgets/game_over_menu.dart';
import 'package:vn_template/screens/dino_game/widgets/hud.dart';
import 'package:vn_template/screens/dino_game/widgets/main_menu.dart';
import 'package:vn_template/screens/dino_game/widgets/pause_menu.dart';
import 'package:vn_template/screens/dino_game/widgets/settings_menu.dart';


class DinoView extends StatefulWidget {
  const DinoView({super.key});

  @override
  State<DinoView> createState() => _DinoViewState();
}

class _DinoViewState extends State<DinoView> {
  late DinoRun _game;

  @override
  void initState() {
    super.initState();
    // Set orientation to landscape when entering the game.
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _game = DinoRun(
      camera: CameraComponent.withFixedResolution(
        width: 360,
        height: 180,
      ),
    );
  }

  @override
  void dispose() {
    // Reset orientation to portrait when exiting the game.
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        final isMainMenuActive = _game.overlays.isActive(MainMenu.id);
        final isPauseMenuActive = _game.overlays.isActive(PauseMenu.id);
        final isGameOverActive = _game.overlays.isActive(GameOverMenu.id);
        final isSettingsMenuActive = _game.overlays.isActive(SettingsMenu.id);

        if (isMainMenuActive || isPauseMenuActive || isGameOverActive || isSettingsMenuActive) {
          // If any dialog/menu is already showing, back press does nothing.
          return;
        }

        // If no menu/dialog is showing, pause the game and show the PauseMenu dialog.
        if (_game.overlays.isActive(Hud.id)) {
          _game.overlays.remove(Hud.id);
          _game.overlays.add(PauseMenu.id);
          _game.pauseEngine();
          AudioManager.instance.pauseBgm();
        }
      },
      child: Scaffold(
        body: GameWidget<DinoRun>.controlled(
          // This will display a loading bar until [DinoRun] completes
          // its onLoad method.
          loadingBuilder: (context) => const Center(
            child: SizedBox(width: 200, child: LinearProgressIndicator()),
          ),
          // Register all the overlays that will be used by this game.
          overlayBuilderMap: {
            MainMenu.id: (_, game) => MainMenu(game),
            PauseMenu.id: (_, game) => PauseMenu(game),
            Hud.id: (_, game) => Hud(game),
            GameOverMenu.id: (_, game) => GameOverMenu(game),
            SettingsMenu.id: (_, game) => SettingsMenu(game),
          },
          // By default MainMenu overlay will be active.
          initialActiveOverlays: const [MainMenu.id],
          gameFactory: () => _game,
        ),
      ),
    );
  }
}

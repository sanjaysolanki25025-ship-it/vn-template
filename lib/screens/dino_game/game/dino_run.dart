import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:hive/hive.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:vn_template/core/constant/dino_game_asset_strings.dart';
import 'package:vn_template/data/models/dino_game_models/player_data.dart';
import 'package:vn_template/data/models/dino_game_models/settings.dart';
import 'package:vn_template/screens/dino_game/game/audio_manager.dart';
import 'package:vn_template/screens/dino_game/game/dino.dart';
import 'package:vn_template/screens/dino_game/game/enemy_manager.dart';
import 'package:vn_template/screens/dino_game/widgets/game_over_menu.dart';
import 'package:vn_template/screens/dino_game/widgets/hud.dart';
import 'package:vn_template/screens/dino_game/widgets/pause_menu.dart';

// This is the main flame game class.
class DinoRun extends FlameGame with TapCallbacks, HasCollisionDetection {
  DinoRun({super.camera});

  // List of all the image assets.
  static const _imageAssets = DinoGameAssets.imageAssets;

  // List of all the audio assets.
  static const _audioAssets = DinoGameAssets.audioAssets;

  late Dino _dino;
  late Settings settings;
  late PlayerData playerData;
  late EnemyManager _enemyManager;
  bool _isGameOver = false;

  Vector2 get virtualSize => camera.viewport.virtualSize;

  // This method get called while flame is preparing this game.
  @override
  Future<void> onLoad() async {
    // Makes the game full screen and landscape only.
    await Flame.device.fullScreen();
    await Flame.device.setLandscape();

    /// Read [PlayerData] and [Settings] from hive.
    playerData = await _readPlayerData();
    settings = await _readSettings();
    // playerData.resetScore();
    // playerData.lives = 1;

    /// Initilize [AudioManager].
    FlameAudio.audioCache.prefix = DinoGameAssets.audioPrefix;
    images.prefix = DinoGameAssets.imagesPrefix;
    await AudioManager.instance.init(_audioAssets, settings);

    // Start playing background music. Internally takes care
    // of checking user settings.
    AudioManager.instance.startBgm(DinoGameAssets.backgroundMusic);

    // Cache all the images.
    await images.loadAll(_imageAssets);

    // This makes the camera look at the center of the viewport.
    camera.viewfinder.position = camera.viewport.virtualSize * 0.5;

    /// Create a [ParallaxComponent] and add it to game.
    final parallaxBackground = await loadParallaxComponent(
      DinoGameAssets.parallaxImages.map((image) => ParallaxImageData(image)).toList(),
      baseVelocity: Vector2(10, 0),
      velocityMultiplierDelta: Vector2(1.4, 0),
    );

    // Add the parallax as the backdrop.
    camera.backdrop.add(parallaxBackground);

    // Precache Interstitial Ad
    // AdHelper.precacheLandscapeInterstitialAd(adId: AppAdIdString.homeReelsInterstitialAd);
  }

  /// This method add the already created [Dino]
  /// and [EnemyManager] to this game.
  void startGamePlay() {
    _dino = Dino(images.fromCache(DinoGameAssets.dino), playerData);
    _enemyManager = EnemyManager();
    _isGameOver = false;

    world.add(_dino);

    world.add(_enemyManager);
  }

  // This method remove all the actors from the game.
  void _disconnectActors() {
    _dino.removeFromParent();
    _enemyManager.removeAllEnemies();
    _enemyManager.removeFromParent();
  }

  // This method reset the whole game world to initial state.
  void reset() {
    // First disconnect all actions from game world.
    _disconnectActors();

    // Reset player data to inital values.
    playerData.resetScore();
    playerData.lives = 1;
    _isGameOver = false;
  }

  // This method gets called for each tick/frame of the game.
  @override
  void update(double dt) {
    // If number of lives is 0 or less, game is over.
    if (playerData.lives <= 0) {
      if (!_isGameOver) {
        _isGameOver = true;
        overlays.add(GameOverMenu.id);
        overlays.remove(Hud.id);
        pauseEngine();
        AudioManager.instance.pauseBgm();
      }
    }
    super.update(dt);
  }


  // This will get called for each tap on the screen.
  @override
  void onTapDown(TapDownEvent event) {
    // Make dino jump only when game is playing.
    // When game is in playing state, only Hud will be the active overlay.
    if (overlays.isActive(Hud.id)) {
      _dino.jump();
    }
    super.onTapDown(event);
  }

  /// This method reads [PlayerData] from the hive box.
  Future<PlayerData> _readPlayerData() async {
    final playerDataBox = await Hive.openBox<PlayerData>('DinoRun.PlayerDataBox');
    final playerData = playerDataBox.get('DinoRun.PlayerData');

    // If data is null, this is probably a fresh launch of the game.
    if (playerData == null) {
      // In such cases store default values in hive.
      await playerDataBox.put('DinoRun.PlayerData', PlayerData());
    }

    // Now it is safe to return the stored value.
    return playerDataBox.get('DinoRun.PlayerData')!;
  }

  /// This method reads [Settings] from the hive box.
  Future<Settings> _readSettings() async {
    final settingsBox = await Hive.openBox<Settings>('DinoRun.SettingsBox');
    final settings = settingsBox.get('DinoRun.Settings');

    // If data is null, this is probably a fresh launch of the game.
    if (settings == null) {
      // In such cases store default values in hive.
      await settingsBox.put('DinoRun.Settings', Settings(bgm: true, sfx: true));
    }

    // Now it is safe to return the stored value.
    return settingsBox.get('DinoRun.Settings')!;
  }

  @override
  void lifecycleStateChange(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // On resume, if active overlay is not PauseMenu,
        // resume the engine (lets the parallax effect play).
        if (!(overlays.isActive(PauseMenu.id)) && !(overlays.isActive(GameOverMenu.id))) {
          resumeEngine();
        }
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        // If game is active, then remove Hud and add PauseMenu
        // before pausing the game.
        if (overlays.isActive(Hud.id)) {
          overlays.remove(Hud.id);
          overlays.add(PauseMenu.id);
        }
        pauseEngine();
        break;
    }
    super.lifecycleStateChange(state);
  }
}

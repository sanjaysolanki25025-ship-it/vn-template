class DinoGameAssets {
  DinoGameAssets._();

  // Images Prefix
  static const String imagesPrefix = 'assets/game/images/';
  
  // Audio Prefix
  static const String audioPrefix = 'assets/game/audio/';

  // Fonts
  static const String fontAudiowide = 'Audiowide';

  // Images
  static const String dino = 'DinoSprites - tard.png';
  static const String angryPig = 'AngryPig/Walk (36x30).png';
  static const String bat = 'Bat/Flying (46x30).png';
  static const String rino = 'Rino/Run (52x34).png';
  
  static const String background = 'background.png';
  
  static const List<String> parallaxImages = [
    'parallax/plx-1.png',
    'parallax/plx-2.png',
    'parallax/plx-3.png',
    'parallax/plx-4.png',
    'parallax/plx-5.png',
    'parallax/plx-6.png',
  ];

  // Audio
  static const String backgroundMusic = '8BitPlatformerLoop.wav';
  static const String hurtSound = 'hurt7.wav';
  static const String jumpSound = 'jump14.wav';

  static const List<String> imageAssets = [
    dino,
    angryPig,
    bat,
    rino,
    'parallax/plx-1.png',
    'parallax/plx-2.png',
    'parallax/plx-3.png',
    'parallax/plx-4.png',
    'parallax/plx-5.png',
    'parallax/plx-6.png',
  ];

  static const List<String> audioAssets = [
    backgroundMusic,
    hurtSound,
    jumpSound,
  ];
}

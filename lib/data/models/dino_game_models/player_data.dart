import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:vn_template/data/helper/preferences_helper.dart';

part 'player_data.g.dart';

// This class stores the player progress presistently.
@HiveType(typeId: 0)
class PlayerData extends ChangeNotifier with HiveObjectMixin {
  @HiveField(1)
  int highScore = 0;

  int _lives = 1;

  int get lives => _lives;
  set lives(int value) {
    if (value <= 1 && value >= 0) {
      _lives = value;
      notifyListeners();
    }
  }

  int _currentScore = 0;

  int get currentScore => _currentScore;
  set currentScore(int value) {
    if (value > _currentScore) {
      final int diff = value - _currentScore;
      final int totalCoin = AppPreferences().getInt(AppPreferences.coin) ?? 0;
      AppPreferences().setInt(AppPreferences.coin, totalCoin + diff);
    }
    _currentScore = value;

    if (highScore < _currentScore) {
      highScore = _currentScore;
    }

    notifyListeners();
    save();
  }

  /// Internal jump counter for jump-based scoring.
  int _jumpCount = 0;

  /// Increments jump count and updates [currentScore]
  /// if the jump count reaches 5.
  void incrementJump() {
    _jumpCount++;
    if (_jumpCount >= 5) {
      currentScore += 1;
      _jumpCount = 0;
    }
  }

  /// Resets the score and jump counter.
  void resetScore() {
    currentScore = 0;
    _jumpCount = 0;
  }
}

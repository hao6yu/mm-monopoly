import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'audio_catalog.dart';

/// Sound effect types used throughout the game.
enum SfxType {
  diceRoll,
  diceHit,
  tokenMove,
  tokenLand,
  buyProperty,
  payMoney,
  collectMoney,
  cardDraw,
  cardFlip,
  jailDoor,
  passGo,
  victory,
  defeat,
  powerUp,
  spinWheel,
  spinResult,
  buttonTap,
  upgrade,
  auction,
  trade,
  notification,
}

/// Coordinates music, adaptive mixing, and concurrent game sound effects.
class AudioService {
  static final AudioService _instance = AudioService._internal();
  static AudioService get instance => _instance;

  AudioService._internal();

  static const _crossFadeDuration = Duration(milliseconds: 1400);
  static const _crossFadeSteps = 20;
  static const _sfxVoiceCount = 6;

  final List<AudioPlayer> _bgmPlayers = List.generate(2, (_) => AudioPlayer());
  final List<AudioPlayer> _sfxPlayers = List.generate(
    _sfxVoiceCount,
    (_) => AudioPlayer(),
  );
  final List<StreamSubscription<void>> _bgmCompletionSubscriptions = [];
  final NoRepeatPlaylist _playlist = NoRepeatPlaylist();

  bool _musicEnabled = true;
  bool _sfxEnabled = true;
  double _musicVolume = 0.5;
  double _sfxVolume = 0.7;

  bool _initialized = false;
  bool _disposed = false;
  bool _isPlaylistMode = false;
  String? _currentBgm;
  String? _currentBoardId;
  ReleaseMode _currentReleaseMode = ReleaseMode.loop;
  MusicIntensity _musicIntensity = MusicIntensity.standard;

  int _activeBgmIndex = 0;
  int _sfxCursor = 0;
  int _musicTransitionGeneration = 0;
  int _duckGeneration = 0;
  double _duckGain = 1;
  final List<double> _bgmMix = [0, 0];
  final List<double> _bgmTrackGain = [1, 1];

  bool get musicEnabled => _musicEnabled;
  bool get sfxEnabled => _sfxEnabled;
  double get musicVolume => _musicVolume;
  double get sfxVolume => _sfxVolume;
  bool get isPlaying =>
      _bgmPlayers.any((player) => player.state == PlayerState.playing);
  String? get currentBgm => _currentBgm;
  String? get currentBoardId => _currentBoardId;
  MusicIntensity get musicIntensity => _musicIntensity;

  Future<void> init() async {
    if (_initialized || _disposed) return;

    final prefs = await SharedPreferences.getInstance();
    _musicEnabled = prefs.getBool('audio_music_enabled') ?? true;
    _sfxEnabled = prefs.getBool('audio_sfx_enabled') ?? true;
    _musicVolume = prefs.getDouble('audio_music_volume') ?? 0.5;
    _sfxVolume = prefs.getDouble('audio_sfx_volume') ?? 0.7;

    for (var index = 0; index < _bgmPlayers.length; index++) {
      final player = _bgmPlayers[index];
      await player.setReleaseMode(ReleaseMode.stop);
      await player.setVolume(0);
      _bgmCompletionSubscriptions.add(
        player.onPlayerComplete.listen((_) {
          if (_activeBgmIndex == index &&
              _isPlaylistMode &&
              _musicEnabled &&
              !_disposed) {
            unawaited(_playNextTrack());
          }
        }),
      );
    }
    for (final player in _sfxPlayers) {
      await player.setReleaseMode(ReleaseMode.stop);
      await player.setVolume(_sfxVolume);
    }

    _initialized = true;
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('audio_music_enabled', _musicEnabled);
    await prefs.setBool('audio_sfx_enabled', _sfxEnabled);
    await prefs.setDouble('audio_music_volume', _musicVolume);
    await prefs.setDouble('audio_sfx_volume', _sfxVolume);
  }

  Future<void> setMusicEnabled(bool enabled) async {
    _musicEnabled = enabled;
    _musicTransitionGeneration++;

    if (!enabled) {
      await Future.wait(
        _bgmPlayers
            .where((player) => player.state == PlayerState.playing)
            .map((player) => player.pause()),
      );
    } else if (_currentBgm != null) {
      final track = _currentBgm!;
      _currentBgm = null;
      await _crossFadeTo(
        track,
        releaseMode: _currentReleaseMode,
        duration: const Duration(milliseconds: 350),
      );
    }
    await _saveSettings();
  }

  Future<void> setSfxEnabled(bool enabled) async {
    _sfxEnabled = enabled;
    if (!enabled) {
      await Future.wait(
        _sfxPlayers
            .where((player) => player.state == PlayerState.playing)
            .map((player) => player.stop()),
      );
    }
    await _saveSettings();
  }

  Future<void> setMusicVolume(double volume) async {
    _musicVolume = volume.clamp(0.0, 1.0);
    await _applyBgmVolumes();
    await _saveSettings();
  }

  Future<void> setSfxVolume(double volume) async {
    _sfxVolume = volume.clamp(0.0, 1.0);
    await Future.wait(
      _sfxPlayers.map((player) => player.setVolume(_sfxVolume)),
    );
    await _saveSettings();
  }

  Future<void> setMusicIntensity(MusicIntensity intensity) async {
    if (_musicIntensity == intensity) return;
    _musicIntensity = intensity;
    await _applyBgmVolumes();
  }

  Future<void> playBgm(String trackName) async {
    _isPlaylistMode = false;
    await _crossFadeTo(trackName, releaseMode: ReleaseMode.loop);
  }

  Future<void> playMenuMusic() async {
    _currentBoardId = null;
    _musicIntensity = MusicIntensity.relaxed;
    _isPlaylistMode = false;
    await _crossFadeTo(AudioCatalog.menuTrack, releaseMode: ReleaseMode.loop);
  }

  Future<void> playGameMusic({String? boardId}) async {
    _currentBoardId = boardId;
    _musicIntensity = MusicIntensity.standard;
    _isPlaylistMode = true;

    final profile = AudioCatalog.profileForBoard(boardId);
    _playlist.reset(profile.tracks, lastTrack: _currentBgm);
    final firstTrack = _playlist.next();
    if (firstTrack != null) {
      await _crossFadeTo(firstTrack, releaseMode: ReleaseMode.stop);
    }
  }

  Future<void> _playNextTrack() async {
    if (!_isPlaylistMode || !_musicEnabled || _disposed) return;
    final nextTrack = _playlist.next();
    if (nextTrack != null) {
      await _crossFadeTo(nextTrack, releaseMode: ReleaseMode.stop);
    }
  }

  Future<void> playVictoryMusic() async {
    _isPlaylistMode = false;
    _musicIntensity = MusicIntensity.standard;
    await _crossFadeTo(
      AudioCatalog.victoryTrack,
      releaseMode: ReleaseMode.stop,
    );
  }

  Future<void> _crossFadeTo(
    String trackName, {
    required ReleaseMode releaseMode,
    Duration duration = _crossFadeDuration,
  }) async {
    if (_disposed) return;
    _currentReleaseMode = releaseMode;

    if (!_musicEnabled) {
      _currentBgm = trackName;
      return;
    }
    if (_currentBgm == trackName &&
        _bgmPlayers[_activeBgmIndex].state == PlayerState.playing) {
      await _applyBgmVolumes();
      return;
    }

    final generation = ++_musicTransitionGeneration;
    final outgoingIndex = _activeBgmIndex;
    final incomingIndex = 1 - outgoingIndex;
    final incoming = _bgmPlayers[incomingIndex];
    final outgoing = _bgmPlayers[outgoingIndex];
    final hadOutgoingTrack =
        _currentBgm != null &&
        (outgoing.state == PlayerState.playing ||
            outgoing.state == PlayerState.paused);

    try {
      await incoming.stop();
      await incoming.setReleaseMode(releaseMode);
      _bgmMix[incomingIndex] = 0;
      _bgmTrackGain[incomingIndex] = AudioCatalog.playbackGainFor(trackName);
      await incoming.play(AssetSource('audio/music/$trackName'), volume: 0);
    } catch (error) {
      debugPrint('BGM not found: $trackName ($error)');
      return;
    }

    _activeBgmIndex = incomingIndex;
    _currentBgm = trackName;
    final stepDelay = Duration(
      microseconds: duration.inMicroseconds ~/ _crossFadeSteps,
    );

    for (var step = 1; step <= _crossFadeSteps; step++) {
      if (generation != _musicTransitionGeneration || _disposed) return;
      final progress = step / _crossFadeSteps;
      _bgmMix[incomingIndex] = progress;
      _bgmMix[outgoingIndex] = hadOutgoingTrack ? 1 - progress : 0;
      await _applyBgmVolumes();
      if (step < _crossFadeSteps) {
        await Future<void>.delayed(stepDelay);
      }
    }

    if (generation != _musicTransitionGeneration || _disposed) return;
    await outgoing.stop();
    _bgmMix[outgoingIndex] = 0;
    _bgmMix[incomingIndex] = 1;
    await _applyBgmVolumes();
  }

  Future<void> _applyBgmVolumes() async {
    if (_disposed) return;
    final intensityGain = switch (_musicIntensity) {
      MusicIntensity.relaxed => 0.84,
      MusicIntensity.standard => 0.94,
      MusicIntensity.tense => 1.0,
    };
    await Future.wait([
      for (var index = 0; index < _bgmPlayers.length; index++)
        _bgmPlayers[index].setVolume(
          (_musicVolume *
                  intensityGain *
                  _duckGain *
                  _bgmMix[index] *
                  _bgmTrackGain[index])
              .clamp(0.0, 1.0),
        ),
    ]);
  }

  Future<void> _duckMusic({
    Duration duration = const Duration(milliseconds: 800),
    double gain = 0.5,
  }) async {
    final generation = ++_duckGeneration;
    _duckGain = gain;
    await _applyBgmVolumes();
    await Future<void>.delayed(duration);
    if (generation != _duckGeneration || _disposed) return;
    _duckGain = 1;
    await _applyBgmVolumes();
  }

  Future<void> stopBgm() async {
    _musicTransitionGeneration++;
    _isPlaylistMode = false;
    _playlist.reset(const []);
    await Future.wait(_bgmPlayers.map((player) => player.stop()));
    _bgmMix
      ..[0] = 0
      ..[1] = 0;
    _currentBgm = null;
    _currentBoardId = null;
  }

  Future<void> pauseBgm() async {
    await Future.wait(
      _bgmPlayers
          .where((player) => player.state == PlayerState.playing)
          .map((player) => player.pause()),
    );
  }

  Future<void> resumeBgm() async {
    if (!_musicEnabled || _currentBgm == null) return;
    final active = _bgmPlayers[_activeBgmIndex];
    if (active.state == PlayerState.paused) {
      await active.resume();
    }
  }

  Future<void> playSfx(SfxType type) async {
    if (!_sfxEnabled || _disposed) return;

    if (_shouldDuckMusic(type)) {
      unawaited(_duckMusic());
    }

    final filename = _getSfxFilename(type);
    final player = _nextSfxPlayer();
    try {
      if (player.state == PlayerState.playing ||
          player.state == PlayerState.paused) {
        await player.stop();
      }
      await player.play(AssetSource('audio/sfx/$filename'), volume: _sfxVolume);
    } catch (error) {
      debugPrint('SFX not found: $filename ($error)');
    }
  }

  AudioPlayer _nextSfxPlayer() {
    for (final player in _sfxPlayers) {
      if (player.state != PlayerState.playing) return player;
    }
    final player = _sfxPlayers[_sfxCursor % _sfxPlayers.length];
    _sfxCursor = (_sfxCursor + 1) % _sfxPlayers.length;
    return player;
  }

  bool _shouldDuckMusic(SfxType type) =>
      type == SfxType.cardDraw ||
      type == SfxType.jailDoor ||
      type == SfxType.passGo ||
      type == SfxType.victory ||
      type == SfxType.defeat ||
      type == SfxType.spinResult;

  String _getSfxFilename(SfxType type) {
    return switch (type) {
      SfxType.diceRoll => 'dice_roll.mp3',
      SfxType.diceHit => 'dice_hit.mp3',
      SfxType.tokenMove => 'token_move.mp3',
      SfxType.tokenLand => 'token_land.mp3',
      SfxType.buyProperty => 'buy_property.mp3',
      SfxType.payMoney => 'pay_money.mp3',
      SfxType.collectMoney => 'collect_money.mp3',
      SfxType.cardDraw => 'card_draw.mp3',
      SfxType.cardFlip => 'card_flip.mp3',
      SfxType.jailDoor => 'jail_door.mp3',
      SfxType.passGo => 'pass_go.mp3',
      SfxType.victory => 'victory.mp3',
      SfxType.defeat => 'defeat.mp3',
      SfxType.powerUp => 'power_up.mp3',
      SfxType.spinWheel => 'spin_wheel.mp3',
      SfxType.spinResult => 'spin_result.mp3',
      SfxType.buttonTap => 'button_tap.mp3',
      SfxType.upgrade => 'upgrade.mp3',
      SfxType.auction => 'auction.mp3',
      SfxType.trade => 'trade.mp3',
      SfxType.notification => 'notification.mp3',
    };
  }

  Future<void> onDiceRoll() => playSfx(SfxType.diceRoll);
  Future<void> onDiceLand() => playSfx(SfxType.diceHit);
  Future<void> onTokenStep() => playSfx(SfxType.tokenMove);
  Future<void> onTokenLand() => playSfx(SfxType.tokenLand);
  Future<void> onBuyProperty() => playSfx(SfxType.buyProperty);
  Future<void> onPayMoney() => playSfx(SfxType.payMoney);
  Future<void> onCollectMoney() => playSfx(SfxType.collectMoney);
  Future<void> onDrawCard() => playSfx(SfxType.cardDraw);
  Future<void> onFlipCard() => playSfx(SfxType.cardFlip);
  Future<void> onJail() => playSfx(SfxType.jailDoor);
  Future<void> onPassGo() => playSfx(SfxType.passGo);
  Future<void> onVictory() => playSfx(SfxType.victory);
  Future<void> onDefeat() => playSfx(SfxType.defeat);
  Future<void> onPowerUp() => playSfx(SfxType.powerUp);
  Future<void> onSpinWheel() => playSfx(SfxType.spinWheel);
  Future<void> onSpinResult() => playSfx(SfxType.spinResult);
  Future<void> onButtonTap() => playSfx(SfxType.buttonTap);
  Future<void> onUpgrade() => playSfx(SfxType.upgrade);
  Future<void> onAuction() => playSfx(SfxType.auction);
  Future<void> onTrade() => playSfx(SfxType.trade);
  Future<void> onNotification() => playSfx(SfxType.notification);

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _musicTransitionGeneration++;
    _duckGeneration++;
    await Future.wait(
      _bgmCompletionSubscriptions.map((subscription) => subscription.cancel()),
    );
    await Future.wait([
      ..._bgmPlayers.map((player) => player.dispose()),
      ..._sfxPlayers.map((player) => player.dispose()),
    ]);
  }
}

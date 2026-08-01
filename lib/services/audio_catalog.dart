import 'dart:math';

enum MusicIntensity { relaxed, standard, tense }

class CityMusicProfile {
  const CityMusicProfile({
    required this.id,
    required this.tracks,
    this.ambienceAsset,
  });

  final String id;
  final List<String> tracks;
  final String? ambienceAsset;
}

class AudioCatalog {
  const AudioCatalog._();

  static const menuTrack = 'menu_theme.mp3';
  static const victoryTrack = 'victory_theme.mp3';

  static const gameTracks = [
    'game_theme.mp3',
    'game_theme_2.mp3',
    'game_theme_3.mp3',
    'game_theme_4.mp3',
    'city_home_town.mp3',
    'city_timeless.mp3',
    'city_sunshine_coast.mp3',
    'city_bazaar.mp3',
  ];

  // The original themes were mastered at noticeably different loudness
  // levels. Keep transitions comfortable without re-encoding those assets.
  // The four city themes are normalized to approximately -18 LUFS already.
  static const Map<String, double> _playbackGains = {
    'game_theme.mp3': 0.58,
    'game_theme_2.mp3': 0.32,
    'game_theme_3.mp3': 0.41,
    'game_theme_4.mp3': 1.0,
    'city_home_town.mp3': 1.0,
    'city_timeless.mp3': 1.0,
    'city_sunshine_coast.mp3': 0.98,
    'city_bazaar.mp3': 0.99,
  };

  static const Map<String, List<String>> _countryPalettes = {
    'usa': [
      'game_theme.mp3',
      'city_sunshine_coast.mp3',
      'game_theme_3.mp3',
      'city_home_town.mp3',
      'game_theme_4.mp3',
      'city_timeless.mp3',
    ],
    'uk': [
      'city_home_town.mp3',
      'city_timeless.mp3',
      'game_theme_2.mp3',
      'game_theme_4.mp3',
      'game_theme.mp3',
      'city_bazaar.mp3',
    ],
    'france': [
      'city_timeless.mp3',
      'game_theme_3.mp3',
      'city_home_town.mp3',
      'game_theme.mp3',
      'city_sunshine_coast.mp3',
      'game_theme_4.mp3',
    ],
    'japan': [
      'game_theme_4.mp3',
      'city_timeless.mp3',
      'city_sunshine_coast.mp3',
      'game_theme_2.mp3',
      'city_bazaar.mp3',
      'game_theme_3.mp3',
    ],
    'china': [
      'city_bazaar.mp3',
      'city_timeless.mp3',
      'game_theme_2.mp3',
      'city_home_town.mp3',
      'game_theme_4.mp3',
      'game_theme_3.mp3',
    ],
    'mexico': [
      'city_sunshine_coast.mp3',
      'city_bazaar.mp3',
      'game_theme_3.mp3',
      'city_home_town.mp3',
      'game_theme_4.mp3',
      'game_theme.mp3',
    ],
  };

  static double playbackGainFor(String trackName) =>
      _playbackGains[trackName] ?? 1.0;

  static CityMusicProfile profileForBoard(String? boardId) {
    final normalized = boardId?.trim().toLowerCase() ?? '';
    final country = _countryForBoard(normalized);
    final palette = List<String>.from(_countryPalettes[country] ?? gameTracks);

    // Each city starts on a stable signature track, then shuffles within the
    // mood selected for its country. This keeps neighboring boards distinct
    // without relying on stereotypical instrumentation.
    if (normalized.isNotEmpty && normalized != country) {
      final offset = _stableHash(normalized) % palette.length;
      if (offset != 0) {
        final rotated = [...palette.skip(offset), ...palette.take(offset)];
        palette
          ..clear()
          ..addAll(rotated);
      }
    }

    return CityMusicProfile(id: country, tracks: List.unmodifiable(palette));
  }

  static String _countryForBoard(String boardId) {
    for (final country in _countryPalettes.keys) {
      if (boardId == country || boardId.startsWith('${country}_')) {
        return country;
      }
    }
    return 'global';
  }

  static int _stableHash(String value) {
    var hash = 17;
    for (final unit in value.codeUnits) {
      hash = 37 * hash + unit;
    }
    return hash.abs();
  }
}

class NoRepeatPlaylist {
  NoRepeatPlaylist({Random? random}) : _random = random ?? Random();

  final Random _random;
  List<String> _source = const [];
  List<String> _remaining = [];
  String? _lastTrack;

  bool get isEmpty => _source.isEmpty;
  String? get lastTrack => _lastTrack;

  void reset(Iterable<String> tracks, {String? lastTrack}) {
    _source = List<String>.unmodifiable(tracks.toSet());
    _lastTrack = lastTrack;
    _remaining = _createCycle(preferSignatureTrack: true);
  }

  String? next() {
    if (_source.isEmpty) return null;
    if (_remaining.isEmpty) {
      _remaining = _createCycle();
    }
    final track = _remaining.removeAt(0);
    _lastTrack = track;
    return track;
  }

  List<String> _createCycle({bool preferSignatureTrack = false}) {
    final cycle = List<String>.from(_source);
    if (cycle.length == 1) return cycle;

    if (preferSignatureTrack && cycle.first != _lastTrack) {
      final signature = cycle.removeAt(0);
      cycle.shuffle(_random);
      cycle.insert(0, signature);
      return cycle;
    }

    cycle.shuffle(_random);
    if (cycle.first == _lastTrack) {
      final replacement = cycle.indexWhere((track) => track != _lastTrack);
      final first = cycle.first;
      cycle[0] = cycle[replacement];
      cycle[replacement] = first;
    }
    return cycle;
  }
}

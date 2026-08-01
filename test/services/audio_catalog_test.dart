import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:property_tycoon/config/city_board_registry.dart';
import 'package:property_tycoon/services/audio_catalog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('every catalog track is bundled as a non-empty app asset', () async {
    for (final track in AudioCatalog.gameTracks) {
      final asset = await rootBundle.load('assets/audio/music/$track');
      expect(asset.lengthInBytes, greaterThan(1024), reason: track);
    }
  });

  test('every city receives a varied country-appropriate playlist', () {
    for (final board in CityBoardRegistry.all) {
      final profile = AudioCatalog.profileForBoard(board.boardId);
      expect(profile.tracks, hasLength(greaterThanOrEqualTo(6)));
      expect(profile.tracks.toSet(), hasLength(profile.tracks.length));
      expect(profile.tracks.every(AudioCatalog.gameTracks.contains), isTrue);
    }
  });

  test('every licensed game track is used by at least one country', () {
    final usedTracks = <String>{
      for (final boardId in ['usa', 'uk', 'france', 'japan', 'china', 'mexico'])
        ...AudioCatalog.profileForBoard(boardId).tracks,
    };

    expect(usedTracks, containsAll(AudioCatalog.gameTracks));
  });

  test('track playback gains stay in the supported player range', () {
    for (final track in AudioCatalog.gameTracks) {
      expect(AudioCatalog.playbackGainFor(track), inInclusiveRange(0.0, 1.0));
    }
  });

  test('country palettes start with different signature tracks', () {
    final signatures = {
      for (final boardId in ['usa', 'uk', 'france', 'japan', 'china', 'mexico'])
        AudioCatalog.profileForBoard(boardId).tracks.first,
    };

    expect(signatures, hasLength(greaterThanOrEqualTo(4)));
  });

  test('playlist never repeats a track at a cycle boundary', () {
    final playlist = NoRepeatPlaylist(random: Random(7))
      ..reset(AudioCatalog.gameTracks);
    String? previous;

    for (var index = 0; index < 100; index++) {
      final next = playlist.next();
      expect(next, isNot(previous));
      previous = next;
    }
  });

  test('playlist avoids the track that was already playing on reset', () {
    final playlist = NoRepeatPlaylist(
      random: Random(2),
    )..reset(AudioCatalog.gameTracks, lastTrack: AudioCatalog.gameTracks.first);

    expect(playlist.next(), isNot(AudioCatalog.gameTracks.first));
  });
}

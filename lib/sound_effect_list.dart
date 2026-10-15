import 'package:flutter/material.dart';

import 'sound_effect.dart';
import 'sound_effect_tile.dart';

class SoundEffectList extends StatelessWidget {
  const SoundEffectList({
    required this.sounds,
    required this.playingId,
    required this.favoriteIds,
    required this.downloadedIds,
    required this.soundTitles,
    required this.onPlay,
    required this.onFavorite,
    required this.onDownload,
    required this.onRename,
    required this.onOpenCredits,
    super.key,
  });

  final List<SoundEffect> sounds;
  final String? playingId;
  final Set<String> favoriteIds;
  final Set<String> downloadedIds;
  final Map<String, String> soundTitles;
  final ValueChanged<SoundEffect> onPlay;
  final ValueChanged<SoundEffect> onFavorite;
  final ValueChanged<SoundEffect> onDownload;
  final ValueChanged<SoundEffect> onRename;
  final ValueChanged<SoundEffect> onOpenCredits;

  @override
  Widget build(BuildContext context) {
    if (sounds.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 52, horizontal: 28),
        child: Column(
          children: [
            Icon(Icons.graphic_eq, size: 38, color: Color(0xFFE45C36)),
            SizedBox(height: 14),
            Text(
              'Nothing here yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 6),
            Text(
              'Browse the collection and add a sound to get started.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFFA3ABA5), height: 1.4),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        for (final sound in sounds)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SoundEffectTile(
              sound: sound,
              isPlaying: playingId == sound.id,
              isFavorite: favoriteIds.contains(sound.id),
              isDownloaded: downloadedIds.contains(sound.id),
              title: soundTitles[sound.id] ?? sound.title,
              onPlay: () => onPlay(sound),
              onFavorite: () => onFavorite(sound),
              onDownload: () => onDownload(sound),
              onRename: () => onRename(sound),
              onOpenCredits: () => onOpenCredits(sound),
            ),
          ),
      ],
    );
  }
}

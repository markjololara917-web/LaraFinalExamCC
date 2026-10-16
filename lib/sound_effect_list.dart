import 'package:flutter/material.dart';

import 'sound_effect.dart';
import 'sound_effect_tile.dart';

class SoundEffectList extends StatelessWidget {
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

  const SoundEffectList({
    super.key,
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
  });

  @override
  Widget build(BuildContext context) {
    if (sounds.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.music_off_rounded, color: Colors.white38, size: 42),
              SizedBox(height: 12),
              Text(
                'No sounds found.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: sounds.length,
      itemBuilder: (context, index) {
        final sound = sounds[index];

        return Padding(
          key: ValueKey(sound.id),
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
        );
      },
    );
  }
}

import 'package:flutter/material.dart';

import 'sound_effect.dart';
import 'sound_effect_list.dart';

class DownloadsPage extends StatelessWidget {
  const DownloadsPage({
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
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      children: [
        const Text(
          'Downloads',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          '${sounds.length} sounds saved in your library',
          style: const TextStyle(color: Color(0xFFA3ABA5)),
        ),
        const SizedBox(height: 22),
        SoundEffectList(
          sounds: sounds,
          playingId: playingId,
          favoriteIds: favoriteIds,
          downloadedIds: downloadedIds,
          soundTitles: soundTitles,
          onPlay: onPlay,
          onFavorite: onFavorite,
          onDownload: onDownload,
          onRename: onRename,
          onOpenCredits: onOpenCredits,
        ),
      ],
    );
  }
}

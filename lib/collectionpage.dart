import 'package:flutter/material.dart';

import 'sound_effect.dart';
import 'sound_effect_list.dart';

class CollectionPage extends StatelessWidget {
  const CollectionPage({
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
    final categories = sounds.map((sound) => sound.category).toSet().toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      children: [
        const Text(
          'Collections',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          '${sounds.length} field recordings and effects',
          style: const TextStyle(color: Color(0xFFA3ABA5)),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final category in categories)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF151816),
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: const Color(0xFF2D332F)),
                ),
                child: Text(
                  '$category  ${sounds.where((sound) => sound.category == category).length}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 24),
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

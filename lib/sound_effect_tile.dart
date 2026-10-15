import 'package:flutter/material.dart';

import 'sound_effect.dart';

class SoundEffectTile extends StatelessWidget {
  const SoundEffectTile({
    required this.sound,
    required this.isPlaying,
    required this.isFavorite,
    required this.isDownloaded,
    required this.title,
    required this.onPlay,
    required this.onFavorite,
    required this.onDownload,
    required this.onRename,
    required this.onOpenCredits,
    super.key,
  });

  final SoundEffect sound;
  final bool isPlaying;
  final bool isFavorite;
  final bool isDownloaded;
  final String title;
  final VoidCallback onPlay;
  final VoidCallback onFavorite;
  final VoidCallback onDownload;
  final VoidCallback onRename;
  final VoidCallback onOpenCredits;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFF151816),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2D332F)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: sound.color.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(sound.icon, color: sound.color, size: 23),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${sound.category}  ·  ${sound.duration}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFA3ABA5),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onPlay,
            tooltip: isPlaying ? 'Pause preview' : 'Play preview',
            visualDensity: VisualDensity.compact,
            icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow, size: 21),
          ),
          IconButton(
            onPressed: onFavorite,
            tooltip: isFavorite ? 'Remove favorite' : 'Add to favorites',
            visualDensity: VisualDensity.compact,
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              size: 19,
              color: isFavorite
                  ? const Color(0xFFE45C36)
                  : const Color(0xFFA3ABA5),
            ),
          ),
          IconButton(
            onPressed: isDownloaded ? null : onDownload,
            tooltip: isDownloaded ? 'Saved to device' : 'Save to device',
            visualDensity: VisualDensity.compact,
            icon: Icon(
              isDownloaded ? Icons.download_done : Icons.download_outlined,
              size: 19,
              color: isDownloaded
                  ? const Color(0xFF4F7E66)
                  : const Color(0xFFA3ABA5),
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'Sound actions',
            onSelected: (action) {
              if (action == 'rename') onRename();
              if (action == 'credits') onOpenCredits();
            },
            itemBuilder: (context) => [
              if (sound.creditUrl != null)
                const PopupMenuItem(value: 'credits', child: Text('Credits')),
              const PopupMenuItem(value: 'rename', child: Text('Rename')),
            ],
            icon: const Icon(Icons.more_vert, size: 19),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
          ),
        ],
      ),
    );
  }
}

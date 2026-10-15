import 'package:flutter/material.dart';

import 'sound_effect.dart';
import 'sound_effect_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({
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
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  bool? _showBackgroundMusic;

  static const _soundEffectCategories = [
    'All',
    'Nature',
    'Human',
    'Objects',
    'Vehicles',
    'UI',
  ];
  static const _musicCategories = [
    'All',
    'Cinematic',
    'Ambient',
    'Focus',
    'Anime',
  ];
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.toLowerCase();
    final categories = _showBackgroundMusic == null
        ? const <String>[]
        : _showBackgroundMusic!
        ? _musicCategories
        : _soundEffectCategories;
    final filteredSounds = widget.sounds.where((sound) {
      final matchesMode =
          _showBackgroundMusic != null &&
          sound.isBackgroundMusic == _showBackgroundMusic;
      final matchesCategory =
          _selectedCategory == 'All' || sound.category == _selectedCategory;
      final matchesQuery =
          (widget.soundTitles[sound.id] ?? sound.title).toLowerCase().contains(
            query,
          ) ||
          sound.category.toLowerCase().contains(query);
      return matchesMode && matchesCategory && matchesQuery;
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        Row(
          children: [
            const Icon(Icons.graphic_eq, color: Color(0xFFB9D57D), size: 27),
            const SizedBox(width: 8),
            const Text(
              'SOUNDEFFECT',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
              ),
            ),
            const Spacer(),
          ],
        ),
        const SizedBox(height: 22),
        const Text(
          'Hear the world\naround you.',
          style: TextStyle(
            fontSize: 30,
            height: 1.08,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _modeButton(
              label: 'Sound Effects',
              icon: Icons.graphic_eq,
              isSelected: _showBackgroundMusic == false,
              onPressed: () => setState(() {
                _showBackgroundMusic = false;
                _selectedCategory = 'All';
                _searchController.clear();
              }),
            ),
            _modeButton(
              label: 'Background Music',
              icon: Icons.music_note,
              isSelected: _showBackgroundMusic == true,
              onPressed: () => setState(() {
                _showBackgroundMusic = true;
                _selectedCategory = 'All';
                _searchController.clear();
              }),
            ),
          ],
        ),
        if (_showBackgroundMusic != null) ...[
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              PopupMenuButton<String>(
                tooltip: 'Choose category',
                onSelected: (category) =>
                    setState(() => _selectedCategory = category),
                itemBuilder: (context) => [
                  for (final category in categories)
                    PopupMenuItem(value: category, child: Text(category)),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF151816),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF343A35)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.tune, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        _selectedCategory == 'All'
                            ? 'Choose Category'
                            : _selectedCategory,
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.expand_more, size: 16),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 230,
                height: 36,
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(
                    color: Color(0xFFF1F3EF),
                    fontSize: 12,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search',
                    hintStyle: const TextStyle(
                      color: Color(0xFFA3ABA5),
                      fontSize: 12,
                    ),
                    prefixIcon: const Icon(Icons.search, size: 18),
                    filled: true,
                    fillColor: const Color(0xFF151816),
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF343A35)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF343A35)),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SoundEffectList(
            sounds: filteredSounds,
            playingId: widget.playingId,
            favoriteIds: widget.favoriteIds,
            downloadedIds: widget.downloadedIds,
            soundTitles: widget.soundTitles,
            onPlay: widget.onPlay,
            onFavorite: widget.onFavorite,
            onDownload: widget.onDownload,
            onRename: widget.onRename,
            onOpenCredits: widget.onOpenCredits,
          ),
        ],
      ],
    );
  }

  Widget _modeButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFFF1F3EF),
        backgroundColor: isSelected
            ? const Color(0xFF35402B)
            : const Color(0xFF151816),
        side: BorderSide(
          color: isSelected ? const Color(0xFF718A57) : const Color(0xFF343A35),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
        minimumSize: const Size(0, 36),
        visualDensity: VisualDensity.compact,
        textStyle: const TextStyle(fontSize: 12),
      ),
    );
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'collectionpage.dart';
import 'downloadpage.dart';
import 'favoritepage.dart';
import 'homepage.dart';
import 'notifpage.dart';
import 'sound_effect.dart';
import 'tiktok_credit_dialog.dart';

class SoundEffectApp extends StatefulWidget {
  const SoundEffectApp({super.key});

  @override
  State<SoundEffectApp> createState() => _SoundEffectAppState();
}

class _SoundEffectAppState extends State<SoundEffectApp> {
  static const _customTitlesKey = 'soundeffect.custom_titles';

  int _selectedIndex = 2;
  String? _playingId;
  String? _pausedId;
  AudioPlayer? _audioPlayer;
  StreamSubscription<void>? _completionSubscription;
  final Set<String> _favoriteIds = {};
  final Set<String> _downloadedIds = {};
  final Map<String, String> _customTitles = {};
  late final Future<SharedPreferences> _preferences;

  @override
  void initState() {
    super.initState();
    _preferences = SharedPreferences.getInstance();
    unawaited(_loadCustomTitles());
  }

  Future<void> _loadCustomTitles() async {
    try {
      final encodedTitles = (await _preferences).getString(_customTitlesKey);
      if (encodedTitles == null) return;
      final decodedTitles = jsonDecode(encodedTitles);
      if (decodedTitles is! Map<String, dynamic>) return;

      final titles = <String, String>{
        for (final entry in decodedTitles.entries)
          if (entry.value is String &&
              (entry.value as String).trim().isNotEmpty)
            entry.key: (entry.value as String).trim(),
      };
      if (!mounted) return;
      setState(() {
        _customTitles
          ..clear()
          ..addAll(titles);
      });
    } catch (_) {
      // Ignore invalid or unavailable saved preferences and use default names.
    }
  }

  String _titleFor(SoundEffect sound) => _customTitles[sound.id] ?? sound.title;

  Future<void> _renameSound(SoundEffect sound) async {
    try {
      final enteredTitle = await showDialog<String>(
        context: context,
        builder: (_) => _RenameSoundDialog(initialTitle: _titleFor(sound)),
      );

      final title = enteredTitle?.trim();
      if (title == null) return;
      if (title.isEmpty) {
        _showMessage('Sound name cannot be empty.');
        return;
      }

      final updatedTitles = {..._customTitles, sound.id: title};
      final preferences = await _preferences;
      await preferences.setString(_customTitlesKey, jsonEncode(updatedTitles));
      if (!mounted) return;
      setState(() {
        _customTitles
          ..clear()
          ..addAll(updatedTitles);
      });
      _showMessage('Sound name saved.');
    } catch (_) {
      if (mounted) _showMessage('Could not save the sound name.');
    }
  }

  Future<void> _togglePlayback(SoundEffect sound) async {
    final player = _audioPlayer ??= AudioPlayer();
    _completionSubscription ??= player.onPlayerComplete.listen((_) {
      if (!mounted) return;
      setState(() {
        _playingId = null;
        _pausedId = null;
      });
    });

    try {
      if (_playingId == sound.id) {
        await player.pause();
        if (!mounted) return;
        setState(() {
          _playingId = null;
          _pausedId = sound.id;
        });
        return;
      }

      if (_pausedId == sound.id) {
        await player.resume();
        if (!mounted) return;
        setState(() {
          _playingId = sound.id;
          _pausedId = null;
        });
        return;
      }

      await player.stop();
      await player.play(AssetSource(_assetSourcePath(sound.assetPath)));
      if (!mounted) return;
      setState(() {
        _playingId = sound.id;
        _pausedId = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _playingId = null;
        _pausedId = null;
      });
      _showMessage('Could not play ${_titleFor(sound)}. Check its MP3 file.');
    }
  }

  String _assetSourcePath(String path) =>
      path.startsWith('assets/') ? path.substring('assets/'.length) : path;

  void _toggleFavorite(SoundEffect sound) {
    setState(() {
      if (!_favoriteIds.add(sound.id)) _favoriteIds.remove(sound.id);
    });
  }

  Future<void> _toggleDownload(SoundEffect sound) async {
    if (_downloadedIds.contains(sound.id)) {
      _showMessage('${_titleFor(sound)} is already saved on this device.');
      return;
    }

    try {
      final audioData = await rootBundle.load(sound.assetPath);
      final bytes = audioData.buffer.asUint8List(
        audioData.offsetInBytes,
        audioData.lengthInBytes,
      );
      final fileSaver = FileSaver.instance;
      final savedLocation =
          !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS
          ? await fileSaver.saveAs(
              name: sound.id,
              bytes: bytes,
              fileExtension: 'mp3',
              mimeType: MimeType.mp3,
              dialogTitle: 'Save ${_titleFor(sound)}',
            )
          : await fileSaver.saveToDownloads(
              name: sound.id,
              bytes: bytes,
              fileExtension: 'mp3',
              mimeType: MimeType.mp3,
              subfolder: 'SoundEffect',
            );

      if (!mounted || savedLocation == null) return;
      setState(() => _downloadedIds.add(sound.id));
      _showMessage('${_titleFor(sound)} saved to this device.');
    } on FlutterError {
      if (!mounted) return;
      _showMessage('Audio file not added yet: ${sound.assetPath}');
    } catch (_) {
      if (!mounted) return;
      _showMessage('Could not save ${_titleFor(sound)} to this device.');
    }
  }

  Future<void> _openCredits(SoundEffect sound) async {
    final creditUrl = sound.creditUrl;
    if (creditUrl == null) return;

    await showDialog<void>(
      context: context,
      builder: (_) => TikTokCreditDialog(sound: sound),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    unawaited(_completionSubscription?.cancel());
    unawaited(_audioPlayer?.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      DownloadsPage(
        sounds: soundEffects
            .where((sound) => _downloadedIds.contains(sound.id))
            .toList(),
        playingId: _playingId,
        favoriteIds: _favoriteIds,
        downloadedIds: _downloadedIds,
        soundTitles: _customTitles,
        onPlay: _togglePlayback,
        onFavorite: _toggleFavorite,
        onDownload: _toggleDownload,
        onRename: _renameSound,
        onOpenCredits: _openCredits,
      ),
      const NotificationsPage(),
      HomePage(
        sounds: soundEffects,
        playingId: _playingId,
        favoriteIds: _favoriteIds,
        downloadedIds: _downloadedIds,
        soundTitles: _customTitles,
        onPlay: _togglePlayback,
        onFavorite: _toggleFavorite,
        onDownload: _toggleDownload,
        onRename: _renameSound,
        onOpenCredits: _openCredits,
      ),
      FavoritePage(
        sounds: soundEffects
            .where((sound) => _favoriteIds.contains(sound.id))
            .toList(),
        playingId: _playingId,
        favoriteIds: _favoriteIds,
        downloadedIds: _downloadedIds,
        soundTitles: _customTitles,
        onPlay: _togglePlayback,
        onFavorite: _toggleFavorite,
        onDownload: _toggleDownload,
        onRename: _renameSound,
        onOpenCredits: _openCredits,
      ),
      CollectionPage(
        sounds: soundEffects,
        playingId: _playingId,
        favoriteIds: _favoriteIds,
        downloadedIds: _downloadedIds,
        soundTitles: _customTitles,
        onPlay: _togglePlayback,
        onFavorite: _toggleFavorite,
        onDownload: _toggleDownload,
        onRename: _renameSound,
        onOpenCredits: _openCredits,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(index: _selectedIndex, children: pages),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.download_outlined),
            selectedIcon: Icon(Icons.download),
            label: 'Download',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_none),
            selectedIcon: Icon(Icons.notifications),
            label: 'Notification',
          ),
          NavigationDestination(
            icon: Icon(Icons.graphic_eq),
            selectedIcon: Icon(Icons.graphic_eq),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favorite',
          ),
          NavigationDestination(
            icon: Icon(Icons.library_music_outlined),
            selectedIcon: Icon(Icons.library_music),
            label: 'Collection',
          ),
        ],
      ),
    );
  }
}

class _RenameSoundDialog extends StatefulWidget {
  const _RenameSoundDialog({required this.initialTitle});

  final String initialTitle;

  @override
  State<_RenameSoundDialog> createState() => _RenameSoundDialogState();
}

class _RenameSoundDialogState extends State<_RenameSoundDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialTitle);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rename sound'),
      content: TextField(
        key: const Key('sound-rename-field'),
        controller: _controller,
        autofocus: true,
        maxLength: 60,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(labelText: 'Sound name'),
        onSubmitted: (value) => Navigator.of(context).pop(value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

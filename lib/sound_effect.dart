import 'package:flutter/material.dart';

class SoundEffect {
  const SoundEffect({
    required this.id,
    required this.title,
    required this.category,
    required this.duration,
    required this.icon,
    required this.color,
    required this.assetPath,
    this.creditUrl,
    this.isBackgroundMusic = false,
  });

  final String id;
  final String title;
  final String category;
  final String duration;
  final IconData icon;
  final Color color;
  final String assetPath;
  final String? creditUrl;
  final bool isBackgroundMusic;
}

const _natureSounds = [
  'Rain',
  'Ocean Waves',
  'Birds Chirping',
  'Forest Ambience',
  'Wind Blowing',
  'Thunderstorm',
  'Crickets at Night',
  'Water Stream',
  'Frogs Croaking',
  'Fire Crackling',
];

const _humanSounds = [
  'Footsteps',
  'Human Talking',
  'Human Laughing',
  'Screaming',
  'Clapping',
  'Breathing',
  'Crying',
  'Coughing',
  'Punch Impact',
  'Crowd Cheering',
];

const _objectSounds = [
  'Door Opening/Closing',
  'Bell Ringing',
  'Phone Notification',
  'Keys Jingle',
  'Glass Breaking',
  'Object Dropping',
  'Metal Clanging',
  'Scissors Cutting',
  'Keyboard Typing',
  'Coin Dropping',
];

const _vehicleSounds = [
  'Car Engine Starting',
  'Car Racing',
  'Motorcycle Engine',
  'Truck Engine',
  'Bus Passing By',
  'Ambulance Siren',
  'Police Siren',
  'Airplane Flying',
  'Helicopter Blades',
  'Boat Engine',
];

const _uiSounds = [
  'Button Click',
  'Button Tap',
  'Notification Pop',
  'Success Sound',
  'Error Sound',
  'Dice Rolling',
  'Level Complete',
  'Unlock Sound',
  'Whoosh Transition',
  'Coin / Reward Pickup',
  'Toggle Switch',
  'Popup Open',
  'Popup Close',
  'Hover Sound',
  'Swipe Sound',
  'Loading Sound',
  'Warning Alert',
  'Typing Sound',
  'Drag and Drop',
  'Game Over',
];

const _cinematicMusic = [
  'Epic Cinematic Rise',
  'Dark Hero Theme',
  'Emotional Piano',
  'Epic Orchestral Battle',
  'Dramatic Suspense',
];

const _ambientMusic = [
  'Peaceful Nature',
  'Dreamy Atmosphere',
  'Deep Space Ambient',
  'Rainy Night',
  'Mystical Forest',
];

const _focusMusic = [
  'Deep Focus',
  'Minimal Piano',
  'Lo-Fi Study',
  'Calm Productivity',
  'Soft Synth Focus',
];

const _animeMusic = [
  'AOT - Vogel im Käfig',
  'AOT- ətˈæk 0N tάɪtn',
  'AOT-Lose it all',
  'AOT-YouSeeBIGGIRL  TT',
  'Music 5',
];

final soundEffects = [
  ..._makeSounds(
    'Nature',
    _natureSounds,
    creditUrls: const {
      'Rain': 'https://www.tiktok.com/@halerelaxation/video/7379631594010725648?is_from_webapp=1&sender_device=pc&web_id=7657802544844162568',
      'Ocean Waves': 'https://www.tiktok.com/@peaceasmrsounds/video/7028076248937024773?is_from_webapp=1&sender_device=pc&web_id=7657802544844162568',
    },
  ),
  ..._makeSounds('Human', _humanSounds),
  ..._makeSounds('Objects', _objectSounds),
  ..._makeSounds('Vehicles', _vehicleSounds),
  ..._makeSounds('UI', _uiSounds),
  ..._makeSounds('Cinematic', _cinematicMusic, isBackgroundMusic: true),
  ..._makeSounds('Ambient', _ambientMusic, isBackgroundMusic: true),
  ..._makeSounds('Focus', _focusMusic, isBackgroundMusic: true),
  ..._makeSounds(
    'Anime',
    _animeMusic,
    isBackgroundMusic: true,
    assetFileNames: const {
      'AOT - Vogel im Käfig': 'AOT - Vogel im Käfig.mp3',
      'AOT- ətˈæk 0N tάɪtn': 'AOT- ətˈæk 0N tάɪtn.mp3',
      'AOT-Lose it all': 'AOT-Lose it all.mp3',
      'AOT-YouSeeBIGGIRL  TT': 'AOT-YouSeeBIGGIRL  TT.mp3',
    },
    creditUrls: const {
      'AOT - Vogel im Käfig': 'https://www.tiktok.com/@razorsinmyreeses/video/7618769423029030158?is_from_webapp=1&sender_device=pc&web_id=7657802544844162568',
      'AOT- ətˈæk 0N tάɪtn': 'https://www.tiktok.com/@hiroyukisawano.official/video/7363396205281283344?is_from_webapp=1&sender_device=pc&web_id=7657802544844162568',
      'AOT-Lose it all': 'https://www.tiktok.com/@rogie_07ae/video/7606333218899496209?is_from_webapp=1&sender_device=pc&web_id=7657802544844162568',
      'AOT-YouSeeBIGGIRL  TT': 'https://www.tiktok.com/@daylyanime/video/7299322883027832094?is_from_webapp=1&sender_device=pc&web_id=7657802544844162568',
    },
  ),
];

List<SoundEffect> _makeSounds(
  String category,
  List<String> titles, {
  bool isBackgroundMusic = false,
  Map<String, String> assetFileNames = const {},
  Map<String, String> creditUrls = const {},
}) {
  return [
    for (final title in titles)
      _makeSound(
        title,
        category,
        isBackgroundMusic: isBackgroundMusic,
        assetFileName: assetFileNames[title],
        creditUrl: creditUrls[title],
      ),
  ];
}

SoundEffect _makeSound(
  String title,
  String category, {
  bool isBackgroundMusic = false,
  String? assetFileName,
  String? creditUrl,
}) {
  final id = _toSlug(title);
  final folder = isBackgroundMusic
      ? 'music/${_toSlug(category)}'
      : _toSlug(category);
  final (icon, color) = switch (category) {
    'Nature' => (Icons.nature_people_outlined, const Color(0xFF4F9D91)),
    'Human' => (Icons.person_outline, const Color(0xFFB78A4E)),
    'Objects' => (Icons.widgets_outlined, const Color(0xFFCB6C52)),
    'Vehicles' => (Icons.directions_car_outlined, const Color(0xFF697D4D)),
    'UI' => (Icons.touch_app_outlined, const Color(0xFF718F9B)),
    _ => (Icons.music_note, const Color(0xFFCE8972)),
  };

  return SoundEffect(
    id: id,
    title: title,
    category: category,
    duration: '--:--',
    icon: icon,
    color: color,
    assetPath: 'assets/audio/$folder/${assetFileName ?? '$id.mp3'}',
    creditUrl: creditUrl,
    isBackgroundMusic: isBackgroundMusic,
  );
}

String _toSlug(String value) => value
    .toLowerCase()
    .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
    .replaceAll(RegExp(r'^-|-$'), '');

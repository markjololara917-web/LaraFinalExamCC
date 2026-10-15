// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/link.dart';

import 'package:soundeffect/main.dart';
import 'package:soundeffect/sound_effect.dart';
import 'package:soundeffect/tiktok_credit_dialog.dart';

void main() {
  test('TikTok oEmbed request parses source metadata', () async {
    const videoUrl = 'https://www.tiktok.com/@creator/video/123';
    final client = MockClient((request) async {
      expect(request.url.path, '/oembed');
      expect(request.url.queryParameters['url'], videoUrl);
      return http.Response(
        jsonEncode({
          'title': 'Rain sounds',
          'author_name': 'Creator',
          'author_url': 'https://www.tiktok.com/@creator',
          'thumbnail_url': 'https://example.com/thumbnail.jpg',
        }),
        200,
        headers: const {'content-type': 'application/json'},
      );
    });

    final info = await fetchTikTokCreditInfo(videoUrl, client: client);
    client.close();

    expect(info.title, 'Rain sounds');
    expect(info.authorName, 'Creator');
    expect(info.authorUrl, 'https://www.tiktok.com/@creator');
    expect(info.thumbnailUrl, 'https://example.com/thumbnail.jpg');
  });

  testWidgets('credits popup shows API data and opens the source', (
    WidgetTester tester,
  ) async {
    final sound = soundEffects.singleWhere((sound) => sound.id == 'rain');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TikTokCreditDialog(
            sound: sound,
            fetchInfo: (url) async => const TikTokCreditInfo(
              title: 'Rain video title',
              authorName: 'Rain creator',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Rain video title'), findsOneWidget);
    expect(find.text('Creator: Rain creator'), findsOneWidget);
    expect(find.text('Open TikTok'), findsOneWidget);
    expect(tester.widget<Link>(find.byType(Link)).target, LinkTarget.blank);
  });

  testWidgets('sound library opens and bottom navigation switches pages', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    expect(soundEffects.where((sound) => !sound.isBackgroundMusic).length, 60);
    expect(soundEffects.where((sound) => sound.isBackgroundMusic).length, 20);
    expect(
      soundEffects.firstWhere((sound) => sound.id == 'rain').assetPath,
      'assets/audio/nature/rain.mp3',
    );
    expect(
      soundEffects
          .singleWhere((sound) => sound.title == 'AOT - Vogel im Käfig')
          .assetPath,
      'assets/audio/music/anime/AOT - Vogel im Käfig.mp3',
    );
    expect(
      soundEffects
          .singleWhere((sound) => sound.title == 'AOT- ətˈæk 0N tάɪtn')
          .assetPath,
      'assets/audio/music/anime/AOT- ətˈæk 0N tάɪtn.mp3',
    );
    expect(
      soundEffects
          .singleWhere((sound) => sound.title == 'AOT-Lose it all')
          .assetPath,
      'assets/audio/music/anime/AOT-Lose it all.mp3',
    );
    expect(
      soundEffects
          .singleWhere((sound) => sound.title == 'AOT-YouSeeBIGGIRL  TT')
          .assetPath,
      'assets/audio/music/anime/AOT-YouSeeBIGGIRL  TT.mp3',
    );
    void expectCredit(String title, String url) {
      expect(
        soundEffects.singleWhere((sound) => sound.title == title).creditUrl,
        url,
      );
    }

    expectCredit(
      'AOT-YouSeeBIGGIRL  TT',
      'https://www.tiktok.com/@daylyanime/video/7299322883027832094?is_from_webapp=1&sender_device=pc&web_id=7657802544844162568',
    );
    expectCredit(
      'AOT- ətˈæk 0N tάɪtn',
      'https://www.tiktok.com/@hiroyukisawano.official/video/7363396205281283344?is_from_webapp=1&sender_device=pc&web_id=7657802544844162568',
    );
    expectCredit(
      'Rain',
      'https://www.tiktok.com/@halerelaxation/video/7379631594010725648?is_from_webapp=1&sender_device=pc&web_id=7657802544844162568',
    );
    expectCredit(
      'Ocean Waves',
      'https://www.tiktok.com/@peaceasmrsounds/video/7028076248937024773?is_from_webapp=1&sender_device=pc&web_id=7657802544844162568',
    );
    expectCredit(
      'AOT-Lose it all',
      'https://www.tiktok.com/@rogie_07ae/video/7606333218899496209?is_from_webapp=1&sender_device=pc&web_id=7657802544844162568',
    );
    expectCredit(
      'AOT - Vogel im Käfig',
      'https://www.tiktok.com/@razorsinmyreeses/video/7618769423029030158?is_from_webapp=1&sender_device=pc&web_id=7657802544844162568',
    );
    for (final track in soundEffects.where(
      (sound) => sound.category == 'Anime' && sound.title != 'Music 5',
    )) {
      final audio = await rootBundle.load(track.assetPath);
      expect(audio.lengthInBytes, greaterThan(0), reason: track.title);
    }

    await tester.pumpWidget(const MyApp());

    expect(
      Theme.of(tester.element(find.byType(Scaffold).first)).brightness,
      Brightness.dark,
    );
    expect(find.text('Hear the world\naround you.'), findsOneWidget);
    expect(find.text('Sound Effects'), findsOneWidget);
    expect(find.text('Background Music'), findsOneWidget);
    expect(find.text('Sound library'), findsNothing);
    expect(find.text('Choose Category'), findsNothing);
    expect(find.text('Rain on a Window'), findsNothing);
    expect(find.text('Sound of the Day'), findsNothing);

    await tester.tap(find.text('Sound Effects'));
    await tester.pumpAndSettle();
    expect(find.text('Rain'), findsOneWidget);
    expect(find.text('Choose Category'), findsOneWidget);

    await tester.tap(find.text('Choose Category'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nature').last);
    await tester.pumpAndSettle();
    expect(find.text('Rain'), findsOneWidget);
    expect(find.text('Footsteps'), findsNothing);

    await tester.tap(find.byTooltip('Sound actions').first);
    await tester.pumpAndSettle();
    expect(find.text('Credits'), findsOneWidget);
    await tester.tap(find.text('Rename'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('sound-rename-field')),
      'Rain Remix',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Rain Remix'), findsOneWidget);

    await tester.tap(find.text('Background Music'));
    await tester.pumpAndSettle();
    expect(find.text('Epic Cinematic Rise'), findsOneWidget);
    expect(find.text('AOT - Vogel im Käfig'), findsOneWidget);

    await tester.tap(find.text('Choose Category'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Anime').last);
    await tester.pumpAndSettle();
    expect(find.text('AOT - Vogel im Käfig'), findsOneWidget);
    expect(find.text('Epic Cinematic Rise'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sound Effects'));
    await tester.pumpAndSettle();
    expect(find.text('Rain Remix'), findsOneWidget);

    await tester.tap(find.text('Collection'));
    await tester.pumpAndSettle();
    expect(find.text('Collections'), findsOneWidget);
    expect(find.text('Rain Remix'), findsOneWidget);

    await tester.tap(find.text('Favorite'));
    await tester.pumpAndSettle();
    expect(find.text('Favorites'), findsOneWidget);
  });
}

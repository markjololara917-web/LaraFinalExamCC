import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/link.dart';

import 'sound_effect.dart';

class TikTokCreditInfo {
  final String? title;
  final String? authorName;
  final String? authorUrl;
  final String? thumbnailUrl;
  final Map<String, dynamic> rawData;

  const TikTokCreditInfo({
    this.title,
    this.authorName,
    this.authorUrl,
    this.thumbnailUrl,
    this.rawData = const {},
  });

  factory TikTokCreditInfo.fromJson(Map<String, dynamic> json) {
    return TikTokCreditInfo(
      title: json['title']?.toString(),
      authorName: json['author_name']?.toString(),
      authorUrl: json['author_url']?.toString(),
      thumbnailUrl: json['thumbnail_url']?.toString(),
      rawData: Map<String, dynamic>.from(json),
    );
  }
}

Future<TikTokCreditInfo> fetchTikTokCreditInfo(
  String videoUrl, {
  http.Client? client,
}) async {
  final httpClient = client ?? http.Client();

  // Local development: http://localhost:3000
  // For APK/release, build with:
  // --dart-define=TIKTOK_API_BASE_URL=https://YOUR-DEPLOYED-BACKEND
  // Do not put the TikTok oEmbed URL here; the Node.js backend calls TikTok.
  const apiBaseUrl = String.fromEnvironment(
    'TIKTOK_API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  final baseUri = Uri.parse(apiBaseUrl);
  final uri = baseUri.replace(
    path: '/api/tiktok-oembed',
    queryParameters: {'url': videoUrl},
  );

  try {
    final response = await httpClient
        .get(uri, headers: const {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(
        'TikTok API error: HTTP ${response.statusCode}\n'
        '${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid JSON response from TikTok.');
    }

    return TikTokCreditInfo.fromJson(decoded);
  } finally {
    if (client == null) {
      httpClient.close();
    }
  }
}

class TikTokCreditDialog extends StatefulWidget {
  final SoundEffect sound;
  final Future<TikTokCreditInfo> Function(String url)? fetchInfo;

  const TikTokCreditDialog({super.key, required this.sound, this.fetchInfo});

  @override
  State<TikTokCreditDialog> createState() => _TikTokCreditDialogState();
}

class _TikTokCreditDialogState extends State<TikTokCreditDialog> {
  late Future<TikTokCreditInfo> _infoFuture;
  bool _showJson = true;

  @override
  void initState() {
    super.initState();
    _loadInfo();
  }

  void _loadInfo() {
    final url = widget.sound.creditUrl;

    if (url == null || url.trim().isEmpty) {
      _infoFuture = Future.error(
        Exception('Walang TikTok source URL para sa sound na ito.'),
      );
      return;
    }

    _infoFuture = (widget.fetchInfo ?? fetchTikTokCreditInfo)(url);
  }

  String get _sourceUrl => widget.sound.creditUrl ?? '';

  Future<void> _openUrl(String url) async {
    if (url.isEmpty) return;

    // Link widget below handles opening links.
  }

  Widget _detail(String label, String? value, {bool selectable = true}) {
    final text = value?.trim().isNotEmpty == true
        ? value!
        : 'Not provided by API';

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 5),
          SelectableText(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _linkDetail(String label, String? url) {
    final validUrl = url?.trim() ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 5),
          if (validUrl.isEmpty)
            const Text(
              'Not provided by API',
              style: TextStyle(color: Colors.white),
            )
          else
            Link(
              uri: Uri.tryParse(validUrl),
              target: LinkTarget.blank,
              builder: (context, followLink) {
                return InkWell(
                  onTap: followLink,
                  child: Text(
                    validUrl,
                    style: const TextStyle(
                      color: Colors.cyanAccent,
                      decoration: TextDecoration.underline,
                      fontSize: 13,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF15171D),
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFF30343D)),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 12, 14),
              child: Row(
                children: [
                  const Icon(Icons.api, color: Colors.cyanAccent, size: 26),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TikTok API Details',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Video metadata and raw response',
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFF30343D)),
            Flexible(
              child: FutureBuilder<TikTokCreditInfo>(
                future: _infoFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(36),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: Colors.cyanAccent),
                            SizedBox(height: 16),
                            Text(
                              'Fetching TikTok API...',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (snapshot.hasError || !snapshot.hasData) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.orangeAccent,
                            size: 36,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Unable to fetch API details',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SelectableText(
                            '${snapshot.error}',
                            style: const TextStyle(
                              color: Colors.orangeAccent,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _detail('Sound', widget.sound.title),
                          _linkDetail('Source video', _sourceUrl),
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(_loadInfo);
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry API request'),
                          ),
                        ],
                      ),
                    );
                  }

                  final info = snapshot.data!;
                  final rawJson = const JsonEncoder.withIndent('  ')
                      .convert(info.rawData);

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (info.thumbnailUrl != null &&
                            info.thumbnailUrl!.isNotEmpty) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              info.thumbnailUrl!,
                              width: double.infinity,
                              height: 170,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 100,
                                  color: const Color(0xFF252832),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    'Thumbnail unavailable',
                                    style: TextStyle(color: Colors.white54),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                        _detail('Sound name', widget.sound.title),
                        _detail('Video title', info.title),
                        _detail('Creator', info.authorName),
                        _linkDetail('Author URL', info.authorUrl),
                        _linkDetail('Thumbnail URL', info.thumbnailUrl),
                        _linkDetail('Source video URL', _sourceUrl),
                        const Divider(color: Color(0xFF30343D), height: 28),
                        InkWell(
                          onTap: () {
                            setState(() {
                              _showJson = !_showJson;
                            });
                          },
                          child: Row(
                            children: [
                              const Icon(
                                Icons.data_object,
                                color: Colors.cyanAccent,
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Raw API JSON Response',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Icon(
                                _showJson
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                                color: Colors.white70,
                              ),
                            ],
                          ),
                        ),
                        if (_showJson) ...[
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0B0D11),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF30343D),
                              ),
                            ),
                            child: SelectableText(
                              rawJson,
                              style: const TextStyle(
                                color: Colors.greenAccent,
                                fontSize: 12,
                                fontFamily: 'monospace',
                                height: 1.6,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              setState(_loadInfo);
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Refresh API Data'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.cyanAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

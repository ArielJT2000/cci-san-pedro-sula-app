import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../utils/constants.dart';

/// Reproductor de YouTube usando solo el widget del paquete [youtube_player_iframe].
/// En móvil el paquete usa WebView internamente para el iframe; aquí solo se usa la API del player.
class YoutubePlayerBase extends StatefulWidget {
  final String videoId;
  final String title;
  final bool autoPlay;

  const YoutubePlayerBase({
    super.key,
    required this.videoId,
    required this.title,
    this.autoPlay = false,
  });

  @override
  State<YoutubePlayerBase> createState() => _YoutubePlayerBaseState();
}

class _YoutubePlayerBaseState extends State<YoutubePlayerBase> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.videoId,
      autoPlay: widget.autoPlay,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        mute: false,
        loop: false,
        strictRelatedVideos: true,
        origin: 'https://www.youtube-nocookie.com',
      ),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  Future<void> _openInYouTube() async {
    final uri = Uri.parse(
      'https://www.youtube.com/watch?v=${widget.videoId}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  bool _isEmbedRestriction(YoutubeError error) {
    return error == YoutubeError.notEmbeddable ||
        error == YoutubeError.sameAsNotEmbeddable;
  }

  Widget _buildUnavailableCard() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          color: colorWithOpacity(negro, 0.95),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colorWithOpacity(negro, 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_circle_outline, size: 48, color: blanco),
              const SizedBox(height: 12),
              Text(
                'Este video no se puede reproducir aquí',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Ábrelo en YouTube para verlo.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _openInYouTube,
                style: FilledButton.styleFrom(
                  backgroundColor: grisOscuro,
                  foregroundColor: blanco,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.open_in_new, size: 20, color: blanco),
                    const SizedBox(width: 10),
                    const Text('Abrir en YouTube'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: colorWithOpacity(negro, 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: colorWithOpacity(accent, 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 2),
                    spreadRadius: -4,
                  ),
                ],
              ),
              child: StreamBuilder<YoutubePlayerValue>(
                stream: _controller.stream,
                initialData: _controller.value,
                builder: (context, snapshot) {
                  final value = snapshot.data;
                  final showUnavailable = value != null &&
                      value.hasError &&
                      _isEmbedRestriction(value.error);
                  if (showUnavailable) {
                    return _buildUnavailableCard();
                  }
                  return YoutubePlayer(
                    controller: _controller,
                    aspectRatio: 16 / 9,
                    backgroundColor: negro,
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 6),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _openInYouTube,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.open_in_new, size: 18, color: blanco),
                    const SizedBox(width: 6),
                    Text(
                      'Abrir en YouTube',
                      style: TextStyle(
                        color: blanco,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

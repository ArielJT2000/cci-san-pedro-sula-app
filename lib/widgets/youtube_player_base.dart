import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../utils/app_config.dart';
import '../utils/constants.dart';

/// Reproductor YouTube endurecido para iOS/Android WebView.
///
/// - Usa origen HTTPS propio (Referer válido; evita fallos 150/153 frecuentes).
/// - Reintenta una vez si el embed falla al arrancar (lives que aún no están listos).
/// - Si YouTube falla o no arranca a tiempo, muestra CTA para abrir en la app de YouTube.
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
  /// Dominio real de la iglesia: YouTube exige un Referer/origen HTTPS identificable.
  static const String _embedOrigin = 'https://${AppConfig.shareLinkHost}';

  /// Si el live no pasa a buffering/playing, asumimos fallo de embed (p. ej. error 153
  /// que a veces solo se ve en la UI de YouTube y no llega bien por la IFrame API).
  static const Duration _startupWatchdog = Duration(seconds: 12);

  late YoutubePlayerController _controller;
  StreamSubscription<YoutubePlayerValue>? _sub;

  bool _showFallback = false;
  bool _didRetry = false;
  bool _playbackStarted = false;
  Timer? _watchdog;

  @override
  void initState() {
    super.initState();
    _createController();
  }

  @override
  void didUpdateWidget(covariant YoutubePlayerBase oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoId != widget.videoId ||
        oldWidget.autoPlay != widget.autoPlay) {
      _disposeController();
      _showFallback = false;
      _didRetry = false;
      _playbackStarted = false;
      _createController();
    }
  }

  void _createController() {
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.videoId,
      autoPlay: widget.autoPlay,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        mute: false,
        loop: false,
        strictRelatedVideos: true,
        playsInline: true,
        enableJavaScript: true,
        // No usar youtube-nocookie: empeora Referer en WebView móvil.
        origin: _embedOrigin,
      ),
    );

    _sub = _controller.stream.listen(_onPlayerValue);
    _armWatchdog();
  }

  void _armWatchdog() {
    _watchdog?.cancel();
    if (_showFallback) return;
    _watchdog = Timer(_startupWatchdog, () {
      if (!mounted || _playbackStarted || _showFallback) return;
      // Sin señal de reproducción real: reintento o fallback.
      _handlePlaybackFailure(reason: 'watchdog');
    });
  }

  void _onPlayerValue(YoutubePlayerValue value) {
    if (!mounted || _showFallback) return;

    final state = value.playerState;
    if (state == PlayerState.playing ||
        state == PlayerState.buffering ||
        state == PlayerState.cued ||
        state == PlayerState.paused) {
      _playbackStarted = true;
      _watchdog?.cancel();
    }

    if (value.hasError) {
      _handlePlaybackFailure(reason: 'api:${value.error}');
    }
  }

  Future<void> _handlePlaybackFailure({required String reason}) async {
    if (!mounted || _showFallback) return;
    debugPrint(
      '[YoutubePlayerBase] fallo embed videoId=${widget.videoId} ($reason)',
    );

    // Un reintento: lives recién publicados a veces fallan al primer load.
    if (!_didRetry) {
      _didRetry = true;
      _playbackStarted = false;
      try {
        await _controller.loadVideoById(videoId: widget.videoId);
      } catch (e) {
        debugPrint('[YoutubePlayerBase] reintento falló: $e');
      }
      _armWatchdog();
      return;
    }

    _watchdog?.cancel();
    setState(() => _showFallback = true);
  }

  void _disposeController() {
    _watchdog?.cancel();
    _sub?.cancel();
    _sub = null;
    _controller.close();
  }

  @override
  void dispose() {
    _disposeController();
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

  Widget _buildFallbackCard() {
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
                'No se pudo reproducir aquí',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Ábrelo en YouTube para ver la transmisión.',
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
                  backgroundColor: youtubeRed,
                  foregroundColor: blanco,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.open_in_new, size: 20),
                    SizedBox(width: 10),
                    Text('Abrir en YouTube'),
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
                  ),
                  BoxShadow(
                    color: colorWithOpacity(accent, 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 2),
                    spreadRadius: -4,
                  ),
                ],
              ),
              child: _showFallback
                  ? _buildFallbackCard()
                  : YoutubePlayer(
                      controller: _controller,
                      aspectRatio: 16 / 9,
                      backgroundColor: negro,
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

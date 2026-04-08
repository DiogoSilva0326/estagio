import 'package:flutter/material.dart';
import 'package:native_web_embeds/native_web_embeds.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:aula_extra/core/components/header/app_header.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({
    super.key,
    required this.name,
    this.photoUrl,
    this.presentationVideoUrl,
    this.isVerified = false,
  });

  final String name;
  final String? photoUrl;
  final String? presentationVideoUrl;
  final bool isVerified;

  String? _extractYoutubeVideoId(String rawUrl) {
    final url = rawUrl.trim();
    if (url.isEmpty) return null;

    final uri = Uri.tryParse(url);
    if (uri == null) return null;

    final host = uri.host.toLowerCase();
    if (host.contains('youtu.be')) {
      final id = uri.pathSegments.isEmpty ? '' : uri.pathSegments.first;
      return id.isEmpty ? null : id;
    }

    if (host.contains('youtube.com')) {
      final videoId = uri.queryParameters['v'];
      if (videoId != null && videoId.trim().isNotEmpty) return videoId.trim();

      if (uri.pathSegments.length >= 2 &&
          (uri.pathSegments.first == 'embed' ||
              uri.pathSegments.first == 'shorts')) {
        final id = uri.pathSegments[1].trim();
        return id.isEmpty ? null : id;
      }
    }

    return null;
  }

  String? _buildYoutubeEmbedUrl(String? rawUrl) {
    final normalized = rawUrl?.trim() ?? '';
    if (normalized.isEmpty) return null;
    final videoId = _extractYoutubeVideoId(normalized);
    if (videoId == null) return null;
    return 'https://www.youtube.com/embed/$videoId?autoplay=1&mute=1&controls=0&loop=1&playlist=$videoId&rel=0&modestbranding=1&playsinline=1';
  }

  Future<void> _openVideo(BuildContext context, String rawUrl) async {
    final uri = Uri.tryParse(rawUrl.trim());
    if (uri == null || !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o vídeo.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final embedUrl = _buildYoutubeEmbedUrl(presentationVideoUrl);
    final isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? true;
    final canOpenVideo = presentationVideoUrl?.trim().isNotEmpty == true;

    return SizedBox(
      height: 408.511,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1E2939), Color(0xFF101828)],
                ),
              ),
            ),
          ),
          if (photoUrl?.trim().isNotEmpty == true)
            Positioned.fill(
              child: Opacity(
                opacity: embedUrl != null && isCurrentRoute ? 0.18 : 0.30,
                child: Image.network(
                  photoUrl!.trim(),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                ),
              ),
            ),
          if (embedUrl != null && isCurrentRoute)
            Positioned.fill(
              child: IgnorePointer(
                child: NativeIframe(
                  src: embedUrl,
                  fill: true,
                  backgroundColor: Colors.black,
                  clipTop: AppHeader.height,
                  cutoutBottomLeftWidth: 255,
                  cutoutBottomLeftHeight: 118,
                ),
              ),
            ),
          Positioned.fill(
            child: Container(
              color: const Color.fromRGBO(16, 24, 40, 0.45),
            ),
          ),
          Positioned(
            left: 291.06,
            top: 68.94,
            child: SizedBox(
              width: 857.872,
              height: 272,
              child: Column(
                children: [
                  InkWell(
                    onTap: canOpenVideo
                        ? () => _openVideo(context, presentationVideoUrl!)
                        : null,
                    borderRadius: BorderRadius.circular(21417702),
                    child: Container(
                      width: 122.553,
                      height: 122.553,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFFFC9039), Color(0xFFF15C64)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.25),
                            blurRadius: 63.83,
                            offset: Offset(0, 31.915),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.play_arrow_rounded,
                          size: 61.277,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Olá! Sou $name',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 38.298,
                      height: 45.957 / 38.298,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10.213),
                  const SizedBox(
                    width: 790.213,
                    child: Text(
                      'Neste vídeo apresento-me e explico como posso ajudar-te a alcançar os teus objetivos de aprendizagem.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22.979,
                        height: 35.745 / 22.979,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 20.426,
            top: 20.426,
            child: Container(
              height: 45.957,
              padding: const EdgeInsets.symmetric(horizontal: 15.319),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(0, 0, 0, 0.7),
                borderRadius: BorderRadius.circular(12.766),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.videocam_outlined, size: 20.426, color: Colors.white),
                  SizedBox(width: 10.213),
                  Text(
                    'Vídeo de Apresentação',
                    style: TextStyle(
                      fontSize: 17.872,
                      height: 25.532 / 17.872,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 40.851,
            top: 306.38,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 204.255,
                  height: 204.255,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 10.213),
                    color: const Color(0xFFF3F4F6),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.25),
                        blurRadius: 63.83,
                        offset: Offset(0, 31.915),
                        spreadRadius: -15.319,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: photoUrl?.trim().isNotEmpty == true
                        ? Image.network(
                            photoUrl!.trim(),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Center(
                              child: Icon(
                                Icons.person,
                                size: 90,
                                color: Color(0xFF6A7282),
                              ),
                            ),
                          )
                        : const Center(
                            child: Icon(
                              Icons.person,
                              size: 90,
                              color: Color(0xFF6A7282),
                            ),
                          ),
                  ),
                ),
                if (isVerified)
                  Positioned(
                    right: -5,
                    bottom: -5,
                    child: Container(
                      width: 61.277,
                      height: 61.277,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFFFC9039), Color(0xFFF15C64)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.1),
                            blurRadius: 19.149,
                            offset: Offset(0, 12.766),
                          ),
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.1),
                            blurRadius: 7.66,
                            offset: Offset(0, 5.106),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.verified, size: 30.638, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

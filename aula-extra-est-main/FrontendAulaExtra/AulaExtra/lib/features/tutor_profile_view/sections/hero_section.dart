import 'package:flutter/material.dart';
import 'package:native_web_embeds/native_web_embeds.dart';

import 'package:aula_extra/core/components/header/app_header.dart';
import 'package:aula_extra/features/tutor_profile_view/constants/tutor_profile_layout.dart';

class HeroSection extends StatefulWidget {
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

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> {
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

  String? _buildYoutubeEmbedUrl(
    String? rawUrl, {
    required bool autoplay,
    required bool muted,
    required bool controls,
    required bool loop,
  }) {
    final normalized = rawUrl?.trim() ?? '';
    if (normalized.isEmpty) return null;
    final videoId = _extractYoutubeVideoId(normalized);
    if (videoId == null) return null;
    final params = <String, String>{
      'autoplay': autoplay ? '1' : '0',
      'mute': muted ? '1' : '0',
      'controls': controls ? '1' : '0',
      'rel': '0',
      'modestbranding': '1',
      'playsinline': '1',
    };
    if (loop) {
      params['loop'] = '1';
      params['playlist'] = videoId;
    }
    return Uri(
      scheme: 'https',
      host: 'www.youtube.com',
      path: '/embed/$videoId',
      queryParameters: params,
    ).toString();
  }

  Future<void> _openVideoDialog(BuildContext context, String playerUrl) {
    final screenSize = MediaQuery.sizeOf(context);
    final dialogWidth = screenSize.width > 1100
        ? 960.0
        : screenSize.width > 820
        ? 760.0
        : screenSize.width - 24;

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: const Color.fromRGBO(15, 23, 42, 0.82),
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.all(12),
          backgroundColor: Colors.transparent,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: dialogWidth),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: ColoredBox(
                color: const Color(0xFF020817),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 10, 14),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Vídeo de Apresentação',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            icon: const Icon(Icons.close, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: NativeIframe(
                        src: playerUrl,
                        fill: true,
                        backgroundColor: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final previewUrl = _buildYoutubeEmbedUrl(
      widget.presentationVideoUrl,
      autoplay: true,
      muted: true,
      controls: false,
      loop: true,
    );
    final playerUrl = _buildYoutubeEmbedUrl(
      widget.presentationVideoUrl,
      autoplay: true,
      muted: false,
      controls: true,
      loop: false,
    );
    final isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? true;
    final hasVideo =
        widget.presentationVideoUrl?.trim().isNotEmpty == true &&
        playerUrl != null;
    final isMobile =
        MediaQuery.sizeOf(context).width <= kTutorProfileMobileBreakpoint;

    if (isMobile) {
      return _MobileHeroSection(
        name: widget.name,
        photoUrl: widget.photoUrl,
        previewUrl: previewUrl,
        hasVideo: hasVideo,
        onPlayTap: hasVideo ? () => _openVideoDialog(context, playerUrl) : null,
      );
    }

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
          if (widget.photoUrl?.trim().isNotEmpty == true)
            Positioned.fill(
              child: Opacity(
                opacity: previewUrl != null && isCurrentRoute ? 0.18 : 0.30,
                child: Image.network(
                  widget.photoUrl!.trim(),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(),
                ),
              ),
            ),
          if (previewUrl != null && isCurrentRoute)
            Positioned.fill(
              child: IgnorePointer(
                child: NativeIframe(
                  src: previewUrl,
                  fill: true,
                  backgroundColor: Colors.black,
                  clipTop: AppHeader.height,
                  cutoutBottomLeftWidth: 255,
                  cutoutBottomLeftHeight: 118,
                ),
              ),
            ),
          Positioned.fill(
            child: Container(color: const Color.fromRGBO(16, 24, 40, 0.45)),
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
                    onTap: hasVideo
                        ? () => _openVideoDialog(context, playerUrl)
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
                    'Olá! Sou ${widget.name}',
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
                  Icon(
                    Icons.videocam_outlined,
                    size: 20.426,
                    color: Colors.white,
                  ),
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
                    child: widget.photoUrl?.trim().isNotEmpty == true
                        ? Image.network(
                            widget.photoUrl!.trim(),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Center(
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
                if (widget.isVerified)
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
                        child: Icon(
                          Icons.verified,
                          size: 30.638,
                          color: Colors.white,
                        ),
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

class _MobileHeroSection extends StatelessWidget {
  const _MobileHeroSection({
    required this.name,
    required this.photoUrl,
    required this.previewUrl,
    required this.hasVideo,
    required this.onPlayTap,
  });

  final String name;
  final String? photoUrl;
  final String? previewUrl;
  final bool hasVideo;
  final VoidCallback? onPlayTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E2939), Color(0xFF101828)],
        ),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(0, 0, 0, 0.35),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.videocam_outlined,
                          size: 16,
                          color: Colors.white,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Vídeo de Apresentação',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        DecoratedBox(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF243247), Color(0xFF101828)],
                            ),
                          ),
                          child: photoUrl?.trim().isNotEmpty == true
                              ? Opacity(
                                  opacity: 0.28,
                                  child: Image.network(
                                    photoUrl!.trim(),
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const SizedBox.shrink(),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.12),
                                Colors.black.withValues(alpha: 0.42),
                              ],
                            ),
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: hasVideo ? onPlayTap : null,
                            child: Center(
                              child: Container(
                                width: 74,
                                height: 74,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color(0xFFFC9039),
                                      Color(0xFFF15C64),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color.fromRGBO(0, 0, 0, 0.25),
                                      blurRadius: 30,
                                      offset: Offset(0, 16),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.play_arrow_rounded,
                                  size: 42,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 16,
                          child: Text(
                            hasVideo
                                ? 'Carrega para ver o vídeo de apresentação do $name.'
                                : 'Vídeo de apresentação indisponível de momento.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              height: 1.45,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
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

/// Barrel export for NativeVideo.
/// Uses the web implementation when running on web, stub otherwise.
library;

export 'native_video_stub.dart'
    if (dart.library.html) 'native_video_web.dart';

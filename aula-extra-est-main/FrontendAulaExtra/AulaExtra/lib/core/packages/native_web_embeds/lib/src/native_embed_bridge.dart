/// Barrel export for NativeEmbedBridge.
/// Uses the web implementation when running on web, stub otherwise.
library;

export 'native_embed_bridge_stub.dart'
    if (dart.library.html) 'native_embed_bridge_web.dart';

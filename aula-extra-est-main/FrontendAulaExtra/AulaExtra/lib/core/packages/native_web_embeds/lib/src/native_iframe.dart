/// Barrel export for NativeIframe.
/// Uses the web implementation when running on web, stub otherwise.
library;

export 'native_iframe_stub.dart'
    if (dart.library.html) 'native_iframe_web.dart';

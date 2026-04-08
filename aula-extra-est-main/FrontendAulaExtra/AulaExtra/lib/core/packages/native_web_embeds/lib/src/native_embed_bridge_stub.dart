/// Non-web stub for native_embed_bridge.
///
/// All functions are no-ops on non-web platforms.
library;

bool get isAvailable => false;

void setClipTop(double y) {}

void createVideo({
  required String id,
  required String src,
  required bool controls,
  required bool autoplay,
  required bool loop,
  required double x,
  required double y,
  required double w,
  required double h,
}) {}

void createIframe({
  required String id,
  required String src,
  required double x,
  required double y,
  required double w,
  required double h,
}) {}

void updateRect({
  required String id,
  required double x,
  required double y,
  required double w,
  required double h,
}) {}

void hideEmbed(String id) {}
void showEmbed(String id) {}
void destroyEmbed(String id) {}
void destroyAll() {}
void hideAll() {}
void showAll() {}

void setBottomLeftCutout({
  required String id,
  required double width,
  required double height,
}) {}

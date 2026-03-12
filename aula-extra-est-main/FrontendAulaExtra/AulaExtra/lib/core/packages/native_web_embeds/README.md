# Native Web Embeds

A Flutter Web module that renders native HTML elements (videos, iframes/Google Maps) above the Flutter CanvasKit canvas. **Works on Chrome, Safari, and Firefox** by bypassing `HtmlElementView` platform-view compositing.

## Why this package?

Flutter Web uses CanvasKit by default, which renders everything on a `<canvas>`. The built-in `HtmlElementView` relies on platform-view compositing that **breaks in Safari & Firefox**:

- Videos don't render or show as black boxes
- Iframes (Google Maps) don't respond to interaction
- OpaqueResponseBlocking errors appear in console

This package solves these issues by creating native DOM elements that float above the Flutter canvas, with precise position synchronization.

## Features

- ✅ Native `<video>` elements with autoplay, loop, controls
- ✅ Native `<iframe>` elements (Google Maps, YouTube, etc.)
- ✅ Works on **Chrome, Safari, and Firefox**
- ✅ Smooth header clipping (video slides behind fixed headers)
- ✅ Mobile drawer detection (hides embeds when hamburger menu opens)
- ✅ Per-frame position synchronization with Flutter widgets
- ✅ Non-web fallbacks for iOS/Android

---

## Installation

### ⚠️ IMPORTANT: Required Files

This package requires **TWO things** to work:
1. **Dart package** (the Flutter widgets)
2. **JavaScript file** (must be copied to your project's `web/` folder)

The JavaScript file handles the native DOM elements and is **NOT automatically included** — you must copy it manually!

---

### Step 1: Add the package dependency

**Option A: Path dependency (copy the folder)**

```bash
# Copy the entire package to your project
cp -r packages/native_web_embeds /path/to/your_project/packages/
```

```yaml
# pubspec.yaml
dependencies:
  native_web_embeds:
    path: packages/native_web_embeds
```

**Option B: Git dependency**

```yaml
# pubspec.yaml
dependencies:
  native_web_embeds:
    git:
      url: https://github.com/your-org/your-repo.git
      path: packages/native_web_embeds
```

---

### Step 2: Copy the JavaScript file (REQUIRED!)

⚠️ **This step is mandatory!** The widgets will NOT work without the JS file.

Copy `native_embeds.js` from this package to your project's `web/` folder:

```bash
# From the package directory
cp packages/native_web_embeds/web/native_embeds.js web/native_embeds.js
```

Your project structure should look like this:

```
your_project/
├── packages/
│   └── native_web_embeds/      ← Dart package
│       ├── lib/
│       ├── web/
│       │   └── native_embeds.js  (source file)
│       └── pubspec.yaml
├── web/
│   ├── index.html
│   └── native_embeds.js        ← COPIED HERE!
├── lib/
└── pubspec.yaml
```

---

### Step 3: Add the script to `index.html` (REQUIRED!)

In your `web/index.html`, add the script tag **BEFORE** `flutter_bootstrap.js`:

```html
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Your App</title>
</head>
<body>
  <!-- ⚠️ ADD THIS LINE BEFORE flutter_bootstrap.js -->
  <script src="native_embeds.js"></script>
  
  <!-- Flutter bootstrap (existing) -->
  <script src="flutter_bootstrap.js" async></script>
</body>
</html>
```

---

### Step 4: Run `flutter pub get`

```bash
flutter pub get
```

---

### ✅ Verification Checklist

Before running your app, verify:

- [ ] `native_web_embeds` folder exists in `packages/`
- [ ] `pubspec.yaml` has the dependency
- [ ] `web/native_embeds.js` exists (copied from package)
- [ ] `web/index.html` has `<script src="native_embeds.js"></script>` BEFORE flutter_bootstrap.js
- [ ] `flutter pub get` ran successfully

---

## Usage

### Video

```dart
import 'package:native_web_embeds/native_web_embeds.dart';

// In your widget tree:
NativeVideo(
  src: '/videos/my-video.mp4',  // Path relative to web/
  autoplay: true,
  loop: true,
  controls: true,
)
```

**Full example with AspectRatio:**

```dart
AspectRatio(
  aspectRatio: 16 / 9,
  child: NativeVideo(
    src: '/images/Video_Final.mp4',
    autoplay: true,
    loop: true,
    controls: true,
  ),
)
```

### Google Maps / Iframe

```dart
import 'package:native_web_embeds/native_web_embeds.dart';

// In your widget tree:
NativeIframe(
  src: 'https://www.google.com/maps/embed?pb=!1m18!1m12!...',
  fill: true,  // Fills available space
)

// Or with aspect ratio:
NativeIframe(
  src: 'https://www.google.com/maps/embed?pb=...',
  fill: false,
  aspectRatio: 16 / 9,
)
```

---

## How It Works

### Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Browser Window                           │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────────┐   │
│  │          #native-embeds-overlay (z-index: 100)          │   │
│  │  ┌─────────────────────────────────────────────────┐    │   │
│  │  │  wrapper div (position:fixed, overflow:hidden)   │    │   │
│  │  │  ┌─────────────────────────────────────────┐    │    │   │
│  │  │  │   <video> or <iframe> (full size)       │    │    │   │
│  │  │  └─────────────────────────────────────────┘    │    │   │
│  │  └─────────────────────────────────────────────────┘    │   │
│  └─────────────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              Flutter CanvasKit Canvas                    │   │
│  │  ┌──────────────────────────────────────────────────┐   │   │
│  │  │  Placeholder widget (colored box, same size)      │   │   │
│  │  └──────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

### Position Synchronization

1. **Dart side**: The `NativeOverlayEmbed` widget renders a colored placeholder box
2. **Per-frame callback**: After each Flutter frame, we read the placeholder's viewport position via `localToGlobal()`
3. **JS side**: The native element is repositioned to match the placeholder exactly
4. **Clipping**: A wrapper `<div>` with `overflow:hidden` clips the element behind fixed headers

### Safari Compatibility

Safari has bugs with video elements inside clipped containers or when their size is modified. This package works around these issues by:

1. Keeping the `<video>` element at **full original size** always
2. Using a **wrapper div** for clipping (the video is just offset inside)
3. Setting `muted` + `playsinline` attributes **before** the `src` attribute

---

## Typical Page Layout

This package works best with a layout like this:

```dart
Scaffold(
  endDrawer: MyDrawerMenu(),  // Hamburger menu (optional)
  body: Column(
    children: [
      TopHeader(),  // Fixed header
      Expanded(
        child: SingleChildScrollView(
          child: Column(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: NativeVideo(src: '/videos/intro.mp4', autoplay: true),
              ),
              // ... other content
              SizedBox(
                height: 400,
                child: NativeIframe(src: 'https://maps.google.com/...'),
              ),
              // ... more content
            ],
          ),
        ),
      ),
    ],
  ),
)
```

The package automatically:
- Detects the scroll area and clips content behind the header
- Hides embeds when the `endDrawer` is open (mobile hamburger menu)

---

## API Reference

### NativeVideo

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `src` | `String` | **required** | Video source URL |
| `autoplay` | `bool` | `false` | Auto-play on load (muted) |
| `loop` | `bool` | `false` | Loop the video |
| `controls` | `bool` | `true` | Show video controls |
| `backgroundColor` | `Color` | `Colors.black` | Placeholder background |

### NativeIframe

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `src` | `String` | **required** | Iframe source URL |
| `fill` | `bool` | `true` | Fill available space |
| `aspectRatio` | `double` | `16/9` | Aspect ratio when `fill=false` |
| `backgroundColor` | `Color` | `Color(0xFFF0F0F0)` | Placeholder background |

### NativeEmbedBridge (advanced)

Low-level bridge for direct JS interop:

```dart
import 'package:native_web_embeds/native_web_embeds.dart';

// Check if JS is loaded
if (NativeEmbedBridge.isAvailable) {
  // Manual operations
  NativeEmbedBridge.hideAll();   // Hide all embeds
  NativeEmbedBridge.showAll();   // Show all embeds
  NativeEmbedBridge.destroyAll(); // Remove all embeds
}
```

---

## Troubleshooting

### Video doesn't play on Safari

1. Ensure `autoplay` videos are also `muted` (Safari requires this)
2. Check that `native_embeds.js` is loaded **before** `flutter_bootstrap.js`
3. Verify the video file is served with correct MIME type (`video/mp4`)

### Video overlaps the header when scrolling

The package detects the scroll area automatically. If it's not working:
- Ensure your video widget is inside a `SingleChildScrollView` or similar
- The header must be **outside** the scroll area (above it in the widget tree)

### Video overlaps the hamburger menu

The package auto-detects `Scaffold.endDrawer`. If using a custom drawer:
- Call `NativeEmbedBridge.hideAll()` when opening
- Call `NativeEmbedBridge.showAll()` when closing

### Iframe doesn't respond to interaction

Make sure the iframe has `pointer-events: auto` (this is set by default).

---

## File Structure

```
packages/native_web_embeds/
├── lib/
│   ├── native_web_embeds.dart      # Main export
│   └── src/
│       ├── native_video.dart        # Video barrel export
│       ├── native_video_web.dart    # Web implementation
│       ├── native_video_stub.dart   # Non-web fallback
│       ├── native_iframe.dart       # Iframe barrel export
│       ├── native_iframe_web.dart   # Web implementation
│       ├── native_iframe_stub.dart  # Non-web fallback
│       ├── native_embed_bridge.dart # Bridge barrel export
│       ├── native_embed_bridge_web.dart  # JS interop
│       ├── native_embed_bridge_stub.dart # Non-web no-ops
│       └── native_overlay_embed_web.dart # Core overlay widget
├── web/
│   └── native_embeds.js            # ← Copy this to your web/ folder
├── pubspec.yaml
└── README.md
```

---

## License

MIT License - Feel free to use in commercial projects.

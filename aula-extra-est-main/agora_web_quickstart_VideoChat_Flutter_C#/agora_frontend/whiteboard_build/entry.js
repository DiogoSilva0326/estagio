import { createFastboard, mount } from "@netless/fastboard";

// Expose the same globals our HTML expects.
// This keeps Flutter Web (iframe) and Flutter IO (WebView) simple.
window.Fastboard = {
  createFastboard,
  mount,
};

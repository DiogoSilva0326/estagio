import esbuild from "esbuild";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const entry = path.join(__dirname, "entry.js");
const outFile = path.resolve(__dirname, "..", "assets", "whiteboard", "fastboard.bundle.js");

await esbuild.build({
  entryPoints: [entry],
  bundle: true,
  format: "iife",
  platform: "browser",
  target: ["es2019"],
  outfile: outFile,
  minify: true,
  sourcemap: false,
  define: {
    "process.env.NODE_ENV": '"production"'
  }
});

console.log("Built:", outFile);

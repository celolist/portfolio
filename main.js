import express from "express";
import { createRequestHandler } from "@remix-run/express";
import { spawn } from "child_process";
import path from "path";
import { fileURLToPath } from "url";
import { dirname } from "path";
import { createProxyMiddleware } from "http-proxy-middleware";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const app = express();
const port = process.env.PORT || 8080;

// --- Rust API起動 ---
const rustBinaryPath = path.join(__dirname, "backend", "target", "release", "backend");
const rustProcess = spawn(rustBinaryPath, [], { stdio: "inherit" });
rustProcess.on("exit", (code) => console.log(`Rust backend exited with code ${code}`));

// --- APIルートをRustにプロキシ ---
app.use("/api", createProxyMiddleware({
  target: "http://localhost:3001",
  changeOrigin: true,
  pathRewrite: { "^/api": "" },
}));

// --- Remix SSR設定 ---
app.use(express.static("app/public"));
app.all("*", createRequestHandler({
  build: await import("./app/build/index.js"),
  mode: process.env.NODE_ENV,
}));

app.listen(port, () => {
  console.log(`✅ Server is listening on http://localhost:${port}`);
});

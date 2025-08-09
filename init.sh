#!/bin/bash
set -e

# 1. Rust API 雛形作成
if [ ! -d backend ]; then
    echo "📦 Creating Rust backend..."
    cargo new --bin backend

    cat > backend/src/main.rs <<'EOF'
use actix_web::{get, App, HttpServer, Responder};

#[get("/hello")]
async fn hello() -> impl Responder {
    "Hello from Rust API!"
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    HttpServer::new(|| App::new().service(hello))
        .bind(("0.0.0.0", 3001))?
        .run()
        .await
}
EOF

    # Cargo.tomlにactix-web依存を追記
    cat >> backend/Cargo.toml <<EOF

[dependencies]
actix-web = "4"
EOF
fi

# 2. Remix雛形作成
if [ ! -d app ]; then
    echo "📦 Creating Remix app..."
    npm create remix@latest app -- --template remix --yes
    cd app
    npm install
    npm run build
    cd ..
fi

# 3. main.js作成
if [ ! -f main.js ]; then
    echo "📄 Creating main.js..."
    cat > main.js <<'EOF'
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
EOF
fi

# 4. Rustビルド
echo "🔨 Building Rust backend..."
cd backend
cargo build --release
cd ..

# 5. Node.jsサーバー起動
echo "🚀 Starting Node.js server..."
cd /app
node main.js

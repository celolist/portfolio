## 必要条件

- Docker（Docker Desktopなど）がインストールされていること
- Docker Compose が使える環境

---

## ディレクトリ構成（初回は空でもOK）
```
portfolio/
├── Dockerfile
├── docker-compose.yml
└── README.md
```

---

## 初回セットアップ・起動手順

1. ターミナル（PowerShellやコマンドプロンプト）でプロジェクトディレクトリへ移動

```bash
cd [プロジェクトルート]
```

2. Dockerコンテナをビルド・起動（初回はRustとRemixの雛形が自動生成されます）

```bash
docker-compose up --build
```

3. 起動後に以下のURLでアクセス確認

- Remix SSRフロントエンド http://localhost:8080
- Rust APIエンドポイント（例）http://localhost:8080/api/hello

---

## 動作確認
- app/ ディレクトリにRemixアプリが生成されます
- backend/ にRust APIプロジェクトが生成されます
- main.js はNode.jsサーバーで、
  - /api/* へのアクセスはRust APIにプロキシ
  - それ以外はRemixでSSRを返します
- 生成されたファイルはホスト側のディレクトリに保存され、次回起動時は再生成されません
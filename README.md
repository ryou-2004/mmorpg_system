# MMORPG System 🎮

セミリアルタイム+ポジション制バトルシステムを持つMMORPGのバックエンドAPI

## 🏗️ システム構成

```
Unity Client (PC/Console)  ─┐
Flutter App (Mobile)       ─┼─→ Rails API Server ←─ Next.js Admin Panel  
WebSocket (Real-time)      ─┘                    
```

## 📚 ドキュメント

- **[📋 システム設計書](MMORPG_SYSTEM_DESIGN.md)** - 包括的な設計書・実装ロードマップ
- **[👨‍💼 管理画面](https://github.com/ryou-2004/mmorpg-admin)** - Next.js製管理画面（別リポジトリ）
- **[📖 Wiki](https://github.com/ryou-2004/mmorpg_system/wiki)** - 詳細な仕様書・開発ガイド

## 🚀 技術スタック

### バックエンド
- **Ruby** 3.2+
- **Rails** 8.0 (API mode)
- **SQLite3** (開発環境)
- **ActionCable** (WebSocket/リアルタイム通信)
- **bcrypt** (パスワード認証)
- **JWT** (トークン認証)

### フロントエンド
- **Next.js** 14 (管理画面)
- **React** 18 + TypeScript
- **Tailwind CSS** (スタイリング)

### ゲームクライアント（予定）
- **Unity** 2022+ (PC/Console)
- **Flutter** 3+ (Mobile)

## 🎯 現在の実装状況

### ✅ 実装済み
- [x] Rails API基盤（User, Player, JobClass）
- [x] JWT認証システム
- [x] 管理画面（Next.js）
- [x] ユーザー・プレイヤー・職業管理
- [x] N+1問題対応済みAPI
- [x] シードデータ（5ユーザー、13プレイヤー、9職業）

### 🔥 次期実装予定
- [ ] アイテムシステム
- [ ] ステータスシステム  
- [ ] スキルシステム
- [ ] 戦闘システム基盤

## 🛠️ セットアップ

### 1. 依存関係のインストール
```bash
bundle install
```

### 2. データベースセットアップ
```bash
rails db:create
rails db:migrate  
rails db:seed
```

### 3. サーバー起動
```bash
rails server
# → http://localhost:3000
```

### 4. 管理画面セットアップ（別リポジトリ）
```bash
cd ../mmorpg-admin
npm install
npm run dev  
# → http://localhost:3001
```

## 🔑 認証情報

### 管理者アカウント
```
Email: admin@mmorpg.local
Password: password123
Role: super_admin
```

### テスト用APIアクセス（開発環境のみ）
```
# 認証不要でブラウザからアクセス可能
http://localhost:3000/admin/job_classes?test=true
http://localhost:3000/admin/users?test=true  
http://localhost:3000/admin/players?test=true
```

## 🎮 ゲームシステム特徴

### セミリアルタイム+ポジション制バトル
```
[前列] [中列] [後列]
  🧙    ⚔️    🏹     ← プレイヤーパーティ (4人)
  
  👹    🐉    👻     ← 敵モンスター
[前列] [中列] [後列]
```

- **リアルタイム要素**: スキルクールダウンがリアルタイムで進行
- **戦略性**: ポジション選択が攻撃力・防御力・魔法射程に影響
- **協力プレイ**: 他プレイヤーの行動がリアルタイムで反映

### 職業システム
- **基本職** (4種): 戦士、魔法使い、僧侶、盗賊
- **上級職** (3種): パラディン、賢者、アサシン  
- **特殊職** (2種): 魔剣士、召喚師

## 📊 API エンドポイント

### 管理者API
```
POST   /admin/session           # ログイン
DELETE /admin/session           # ログアウト
GET    /admin/dashboard         # ダッシュボード
GET    /admin/users             # ユーザー一覧
GET    /admin/users/:id         # ユーザー詳細
GET    /admin/players           # プレイヤー一覧
GET    /admin/job_classes       # 職業一覧
```

### ゲーム用API（実装予定）
```
POST   /api/v1/session          # プレイヤーログイン
GET    /api/v1/players/:id      # プレイヤー情報
GET    /api/v1/players/:id/items # インベントリ
POST   /api/v1/battle/start     # 戦闘開始
POST   /api/v1/battle/skill     # スキル使用
```

## 🗂️ プロジェクト構造

```
mmorpg_system/
├── app/
│   ├── controllers/
│   │   ├── admin/              # 管理画面用API
│   │   └── api/v1/             # ゲームクライアント用API（予定）
│   ├── models/                 # データモデル
│   ├── channels/               # ActionCable（予定）
│   └── jobs/                   # バックグラウンドジョブ
├── db/
│   ├── migrate/                # マイグレーションファイル
│   └── seeds/                  # シードデータ（モデル別）
├── config/
│   ├── routes.rb               # ルーティング
│   └── skills.yml              # スキル設定（予定）
└── MMORPG_SYSTEM_DESIGN.md     # 📋 設計書
```

## 🧪 テスト

```bash
# モデルテスト実行
rails test:models

# 全テスト実行  
rails test
```

## 📈 開発ロードマップ

### Phase 1: アイテムシステム基盤 🔥
- Item, PlayerItem モデル実装
- インベントリAPI
- アイテム管理画面

### Phase 2: ステータスシステム 📊  
- PlayerStat モデル実装
- レベルアップシステム
- ステータス計算ロジック

### Phase 3: スキルシステム ⚔️
- Skill, PlayerSkill モデル実装  
- Effect システム（Strategy Pattern）
- スキル管理画面

### Phase 4: 戦闘システム基盤 ⚔️
- ActionCable セットアップ
- BattleRoom 実装  
- リアルタイム戦闘API

### Phase 5: マップ・クエストシステム 🗺️
- Area, Monster モデル実装
- クエストシステム  
- プレイヤー進行管理

### Phase 6: ソーシャル機能 👥
- ギルドシステム
- パーティシステム
- フレンドシステム

## 🤝 開発への参加

1. リポジトリをフォーク
2. フィーチャーブランチを作成 (`git checkout -b feature/awesome-feature`)
3. 変更をコミット (`git commit -m 'Add awesome feature'`)
4. ブランチにプッシュ (`git push origin feature/awesome-feature`)  
5. プルリクエストを作成

## 📝 ライセンス

このプロジェクトはMITライセンスの下で公開されています。

## 📞 お問い合わせ

- **GitHub**: [@ryou-2004](https://github.com/ryou-2004)
- **Project Link**: [https://github.com/ryou-2004/mmorpg_system](https://github.com/ryou-2004/mmorpg_system)

---

**最終更新**: 2025-07-30  
**バージョン**: 2.0  
🤖 **Generated with**: [Claude Code](https://claude.ai/code)
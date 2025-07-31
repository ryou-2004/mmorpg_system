# Claude Code セッション継続ガイド

## プロジェクト概要
Dragon Quest風のMMORPG職業システムをRails API + Next.js管理画面 + Unity/Flutterクライアントで実装。
各職業が独自のレベルを持ち、職業切り替え可能なセミリアルタイム戦闘システム。

### システム構成
- **バックエンド**: Rails 8.0 API サーバー (SQLite)
- **フロントエンド**: Unity (メインゲーム)、Flutter (アカウント管理・ミニゲーム)
- **管理画面**: Next.js 14/React/TypeScript
- **リアルタイム通信**: ActionCable (WebSocket)
- **認証**: JWT Token ベース

## 開発方針・指示

### コード品質
- **コメントアウト禁止**: 自己説明的なコードを書く。コメントがないとわからないコードは書かない
- **RESTful設計**: 単一責任の原則に従い、Controllerを適切に分離
- **動的計算**: 累積保存ではなく動的計算によるデータ整合性確保
- **Strategy Pattern**: スキル効果システムに採用予定

### コミット・デプロイ方針
- **日本語コミットメッセージ**: 全てのコミットメッセージは日本語で記述
- **機能単位コミット**: 実装完了のたびに必ずコミット
- **CI/CD事前チェック**: 
  - Next.js: そのままプッシュ可能
  - Rails: lint(RuboCop)、rspec、基本動作確認後にプッシュ

## ディレクトリ構造
```
/mnt/c/Users/ryo/Documents/apps/
├── mmorpg_system/          # Rails API (main branch)
├── mmorpg-admin/           # Next.js管理画面 (master branch)
└── MMORPG_SYSTEM_DESIGN.md # 全体設計書
```

## 現在の実装状況 (2025-07-31)

### ✅ 実装済み機能

#### データベース設計
- **基本認証システム**: Users, AdminUsers
- **職業毎レベルシステム**: PlayerJobClass model with delegate pattern
- **動的ステータス計算**: JobClass基本値 + レベル成長 × 職業補正値
- **現在職業管理**: Player.current_job_class_id
- **データマイグレーション**: 既存PlayerStatからPlayerJobClassへの移行完了

#### API エンドポイント (RESTful化完了)
- `GET /admin/job_class_stats` - 全職業レベル別統計
- `GET /admin/job_class_stats/:id` - 個別職業成長チャート  
- `GET /admin/job_level_samples` - レベル別職業比較・ランキング
- `GET /admin/job_comparisons` - 職業間比較・マルチレベル対応
- 基本CRUD: Users, Players, JobClasses管理

#### Next.js管理画面
- 認証システム (JWT Token)
- ユーザー管理・プレイヤー管理・職業管理
- **職業統計システム**: 
  - `/job-stats` - 職業統計メイン画面
  - `/job-stats/level-samples` - レベル別統計・ランキング
  - `/job-stats/compare` - 職業比較ツール
- TailwindCSS レスポンシブデザイン
- AdminLayout統一レイアウト

### 🔥 次期実装予定 (Phase 1)

#### アイテムシステム基盤
```ruby
# 予定モデル
class Item < ApplicationRecord
  enum item_type: { weapon: 'weapon', armor: 'armor', consumable: 'consumable' }
  enum rarity: { common: 'common', rare: 'rare', epic: 'epic', legendary: 'legendary' }
  # fields: name, description, effects:json, buy_price, sell_price, etc.
end

class PlayerItem < ApplicationRecord
  belongs_to :player
  belongs_to :item
  # fields: quantity, equipped, durability, enchantment_level, etc.
end
```

## 実装アーキテクチャ

### システム設計パターン
```
Player (委譲先) ──→ PlayerJobClass (実装先) ──→ JobClass (設定元)
   │                      │                        │
   │ delegate              │ 動的計算                │ 基本値・補正値
   │                      │                        │
   └─ hp, mp, attack      └─ level × multiplier    └─ base_hp, hp_multiplier
      defense, agility       + base_value             base_attack, etc.
```

### Option A: Player Delegation Pattern
```ruby
# Player Model
class Player < ApplicationRecord
  delegate :hp, :max_hp, :mp, :max_mp, :attack, :defense, 
           :magic_attack, :magic_defense, :agility, :luck, 
           to: :current_job_class
end

# PlayerJobClass Model (動的計算)
def hp
  job_class.base_hp + (level * job_class.hp_multiplier).to_i
end
```

### RESTful Controller設計
```
JobStatsController (旧)
├── GET /job_class_stats      → Admin::JobClassStatsController
├── GET /job_level_samples    → Admin::JobLevelSamplesController  
└── GET /job_comparisons      → Admin::JobComparisonsController
```

## 重要な技術決定

### データ設計
- **Option A採用**: PlayerからJobClassへのdelegate pattern
- **動的計算**: `base_value + (level_growth * multiplier)`
- **skill_points**: stat_pointsから名称変更済み
- **RESTful Controller分離**: 機能別Controller設計

### 戦闘システム設計 (設計済み・未実装)
- **セミリアルタイム+ポジション制**: 前列・中列・後列
- **Strategy Pattern**: BaseEffect, DamageEffect, HealEffect, StatusEffect
- **WebSocket通信**: ActionCable使用予定

### API設計原則
- **パラメータ処理**: CSV文字列の適切な分割処理 (`split(",")`)
- **エラーハンドリング**: 統一されたJSON レスポンス
- **認証**: development_test_mode対応 (`params[:test] == "true"`)
- **N+1対策**: includes使用済み

## 開発ワークフロー
1. 機能設計・実装
2. コメント削除・自己説明的コード化
3. RuboCop修正 (Rails)
4. 基本動作確認 (ルーティング・マイグレーション・Rails console)
5. 日本語コミットメッセージでコミット
6. プッシュ

## 実装ロードマップ

### Phase 1: アイテムシステム基盤 🔥 (最優先)
- Item モデル・マイグレーション作成
- PlayerItem モデル・マイグレーション作成
- アイテム Seed データ作成 (武器10種、防具15種、消耗品8種)
- Items API実装 (admin/api)
- アイテム管理画面実装 (Next.js)

### Phase 2: ステータスシステム 📊
- PlayerStat モデル見直し (現在はPlayerJobClassに統合済み)
- レベルアップロジック実装
- 装備品効果計算システム

### Phase 3: スキルシステム ⚔️
- Skill, PlayerSkill モデル作成
- Effect システム実装 (Strategy Pattern)
- スキル設定読み込み (YAML)

### Phase 4: 戦闘システム基盤 ⚔️
- ActionCable セットアップ
- BattleRoom 実装
- 戦闘API実装

## 開発環境・確認事項

### 基本コマンド
```bash
# Rails サーバー起動
cd /mnt/c/Users/ryo/Documents/apps/mmorpg_system
rails server

# Next.js 開発サーバー起動  
cd /mnt/c/Users/ryo/Documents/apps/mmorpg-admin
npm run dev

# データベースリセット & Seed実行
rails db:drop db:create db:migrate db:seed
```

### テスト用URL
```
# 管理画面
http://localhost:3001/

# API テスト (開発環境のみ)
http://localhost:3000/admin/job_class_stats?test=true
http://localhost:3000/admin/job_level_samples?level=30&test=true
```

## 次回セッション時の確認事項
1. **Todoリストの継続状況**: 現在21項目完了
2. **実装中の機能詳細**: アイテムシステム着手予定
3. **発生している課題・エラー**: 特になし (2025-07-31時点)
4. **ユーザーからの新しい要求**: 次のフェーズ指示待ち
5. **設計書整合性**: MMORPG_SYSTEM_DESIGN.mdとの同期確認

## 重要なファイル
- `MMORPG_SYSTEM_DESIGN.md`: 全体設計書・ロードマップ
- `CLAUDE.md`: このファイル (セッション継続用)
- `app/models/player_job_class.rb`: 動的ステータス計算の核心実装
- `app/controllers/admin/job_*_controller.rb`: RESTful API実装例

---
*最終更新: 2025-07-31 - 職業統計システムRESTful化・MMORPG設計書統合完了*
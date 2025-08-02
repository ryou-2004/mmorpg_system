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

## 現在の実装状況 (2025-08-03)

### ✅ 実装済み機能

#### データベース設計
- **基本認証システム**: Users, AdminUsers
- **キャラクター職業システム**: CharacterJobClass model with delegate pattern
- **動的ステータス計算**: JobClass基本値 + レベル成長 × 職業補正値  
- **現在職業管理**: Character.current_character_job_class_id
- **データマイグレーション**: Player → Character 名称統一完了
- **装備システム**: CharacterItem equipment_slot 対応、装備効果計算
- **経験値システム**: レベル1-100対応、Dragon Quest風成長カーブ

#### API エンドポイント (RESTful化完了)
- `GET /admin/users` - ユーザー一覧・詳細
- `GET /admin/characters` - キャラクター一覧・詳細
- `GET /admin/job_classes` - 職業一覧・詳細・編集
- `GET /admin/items` - アイテム一覧・詳細・編集
- `GET /admin/characters/:id/character_job_classes/:id` - キャラクター職業詳細
- `GET /admin/job_class_stats` - 全職業レベル別統計
- `GET /admin/job_level_samples` - レベル別職業比較・ランキング
- `GET /admin/job_comparisons` - 職業間比較・マルチレベル対応
- `GET /admin/characters/:id/equipment` - キャラクター装備状態取得
- `POST /admin/characters/:id/equipment/equip` - 装備装着
- `POST /admin/characters/:id/equipment/unequip` - 装備解除
- `PATCH /admin/characters/:id/add_experience` - 経験値手動調整

#### Next.js管理画面 (完全実装済み)
- **認証システム**: JWT Token ベース
- **ユーザー管理**: 一覧・詳細（現在の職業表示、キャラクター管理）
- **キャラクター管理**: 一覧・詳細・職業切り替え・倉庫管理
- **職業管理**: 一覧・詳細・編集（フローティングボタン）
- **アイテム管理**: 一覧・詳細・編集（equipment_slot対応）
- **装備システム**: 装備状態一覧・装着/解除・左手装備制限UI
- **キャラクター職業詳細**: 個人成長履歴・レベル進捗バー・統計表示
- **職業マスター詳細**: 同職業ランキング・統計情報・基本値/成長率表示
- **職業統計システム**: レベル別統計・職業比較ツール
- **経験値管理**: 進捗表示・手動調整フォーム（管理者用）
- **TailwindCSS**: レスポンシブデザイン・統一UI/UX
- **表形式レイアウト**: 一覧画面の統一デザイン
- **クリッカブルカード**: 詳細ページへの直接遷移

### 🔥 実装予定項目 (優先度順)

#### Phase 1: ログ・監査システム (高優先度)
1. **経験値変更ログシステム実装**
   - ExperienceLog モデル作成（管理者・変更理由・変更前後値記録）
   - Rails ログ記録API実装
   - Next.js ログ表示ページ作成
   - ログ検索・フィルター機能

#### Phase 2: ゲームシステム拡張 (中優先度)  
2. **テストファイル・fixture更新**
   - RSpec テストスイート整備
   - テストデータ整合性確保

3. **レベルアップシミュレーター**
   - レベルアップ予測表示
   - 経験値投入シミュレーション
   - スキルポイント計算

4. **スキルシステム基盤実装**
   - Skill, CharacterSkill モデル作成
   - Strategy Pattern による Effect システム
   - スキル設定ファイル (YAML) 読み込み

#### Phase 3: パフォーマンス・戦闘システム (低優先度)
9. **データベースパフォーマンス最適化**
   - インデックス設定最適化
   - N+1問題解決・クエリ最適化

10. **戦闘システム基盤実装**
    - ActionCable セットアップ
    - BattleRoom 実装・戦闘API実装
    - セミリアルタイム戦闘ロジック

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

## 実装完了項目 (2025-08-03時点)

### 🎉 今セッションで完了した機能
1. **レベルアップ・経験値システム完全実装**
   - CharacterJobClass経験値テーブル拡張（レベル1-100、Dragon Quest風カーブ）
   - Rails経験値調整API実装（add_experienceアクション）
   - Next.js ExperienceDisplayコンポーネント（進捗バー・レベル表示）
   - Next.js ExperienceAdjustmentFormコンポーネント（管理者用調整フォーム）
   - 確認ダイアログ・理由入力・監査機能

2. **装備システム完全実装**
   - キャラクター装備状態一覧ページ
   - 装備装着/解除機能・リアルタイムステータス更新
   - 左手装備制限UI（職業別can_equip_left_hand対応）
   - 装備効果計算システム統合

3. **TypeScript・ビルドエラー解決**
   - apiClientにpatch()メソッド追加
   - Equipment関連型定義修正
   - boolean型ハンドリング修正
   - Next.jsビルド成功確認済み

4. **Ruby定数初期化エラー修正**
   - CharacterJobClassのgenerate_exp_tableメソッド定義順序修正
   - LEVEL_EXP_TABLE定数の正常初期化

### 💡 設計改善点
- **管理者機能の明確化**: 経験値調整フォームに警告・確認機能追加
- **リアルタイム更新**: 装備変更時の即座なステータス反映
- **監査機能**: 経験値変更時の理由記録（ログシステムは次回実装予定）
- **UI/UX一貫性**: 全コンポーネントでTailwindCSS統一デザイン

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
1. **Todoリストの継続状況**: 現在25項目完了・3項目待機中
2. **最優先実装項目**: 経験値変更ログシステム実装
3. **発生している課題・エラー**: 特になし (2025-08-03時点)
4. **次期フェーズ**: ログ・監査システム → スキルシステム実装
5. **管理画面完成度**: レベルアップ・装備システム含む基本機能100%実装済み
6. **経験値調整機能**: 実装済み、ログ表示ページは未実装

## 重要なファイル
- `MMORPG_SYSTEM_DESIGN.md`: 全体設計書・ロードマップ
- `CLAUDE.md`: このファイル (セッション継続用)
- `app/models/player_job_class.rb`: 動的ステータス計算の核心実装
- `app/controllers/admin/job_*_controller.rb`: RESTful API実装例

---
*最終更新: 2025-08-03 - 経験値調整システム・装備システム完全実装、Ruby定数初期化エラー修正、Next.jsビルドエラー解決完了*

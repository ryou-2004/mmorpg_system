# MMORPG System

セミリアルタイム+ポジション制バトルシステムを持つMMORPGのバックエンドAPI

## 技術スタック

* Ruby 3.3+
* Rails 8.0 (API mode)
* SQLite3 (開発環境)
* ActionCable (リアルタイム通信)
* bcrypt (パスワード認証)

## セットアップ

```bash
bundle install
rails db:create
rails db:migrate
rails db:seed
```

## 機能

- 管理者アカウント管理
- プレイヤーアカウント管理
- リアルタイム戦闘システム
- ポジション制バトル
- スキル・アイテムシステム

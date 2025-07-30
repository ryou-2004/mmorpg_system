# MMORPGシステム設計書（改訂版）

## 1. プロジェクト概要

### 1.1 システム構成
- **バックエンド**: Rails 8.0 API サーバー (SQLite)
- **フロントエンド**: Unity (メインゲーム)、Flutter (アカウント管理・ミニゲーム)
- **管理画面**: Next.js 14/React/TypeScript
- **リアルタイム通信**: ActionCable (WebSocket)
- **認証**: JWT Token ベース

### 1.2 マルチプラットフォーム対応
```
Unity Client (PC/Console)  ─┐
Flutter App (Mobile)       ─┼─→ Rails API Server ←─ Next.js Admin Panel
WebSocket (Real-time)      ─┘
```

### 1.3 現在の実装状況 (2025-07-30)
```
✅ 実装済み:
- Rails API基盤 (User, Player, JobClass, AdminUser)
- Next.js管理画面 (認証、ユーザー管理、プレイヤー管理、職業管理)
- JWT認証システム
- N+1問題対応済みAPI
- 職業システム (PlayerJobClass)
- シードデータ (5ユーザー、13プレイヤー、9職業)

🔥 次期実装予定:
- アイテムシステム
- ステータスシステム  
- スキルシステム
- 戦闘システム
```

## 2. データベース設計

### 2.1 実装済みモデル

#### Users (ゲームプレイヤーアカウント)
```ruby
class User < ApplicationRecord
  has_many :players, dependent: :destroy
  
  # Fields:
  # - name: string
  # - email: string  
  # - password_digest: string
  # - active: boolean
  # - last_login_at: datetime
end
```

#### Players (ゲーム内キャラクター)
```ruby
class Player < ApplicationRecord
  belongs_to :user
  has_many :player_job_classes, dependent: :destroy
  has_many :job_classes, through: :player_job_classes
  
  # Fields:
  # - name: string
  # - gold: integer (default: 1000)
  # - active: boolean
  # - last_login_at: datetime
end
```

#### JobClasses (職業)
```ruby
class JobClass < ApplicationRecord
  has_many :player_job_classes, dependent: :destroy
  has_many :players, through: :player_job_classes
  
  # Fields:
  # - name: string ("戦士", "魔法使い", etc.)
  # - job_type: string (basic/advanced/special)
  # - max_level: integer
  # - exp_multiplier: decimal
  # - description: text
  # - active: boolean
end
```

#### AdminUsers (管理者)
```ruby
class AdminUser < ApplicationRecord
  # Fields:
  # - name: string
  # - email: string
  # - password_digest: string
  # - role: string (super_admin/admin/moderator)
  # - active: boolean
  # - last_login_at: datetime
end
```

### 2.2 次期実装モデル

#### Items (アイテム)
```ruby
class Item < ApplicationRecord
  has_many :player_items, dependent: :destroy
  has_many :players, through: :player_items
  
  enum item_type: {
    weapon: 'weapon',           # 武器
    armor: 'armor',             # 防具  
    accessory: 'accessory',     # アクセサリー
    consumable: 'consumable',   # 消耗品
    material: 'material',       # 素材
    quest: 'quest'              # クエストアイテム
  }
  
  enum rarity: {
    common: 'common',       # コモン (白)
    uncommon: 'uncommon',   # アンコモン (緑)  
    rare: 'rare',           # レア (青)
    epic: 'epic',           # エピック (紫)
    legendary: 'legendary'  # レジェンダリー (橙)
  }
  
  # Fields:
  # - name: string
  # - description: text
  # - item_type: enum
  # - rarity: enum
  # - max_stack: integer (スタック可能数)
  # - buy_price: integer (購入価格)
  # - sell_price: integer (売却価格)
  # - level_requirement: integer (必要レベル)
  # - job_requirement: json (必要職業)
  # - effects: json (アイテム効果)
  # - icon_path: string
  # - active: boolean
end
```

#### PlayerItems (プレイヤー所持アイテム)
```ruby
class PlayerItem < ApplicationRecord
  belongs_to :player
  belongs_to :item
  
  # Fields:
  # - quantity: integer (所持数)
  # - equipped: boolean (装備中かどうか)
  # - durability: integer (耐久値、装備品用)
  # - max_durability: integer (最大耐久値)
  # - enchantment_level: integer (強化レベル)
  # - obtained_at: datetime (入手日時)
end
```

#### Skills (スキル)
```ruby
class Skill < ApplicationRecord
  has_many :player_skills, dependent: :destroy
  has_many :players, through: :player_skills
  has_many :job_class_skills, dependent: :destroy
  has_many :job_classes, through: :job_class_skills
  
  enum skill_type: {
    active: 'active',       # アクティブスキル
    passive: 'passive',     # パッシブスキル
    ultimate: 'ultimate'    # 必殺技
  }
  
  enum target_type: {
    self: 'self',
    single_ally: 'single_ally',
    single_enemy: 'single_enemy', 
    all_allies: 'all_allies',
    all_enemies: 'all_enemies',
    area: 'area'
  }
  
  # Fields:
  # - name: string
  # - description: text
  # - skill_type: enum
  # - target_type: enum
  # - mp_cost: integer
  # - cooldown: decimal (秒)
  # - cast_time: decimal (詠唱時間)
  # - range: integer (射程)
  # - level_requirement: integer
  # - effects: json (スキル効果設定)
  # - animation_key: string
  # - icon_path: string
  # - active: boolean
end
```

#### PlayerSkills (プレイヤー習得スキル)
```ruby
class PlayerSkill < ApplicationRecord
  belongs_to :player
  belongs_to :skill
  
  # Fields:
  # - skill_level: integer (スキルレベル)
  # - experience: integer (スキル経験値)
  # - unlocked_at: datetime
  # - last_used_at: datetime
end
```

#### PlayerStats (プレイヤーステータス)
```ruby
class PlayerStat < ApplicationRecord
  belongs_to :player
  
  # Fields:
  # - level: integer (default: 1)
  # - experience: integer (default: 0)
  # - hp: integer (現在HP)
  # - max_hp: integer (最大HP)
  # - mp: integer (現在MP)  
  # - max_mp: integer (最大MP)
  # - attack: integer (物理攻撃力)
  # - defense: integer (物理防御力)
  # - magic_attack: integer (魔法攻撃力)
  # - magic_defense: integer (魔法防御力)
  # - agility: integer (素早さ)
  # - luck: integer (運)
  # - stat_points: integer (振り分け可能ポイント)
end
```

## 3. 戦闘システム設計

### 3.1 セミリアルタイム+ポジション制バトル
```
[前列] [中列] [後列]
  🧙    ⚔️    🏹     ← プレイヤーパーティ (4人)
  
  👹    🐉    👻     ← 敵モンスター  
[前列] [中列] [後列]
```

#### ポジション特性
```ruby
POSITIONS = {
  front: { 
    attack_bonus: 1.2, 
    defense_bonus: 0.8, 
    magic_range: 1,
    description: "近接攻撃に有利、魔法射程短い"
  },
  middle: { 
    attack_bonus: 1.0, 
    defense_bonus: 1.0, 
    magic_range: 2,
    description: "バランス型"
  },
  back: { 
    attack_bonus: 0.8, 
    defense_bonus: 1.2, 
    magic_range: 3,
    description: "魔法攻撃に有利、物理攻撃力低下"
  }
}
```

### 3.2 効果システム (Strategy Pattern)

#### BaseEffect クラス
```ruby
module Effects
  class BaseEffect
    attr_reader :config

    def initialize(config)
      @config = config
    end

    def valid_targets(caster, available_targets)
      raise NotImplementedError
    end

    def can_execute?(caster, target)
      true
    end

    def execute(caster, target)
      raise NotImplementedError
    end
  end
end
```

#### 具体的な効果クラス
```ruby
module Effects
  class DamageEffect < BaseEffect
    def valid_targets(caster, available_targets)
      available_targets.select { |t| t.team != caster.team }
    end

    def execute(caster, target)
      damage = config['base_damage'] + (caster.attack * config['attack_ratio'])
      target.take_damage(damage)
      
      {
        type: 'damage',
        value: damage,
        target_id: target.id
      }
    end
  end

  class HealEffect < BaseEffect
    def valid_targets(caster, available_targets)
      available_targets.select { |t| t.team == caster.team && t.hp < t.max_hp }
    end

    def execute(caster, target)
      heal_amount = config['base_heal'] + (caster.magic_attack * config['magic_ratio'])
      actual_heal = target.heal(heal_amount)
      
      {
        type: 'heal',
        value: actual_heal,
        target_id: target.id
      }
    end
  end

  class StatusEffect < BaseEffect
    def valid_targets(caster, available_targets)
      # 状態異常によって対象が変わる
      case config['status_type']
      when 'buff'
        available_targets.select { |t| t.team == caster.team }
      when 'debuff', 'poison', 'sleep'
        available_targets.select { |t| t.team != caster.team }
      end
    end

    def execute(caster, target)
      status = StatusCondition.new(
        type: config['status_type'],
        duration: config['duration'],
        power: config['power']
      )
      
      target.apply_status(status)
      
      {
        type: 'status',
        status_type: config['status_type'],
        duration: config['duration'],
        target_id: target.id
      }
    end
  end
end
```

### 3.3 スキル設定例 (YAML)
```yaml
# config/skills.yml
fireball:
  name: "ファイアボール"
  mp_cost: 5
  cooldown: 3.0
  effects:
    - type: "damage"
      base_damage: 20
      attack_ratio: 0.5
      element: "fire"

heal:
  name: "ヒール"
  mp_cost: 3
  cooldown: 2.0
  effects:
    - type: "heal"
      base_heal: 30
      magic_ratio: 0.8

poison_blade:
  name: "ポイズンブレード"
  mp_cost: 8
  cooldown: 5.0
  effects:
    - type: "damage"
      base_damage: 15
      attack_ratio: 1.0
    - type: "status"
      status_type: "poison"
      duration: 3
      power: 5
      chance: 70

group_heal:
  name: "グループヒール"
  mp_cost: 15
  cooldown: 8.0
  effects:
    - type: "area_heal"
      base_heal: 20
      magic_ratio: 0.6
      range: "all_allies"
```

## 4. API設計

### 4.1 実装済みエンドポイント
```ruby
# config/routes.rb
Rails.application.routes.draw do
  namespace :admin do
    resource :session, only: [:show, :create, :destroy]
    resource :dashboard, only: [:show]
    resources :users, only: [:index, :show]
    resources :players, only: [:index]
    resources :job_classes, only: [:index]
  end
end
```

### 4.2 次期実装予定エンドポイント
```ruby
# ゲーム用API
namespace :api do
  namespace :v1 do
    # 認証
    resource :session, only: [:create, :destroy]
    
    # プレイヤー
    resources :players, only: [:show, :update] do
      resources :items, only: [:index] # インベントリ
      resources :skills, only: [:index] # 習得スキル
      member do
        patch :equip_item
        patch :unequip_item
        post :use_item
        post :learn_skill
      end
    end
    
    # アイテム
    resources :items, only: [:index, :show]
    
    # スキル
    resources :skills, only: [:index, :show]
    
    # 戦闘
    namespace :battle do
      post :start
      post :execute_skill
      post :use_item  
      post :move_position
      get :valid_targets
      get :state
    end
    
    # ショップ
    resources :shops, only: [:index, :show] do
      member do
        post :buy_item
        post :sell_item
      end
    end
  end
end

# 管理画面用API追加
namespace :admin do
  resources :items
  resources :skills
  resources :shops
  resource :battle_logs, only: [:index]
end
```

## 5. フロントエンド実装

### 5.1 Next.js 管理画面 (実装済み)
```
src/
├── app/
│   ├── dashboard/page.tsx        ✅ ダッシュボード
│   ├── users/                    ✅ ユーザー管理
│   ├── players/page.tsx          ✅ プレイヤー管理  
│   ├── job-classes/page.tsx      ✅ 職業管理
│   └── login/page.tsx            ✅ ログイン
├── components/
│   ├── AuthGuard.tsx             ✅ 認証ガード
│   ├── AdminLayout.tsx           ✅ 共通レイアウト
│   └── Dashboard.tsx             ✅ ダッシュボードコンポーネント
└── lib/
    ├── api.ts                    ✅ API クライアント
    └── auth-context.tsx          ✅ 認証コンテキスト
```

### 5.2 Next.js 管理画面 (次期実装)
```
src/app/
├── items/                        🔥 アイテム管理
│   ├── page.tsx                  📦 アイテム一覧
│   ├── [id]/page.tsx             📦 アイテム詳細
│   └── new/page.tsx              📦 アイテム作成
├── skills/                       🔥 スキル管理
│   ├── page.tsx                  ⚔️ スキル一覧
│   └── [id]/page.tsx             ⚔️ スキル詳細
├── battles/                      🎯 戦闘ログ
│   └── page.tsx                  📊 戦闘統計
└── shops/                        💰 ショップ管理
    └── page.tsx                  🏪 ショップ設定
```

## 6. 実装ステップ・ロードマップ

### Phase 1: アイテムシステム基盤 🔥 (次期実装)
```ruby
# 1. マイグレーション作成
rails generate model Item name:string description:text item_type:string rarity:string max_stack:integer buy_price:integer sell_price:integer level_requirement:integer job_requirement:json effects:json icon_path:string active:boolean

rails generate model PlayerItem player:references item:references quantity:integer equipped:boolean durability:integer max_durability:integer enchantment_level:integer obtained_at:datetime

# 2. Seed データ作成
# db/seeds/03_items.rb
# - 武器: 10種類 (剣、斧、杖、弓など)
# - 防具: 15種類 (兜、鎧、盾、靴など)  
# - 消耗品: 8種類 (回復薬、魔法薬など)

# 3. API実装
# app/controllers/api/v1/items_controller.rb
# app/controllers/admin/items_controller.rb

# 4. 管理画面実装  
# src/app/items/page.tsx
```

### Phase 2: ステータスシステム 📊
```ruby
# 1. PlayerStatモデル作成
rails generate model PlayerStat player:references level:integer experience:integer hp:integer max_hp:integer mp:integer max_mp:integer attack:integer defense:integer magic_attack:integer magic_defense:integer agility:integer luck:integer stat_points:integer

# 2. レベルアップロジック実装
# app/models/concerns/level_system.rb

# 3. ステータス計算 (装備品効果含む)
# app/models/concerns/stat_calculator.rb
```

### Phase 3: スキルシステム ⚔️  
```ruby
# 1. スキル関連モデル作成
rails generate model Skill name:string description:text skill_type:string target_type:string mp_cost:integer cooldown:decimal cast_time:decimal range:integer level_requirement:integer effects:json animation_key:string icon_path:string active:boolean

rails generate model PlayerSkill player:references skill:references skill_level:integer experience:integer unlocked_at:datetime last_used_at:datetime

rails generate model JobClassSkill job_class:references skill:references required_level:integer

# 2. Effect システム実装
# app/models/effects/base_effect.rb
# app/models/effects/damage_effect.rb
# app/models/effects/heal_effect.rb
# app/models/effects/status_effect.rb

# 3. スキル設定読み込み
# config/skills.yml
```

### Phase 4: 戦闘システム基盤 ⚔️
```ruby
# 1. ActionCable セットアップ
# app/channels/battle_channel.rb

# 2. BattleRoom 実装
# app/models/battle_room.rb

# 3. 戦闘API実装
# app/controllers/api/v1/battle_controller.rb
```

### Phase 5: マップ・クエストシステム 🗺️
```ruby
# 1. Map関連モデル
rails generate model Area name:string description:text map_data:json level_requirement:integer
rails generate model Monster name:string hp:integer attack:integer defense:integer experience_reward:integer gold_reward:integer

# 2. クエストシステム
rails generate model Quest name:string description:text quest_type:string requirements:json rewards:json active:boolean
rails generate model PlayerQuest player:references quest:references status:string progress:json started_at:datetime completed_at:datetime
```

### Phase 6: ソーシャル機能 👥
```ruby
# 1. ギルドシステム
rails generate model Guild name:string description:text max_members:integer created_at:datetime
rails generate model GuildMember guild:references player:references role:string joined_at:datetime

# 2. パーティシステム  
rails generate model Party name:string max_members:integer created_at:datetime
rails generate model PartyMember party:references player:references role:string joined_at:datetime

# 3. フレンドシステム
rails generate model Friendship player:references friend:references status:string created_at:datetime
```

## 7. Unity側実装予定

### 7.1 基本構造
```csharp
// GameManager.cs - ゲーム全体の管理
public class GameManager : MonoBehaviour
{
    public static GameManager Instance;
    public PlayerController Player;
    public InventoryManager Inventory;
    public SkillManager Skills;
    public BattleManager Battle;
}

// APIClient.cs - サーバー通信
public class APIClient : MonoBehaviour
{
    private string baseURL = "http://localhost:3000/api/v1";
    private string authToken;
    
    public async Task<PlayerData> GetPlayerData(int playerId);
    public async Task<List<Item>> GetInventory(int playerId);
    public async Task<BattleResult> ExecuteSkill(int skillId, List<int> targetIds);
}
```

### 7.2 主要システム
```csharp
// InventoryManager.cs
public class InventoryManager : MonoBehaviour
{
    public List<PlayerItem> items;
    public EquipmentSlot[] equipmentSlots;
    
    public bool CanEquip(Item item);
    public void EquipItem(PlayerItem playerItem);
    public void UnequipItem(EquipmentSlot slot);
    public void UseItem(PlayerItem playerItem);
}

// BattleController.cs  
public class BattleController : MonoBehaviour
{
    public BattleGrid battleGrid;
    public SkillPanel skillPanel;
    public List<PlayerController> players;
    
    private WebSocketConnection battleSocket;
    
    void OnSkillSelected(Skill skill);
    void ExecuteSkill(int skillId, List<int> targetIds);
    void HandleBattleUpdate(string json);
}
```

## 8. 開発環境・設定

### 8.1 現在の環境
```
- Ruby 3.2
- Rails 8.0  
- SQLite3
- Node.js 18+
- Next.js 14
- TypeScript
```

### 8.2 開発コマンド
```bash
# Rails サーバー起動
cd /mnt/c/Users/ryo/Documents/apps/mmorpg_system
rails server

# Next.js 開発サーバー起動  
cd /mnt/c/Users/ryo/Documents/apps/mmorpg-admin
npm run dev

# データベースリセット & Seed実行
rails db:drop db:create db:migrate db:seed

# 新しいマイグレーション作成
rails generate migration AddFieldToModel field:type

# 新しいコントローラー作成
rails generate controller ControllerName action1 action2
```

### 8.3 テスト用URL
```
# 管理画面
http://localhost:3001/

# API テスト (開発環境のみ)
http://localhost:3000/admin/job_classes?test=true
http://localhost:3000/admin/users?test=true
http://localhost:3000/admin/players?test=true
```

## 9. データベース構造図

```
Users (1) ──────────────── (N) Players
                               │
                               │ (1)
                               │
                               ▼ (1)
                         PlayerStats
                               │
                               │ (1)
                               │
                               ▼ (N)
Players (N) ─────────────── (N) PlayerItems ─────────────── (N) Items
   │                                                           │
   │ (N)                                                       │ (1)
   │                                                           │
   ▼ (N)                                                       ▼ (N)
PlayerJobClasses ─────────── (N) JobClasses                ItemCategories
   │                               │
   │ (N)                           │ (N)  
   │                               │
   ▼ (N)                           ▼ (N)
PlayerSkills ────────────── (N) Skills ──────────────── (N) JobClassSkills
                               │
                               │ (1)
                               │  
                               ▼ (N)
                         SkillEffects
```

## 10. 次回セッション用チェックリスト

### 🔥 最優先実装タスク
- [ ] Item モデル・マイグレーション作成
- [ ] PlayerItem モデル・マイグレーション作成  
- [ ] アイテム Seed データ作成
- [ ] Items API実装 (admin/api)
- [ ] アイテム管理画面実装

### 📋 中期タスク
- [ ] PlayerStat モデル実装
- [ ] Skill システム実装
- [ ] Effect システム実装 (Strategy Pattern)
- [ ] 戦闘システム基盤

### 📋 長期タスク  
- [ ] ActionCable セットアップ
- [ ] Unity連携準備
- [ ] マップ・クエストシステム
- [ ] ソーシャル機能

---
**最終更新**: 2025-07-30  
**作成者**: Claude Code  
**バージョン**: 2.0
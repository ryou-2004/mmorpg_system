namespace :skill_lines do
  desc "職業の装備可能武器に基づいてスキルラインを自動生成"
  task generate_from_weapons: :environment do
    puts "職業別スキルライン自動生成を開始します..."
    
    # 武器カテゴリごとのスキルライン情報（ドラクエ10準拠）
    weapon_skill_lines = {
      'one_hand_sword' => {
        name: '片手剣',
        description: '片手剣の技能を向上させ、より強力な剣技を習得します。'
      },
      'two_hand_sword' => {
        name: '両手剣',
        description: '両手剣の威力を最大限に活用し、強力な一撃を放つ技術を学びます。'
      },
      'dagger' => {
        name: '短剣',
        description: '素早い連撃と急所攻撃に特化した短剣の技術を磨きます。'
      },
      'club' => {
        name: '棍',
        description: 'シンプルながら確実なダメージを与える棍棒術を習得します。'
      },
      'axe' => {
        name: '斧',
        description: '破壊力に優れた斧の扱い方を学び、敵の防御を粉砕します。'
      },
      'spear' => {
        name: '槍',
        description: 'リーチを活かした槍術で、安全な距離から敵を攻撃します。'
      },
      'hammer' => {
        name: 'ハンマー',
        description: '重い一撃で敵を粉砕するハンマーの技術を習得します。'
      },
      'staff' => {
        name: '両手杖',
        description: '魔力を増幅させる両手杖の扱い方と、魔法攻撃の威力を高めます。'
      },
      'stick' => {
        name: 'スティック',
        description: '片手で扱える軽量な杖で、素早い魔法を放ちます。'
      },
      'whip' => {
        name: 'ムチ',
        description: '変幻自在のムチさばきで、敵を翻弄しながら攻撃します。'
      },
      'bow' => {
        name: '弓',
        description: '遠距離から正確に敵を射抜く弓術を極めます。'
      },
      'boomerang' => {
        name: 'ブーメラン',
        description: '投げた武器が戻ってくる特殊な技術で、複数の敵を攻撃します。'
      },
      'fan' => {
        name: '扇',
        description: '優雅な扇の舞で敵を魅了し、多彩な技を繰り出します。'
      },
      'claw' => {
        name: 'ツメ',
        description: '野生の本能を活かした爪での連続攻撃を極めます。'
      },
      'martial_arts' => {
        name: '格闘',
        description: '素手による格闘術で、己の拳を武器とする技術を習得します。'
      }
    }
    
    # 各職業に対してスキルラインを作成
    JobClass.find_each do |job_class|
      puts "\n#{job_class.name}のスキルライン生成中..."
      
      # 武器スキルラインの作成
      job_class.job_class_weapons.active.each do |jcw|
        skill_line_info = weapon_skill_lines[jcw.weapon_category]
        next unless skill_line_info
        
        # スキルラインを作成または取得（職業名なし、重複許可）
        skill_line_name = skill_line_info[:name]
        skill_line = SkillLine.create!(
          name: skill_line_name,
          skill_line_type: 'weapon',
          description: skill_line_info[:description],
          active: true
        )
        
        # 職業とスキルラインの関連付け
        JobClassSkillLine.find_or_create_by!(
          job_class: job_class,
          skill_line: skill_line
        ) do |jcsl|
          jcsl.unlock_level = jcw.unlock_level
          jcsl.active = true
        end
        
        puts "  - #{skill_line.name} (解除レベル: #{jcw.unlock_level})"
        
        # 基本的なスキルノードを作成（まだ作成されていない場合）
        if skill_line.skill_nodes.empty?
          create_weapon_skill_nodes(skill_line, jcw.weapon_category)
        end
      end
      
      # 職業専用スキルラインの作成
      job_specific_skill_line = SkillLine.create!(
        name: "#{job_class.name}の心得",
        skill_line_type: 'job_specific',
        description: "#{job_class.name}としての基本的な戦闘技術と精神力を鍛えます。",
        active: true
      )
      
      JobClassSkillLine.find_or_create_by!(
        job_class: job_class,
        skill_line: job_specific_skill_line
      ) do |jcsl|
        jcsl.unlock_level = 1
        jcsl.active = true
      end
      
      puts "  - #{job_specific_skill_line.name} (職業専用)"
      
      # 職業専用スキルノードを作成
      if job_specific_skill_line.skill_nodes.empty?
        create_job_specific_skill_nodes(job_specific_skill_line, job_class)
      end
    end
    
    puts "\n全ての職業のスキルライン生成が完了しました！"
    puts "生成されたスキルライン数: #{SkillLine.count}"
    puts "武器スキル: #{SkillLine.where(skill_line_type: 'weapon').count}"
    puts "職業専用スキル: #{SkillLine.where(skill_line_type: 'job_specific').count}"
  end
  
  private
  
  def create_weapon_skill_nodes(skill_line, weapon_category)
    # 基本的な武器スキルノードのテンプレート
    nodes = [
      {
        name: '基本熟練',
        description: "#{skill_line.name}の基本的な扱いに慣れ、攻撃力が向上します。",
        node_type: 'stat_boost',
        points_required: 5,
        effects: { type: 'stat_boost', stat: 'attack', value: 3 },
        position_x: 0,
        position_y: 0
      },
      {
        name: '上級熟練',
        description: "#{skill_line.name}の扱いに熟達し、さらに攻撃力が向上します。",
        node_type: 'stat_boost',
        points_required: 15,
        effects: { type: 'stat_boost', stat: 'attack', value: 5 },
        position_x: 1,
        position_y: 0
      },
      {
        name: '専門技',
        description: "#{skill_line.name}の特殊技を習得します。",
        node_type: 'technique',
        points_required: 25,
        effects: { type: 'technique', name: "#{skill_line.name}専門技", damage_multiplier: 1.5 },
        position_x: 2,
        position_y: 0
      }
    ]
    
    # 武器種別の特殊ノード
    case weapon_category
    when 'staff'
      nodes << {
        name: '魔力増幅',
        description: '杖の魔力増幅効果を高め、魔法攻撃力が向上します。',
        node_type: 'stat_boost',
        points_required: 10,
        effects: { type: 'stat_boost', stat: 'magic_attack', value: 5 },
        position_x: 0,
        position_y: 1
      }
    when 'dagger'
      nodes << {
        name: '急所狙い',
        description: 'クリティカル率が上昇します。',
        node_type: 'passive',
        points_required: 20,
        effects: { type: 'passive', effect: 'critical_rate', value: 0.1 },
        position_x: 1,
        position_y: 1
      }
    when 'two_hand_sword', 'axe', 'hammer'
      nodes << {
        name: '破壊力強化',
        description: '重い武器の破壊力を最大限に引き出します。',
        node_type: 'stat_boost',
        points_required: 30,
        effects: { type: 'stat_boost', stat: 'attack', value: 8 },
        position_x: 3,
        position_y: 0
      }
    end
    
    nodes.each do |node_data|
      SkillNode.create!(
        skill_line: skill_line,
        name: node_data[:name],
        description: node_data[:description],
        node_type: node_data[:node_type],
        points_required: node_data[:points_required],
        effects: node_data[:effects],
        position_x: node_data[:position_x],
        position_y: node_data[:position_y],
        active: true
      )
    end
  end
  
  def create_job_specific_skill_nodes(skill_line, job_class)
    # 職業別の特殊スキルノード
    base_nodes = [
      {
        name: "#{job_class.name}の基礎",
        description: "#{job_class.name}として基本能力が向上します。",
        node_type: 'stat_boost',
        points_required: 5,
        effects: { type: 'stat_boost', stat: 'hp', value: 10 },
        position_x: 0,
        position_y: 0
      }
    ]
    
    # 職業タイプ別の追加ノード
    case job_class.job_type
    when 'basic'
      base_nodes << {
        name: '成長促進',
        description: '獲得経験値が増加します。',
        node_type: 'passive',
        points_required: 10,
        effects: { type: 'passive', effect: 'exp_bonus', value: 0.05 },
        position_x: 1,
        position_y: 0
      }
    when 'advanced'
      base_nodes << {
        name: '上級者の証',
        description: '全ステータスが小幅に上昇します。',
        node_type: 'stat_boost',
        points_required: 15,
        effects: { type: 'stat_boost', stat: 'all', value: 2 },
        position_x: 1,
        position_y: 0
      }
    when 'special'
      base_nodes << {
        name: '特殊能力開花',
        description: '職業固有の特殊能力が強化されます。',
        node_type: 'passive',
        points_required: 20,
        effects: { type: 'passive', effect: 'special_power', value: 0.1 },
        position_x: 1,
        position_y: 0
      }
    end
    
    base_nodes.each do |node_data|
      SkillNode.create!(
        skill_line: skill_line,
        name: node_data[:name],
        description: node_data[:description],
        node_type: node_data[:node_type],
        points_required: node_data[:points_required],
        effects: node_data[:effects],
        position_x: node_data[:position_x],
        position_y: node_data[:position_y],
        active: true
      )
    end
  end
end
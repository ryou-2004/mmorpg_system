class AddBaseStatsToJobClasses < ActiveRecord::Migration[8.0]
  def change
    add_column :job_classes, :base_hp, :integer, default: 100, null: false
    add_column :job_classes, :base_mp, :integer, default: 50, null: false
    add_column :job_classes, :base_attack, :integer, default: 10, null: false
    add_column :job_classes, :base_defense, :integer, default: 10, null: false
    add_column :job_classes, :base_magic_attack, :integer, default: 10, null: false
    add_column :job_classes, :base_magic_defense, :integer, default: 10, null: false
    add_column :job_classes, :base_agility, :integer, default: 10, null: false
    add_column :job_classes, :base_luck, :integer, default: 10, null: false
    add_column :job_classes, :hp_multiplier, :decimal, precision: 3, scale: 2, default: 1.0, null: false
    add_column :job_classes, :mp_multiplier, :decimal, precision: 3, scale: 2, default: 1.0, null: false
    add_column :job_classes, :attack_multiplier, :decimal, precision: 3, scale: 2, default: 1.0, null: false
    add_column :job_classes, :defense_multiplier, :decimal, precision: 3, scale: 2, default: 1.0, null: false
    add_column :job_classes, :magic_attack_multiplier, :decimal, precision: 3, scale: 2, default: 1.0, null: false
    add_column :job_classes, :magic_defense_multiplier, :decimal, precision: 3, scale: 2, default: 1.0, null: false
    add_column :job_classes, :agility_multiplier, :decimal, precision: 3, scale: 2, default: 1.0, null: false
    add_column :job_classes, :luck_multiplier, :decimal, precision: 3, scale: 2, default: 1.0, null: false
  end
end

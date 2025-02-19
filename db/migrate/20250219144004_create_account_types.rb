class CreateAccountTypes < ActiveRecord::Migration[8.0]
  def change
    create_table :account_types do |t|
      t.boolean :is_minimum_balance_enforced
      t.float :minimum_balance_needed
      t.references :bank, null: false, foreign_key: true

      t.timestamps
    end
  end
end

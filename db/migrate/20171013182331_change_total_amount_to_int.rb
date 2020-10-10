class ChangeTotalAmountToInt < ActiveRecord::Migration[5.1]
  def change
  	change_column :account_movements, :total_amount, 'integer USING CAST(total_amount AS integer)'
  end
end

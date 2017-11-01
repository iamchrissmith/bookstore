class AddNotNullToTitleOnBooks < ActiveRecord::Migration[5.1]
  def change
    change_column_null :books, :title, false
  end
end

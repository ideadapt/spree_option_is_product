class AddAllowMultipleToOptionType < ActiveRecord::Migration
  def change
    add_column :spree_option_types, :allow_multiple, :boolean, default: 0
  end
end

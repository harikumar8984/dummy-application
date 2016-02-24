class AddMarketingLabelToContent < ActiveRecord::Migration
  def change
    add_column :contents, :marketing_label, :string
  end
end

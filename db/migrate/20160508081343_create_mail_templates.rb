class CreateMailTemplates < ActiveRecord::Migration
  def change
    create_table :mail_templates do |t|
    	t.string :device_type
    	t.string :template
    	t.string :context
    	t.text :content, :limit => 1000_000
  
        t.timestamps null: false
    end
  end
end

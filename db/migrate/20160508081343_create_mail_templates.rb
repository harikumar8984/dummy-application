class CreateMailTemplates < ActiveRecord::Migration
  def change
    create_table :mail_templates do |t|
    	t.string :device_type
    	t.string :template
    	t.string :context
    	t.text :content, :limit => 4294967295
  
        t.timestamps null: false
    end
  end
end

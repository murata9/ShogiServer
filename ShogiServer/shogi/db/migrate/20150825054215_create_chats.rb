class CreateChats < ActiveRecord::Migration
  def change
    create_table :chats do |t|
      t.references :user, index: true
      t.references :play, index: true
      t.text :comment
      t.timestamps
    end
  end
end

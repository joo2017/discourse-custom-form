# frozen_string_literal: true

class CreateCustomFormEntries < ActiveRecord::Migration[7.0]
  def change
    create_table :custom_form_entries do |t|
      t.references :post, null: false, foreign_key: true, index: true
      t.references :user, null: false, foreign_key: true, index: true
      t.string :title, null: false, limit: 255
      t.date :event_date, null: false
      t.integer :image_upload_id, null: true
      t.text :description, null: true
      t.timestamps null: false
    end

    add_index :custom_form_entries, [:post_id, :created_at]
    add_index :custom_form_entries, [:user_id, :created_at]
    add_index :custom_form_entries, :event_date
  end
end

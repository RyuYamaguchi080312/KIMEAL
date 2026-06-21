class CreateMvpTables < ActiveRecord::Migration[8.0]
  def change
    create_table :categories do |t|
      t.string :name, null: false

      t.timestamps null: false
    end

    create_table :tags do |t|
      t.string :name, null: false

      t.timestamps null: false
    end

    create_table :recipes do |t|
      t.references :category, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.string :image_url
      t.text :ingredients
      t.text :instructions
      t.integer :cooking_time
      t.integer :source_type, null: false, default: 0
      t.string :external_id
      t.string :source_url

      t.timestamps null: false
    end

    create_table :recipe_tags do |t|
      t.references :recipe, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true

      t.timestamps null: false
    end

    create_table :swipes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :recipe, null: false, foreign_key: true
      t.integer :direction, null: false

      t.timestamps null: false
    end

    create_table :recipe_impressions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :recipe, null: false, foreign_key: true
      t.datetime :displayed_at, null: false

      t.timestamps null: false
    end

    create_table :daily_selections do |t|
      t.references :user, null: false, foreign_key: true
      t.references :recipe, null: false, foreign_key: true
      t.date :selected_on, null: false

      t.timestamps null: false
    end

    add_index :categories, :name, unique: true
    add_index :tags, :name, unique: true
    add_index :recipe_tags, [:recipe_id, :tag_id], unique: true
    add_index :swipes, [:user_id, :recipe_id]
    add_index :recipe_impressions, [:user_id, :recipe_id]
    add_index :daily_selections, [:user_id, :selected_on], unique: true
  end
end

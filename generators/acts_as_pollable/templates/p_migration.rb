class CreatePolls < ActiveRecord::Migration
  def self.up
    create_table :polls do |poll|
      poll.string :name
      poll.string :description
      poll.boolean :enable
      poll.string :type
      poll.boolean :multiple
      poll.integer :max_multiple
      poll.datetime :start_date
      poll.datetime :end_date
      poll.integer :target
    end
    create_table :poll_options do |opt|
      opt.string :description
      opt.belongs_to :poll
      opt.integer :votes, :default => 0
    end
    create_table :poll_answers do |ans|
      ans.belongs_to :pollable, :polymorphic => true
      ans.belongs_to :targetable, :polymorphic => true
      ans.belongs_to :poll_option
      ans.integer :parent_id
    end
  end

  def self.down
    drop_table :polls
    drop_table :poll_options
    drop_table :poll_answers
  end
end


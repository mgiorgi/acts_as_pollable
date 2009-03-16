class PollAnswer < ActiveRecord::Base
  belongs_to :option, :class_name => 'PollOption', :foreign_key => 'poll_option_id', :dependent => :destroy 
  belongs_to :pollable, :polymorphic => true
  belongs_to :targetable, :polymorphic => true
  has_one :poll, :through => :option
  belongs_to :user_target, :class_name => 'User', :foreign_key => 'targetable_id'
  belongs_to :user_source, :class_name => 'User', :foreign_key => 'pollable_id'
  
  named_scope :votes, lambda { |poll_id, target_type, target_id| { :include=>[:option=>[:poll]], :conditions => ['polls.id = ? AND poll_answers.targetable_type = ? AND poll_answers.targetable_id = ?', poll_id, target_type, target_id]} }
end

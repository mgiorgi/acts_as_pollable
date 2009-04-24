class PollAnswer < ActiveRecord::Base
  belongs_to :option, :class_name => 'PollOption', :foreign_key => 'poll_option_id'
  belongs_to :pollable, :polymorphic => true
  belongs_to :targetable, :polymorphic => true
  has_one :poll, :through => :option
  
  named_scope :for_option, lambda { |option_id| { :include=>[:option=>[:poll]], :conditions => ['poll_answers.poll_option_id = ?', option_id]} }
  named_scope :votes, lambda { |poll_id, target_type, target_id| { :include=>[:option=>[:poll]], :conditions => ['polls.id = ? AND poll_answers.targetable_type = ? AND poll_answers.targetable_id = ?', poll_id, target_type, target_id]} }
end

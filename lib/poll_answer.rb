class PollAnswer < ActiveRecord::Base
  belongs_to :option, :class_name => 'PollOption', :foreign_key => 'poll_option_id'
  belongs_to :pollable, :polymorphic => true
end

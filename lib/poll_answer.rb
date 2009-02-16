class PollAnswer < ActiveRecord::Base
  belongs_to :option, :class_name => 'PollOption', :foreign_key => 'poll_option_id', :dependent => :destroy 
  belongs_to :pollable, :polymorphic => true
end

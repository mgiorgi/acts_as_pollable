class Poll < ActiveRecord::Base
  has_many :options, :class_name => 'PollOption'
end

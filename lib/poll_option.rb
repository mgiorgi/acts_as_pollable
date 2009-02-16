class PollOption < ActiveRecord::Base
  belongs_to :poll
  has_many :answers, :class_name => 'PollAnswer', :dependent => :destroy  
end

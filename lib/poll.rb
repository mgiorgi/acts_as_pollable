class Poll < ActiveRecord::Base
  has_many :options, :class_name => 'PollOption', :dependent => :destroy
  has_many :answers, :class_name => 'PollAnswer', :through => :options

  def user_voted?(user)
    answers.of_user(user).count > 0
  end

  def votes_total
    return options.inject(0) {|sum, a| sum += a.votes}
  end
end

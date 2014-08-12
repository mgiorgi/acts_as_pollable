class PollOption < ActiveRecord::Base
  belongs_to :poll
  has_many :answers, :class_name => 'PollAnswer', :dependent => :destroy

  def relative_votes
    return (votes.to_f / poll.votes_total.to_f * 100).to_s
  end

  def winner?
    poll.options.each do |opt|
      return false if opt != self && opt.votes > votes
    end
    return true
  end
end

require 'acts_as_pollable'
require 'poll_helper'
require 'acts_as_vote_handler'
require 'logged_user_helper'
require 'poll_constants'
ActionController::Base.send :include, Mgm::Acts::VoteHandler
ActionView::Base.send :include, Mgm::PollHelper
ActiveRecord::Base.send :include, Mgm::Acts::Pollable

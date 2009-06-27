module Mgm
  module PollHelper
    include LoggedUserHelper

    # Render the poll
    def poll(name, opthash)
      view_dir = get_view_dir(opthash[:view_dir])
      target_type     = opthash[:targetable_type]
      target_id     = opthash[:targetable_id]
      pollable_type     = opthash[:pollable_type]
      pollable_id     = opthash[:pollable_id]
      cookie_name = "acts_as_pollable_#{name}"
      unlogged_user_votes_in_cookies = Marshal.load(cookies[cookie_name]) if cookies[cookie_name]
      poll = Poll.find_by_name(name)
      user = pollable_user(pollable_type, pollable_id)
      #Check for poll existance
      if poll.blank?
        render :file => "#{view_dir}/poll_not_found.rhtml"
      else
        #poll exists confirmed
        #Now, check user existance
        unless user.blank? && poll.target == PollConstants::TARGET_LOGGED_USER
          logged_user_has_voted = user_has_voted_poll?(poll.name, user, target_type, target_id) unless user.blank?
          #Ask if the conditions are met to show the poll
          if user_can_see_poll?(poll, user)
            cookie_voted = (unlogged_user_voted?(unlogged_user_votes_in_cookies, name) and !opthash[:allow_multiple])
            now=Time.now
            if user.blank? && cookie_voted
              render :file => "#{view_dir}/already_voted.rhtml"
            elsif !user.blank? && logged_user_has_voted
              render :file => "#{view_dir}/already_voted.rhtml"
            elsif (!poll.start_date.blank? && poll.start_date > now || !poll.end_date.blank? && poll.end_date < now)
              render :file => "#{view_dir}/poll_outdated.rhtml"
            else
              poll_question = Poll.find(:first, :conditions => ["name = ? ", name])
              unless poll_question.blank?
                question = poll_question.description
                answers = poll_question.options
                render :file => "#{view_dir}/show_poll.rhtml",
                  :locals => { :poll => poll, :in_place => opthash[:in_place], :redirect => opthash[:redirect] , :view_dir => view_dir}        
              else
                render :file => "#{view_dir}/poll_not_found.rhtml"
              end
            end
          end
        else
        #No user found in session & poll configured JUST for USERs (Not anonymous)
        render :file => "#{view_dir}/user_not_logged.rhtml"
        end
      end
    end
  
    # Renders the poll results
    def poll_results(opthash = { } )
      poll_name = opthash[:poll_name] or poll_name = session[:last_poll]
      view_dir = get_view_dir(opthash[:view_dir])
      poll = Poll.find(:first, :conditions => ["name = ? ", poll_name]) 
      unless poll.blank?
        question = poll.description
        answers = poll.options
        votes_total = 0; 
        answers.each { |a| votes_total += a.votes }
        render :file => "#{view_dir}/show_results.rhtml",
	      :locals => { :poll => poll, :votes_total => votes_total }.merge(opthash)
      else
        render :file => "#{view_dir}/poll_not_found.rhtml"
      end
    end
  
    private
    def unlogged_user_voted?(list, poll_name)
      return true if list.includes?(PollConstants::NO_TARGET_SPECIFIED_VOTE)
      list.includes?(poll_name)
    end
  
    def user_has_voted_poll?(poll_name, user, target_type, target_id)
      opts = [poll_name, user.class.to_s, user.id]
      opts += [target_type, target_id] if target_type && target_id
      !!PollAnswer.first(:include => [ :option => [:poll] ], :conditions => ['polls.name = ? AND poll_answers.pollable_type = ? AND poll_answers.pollable_id = ? ' + (target_type && target_id ? ' AND poll_answers.targetable_type = ? AND poll_answers.targetable_id = ?' : '') , *opts])
    end
  
    def user_can_see_poll?(poll, user)
      (poll.target == PollConstants::TARGET_LOGGED_USER && !user.blank?) || \
      (poll.target == PollConstants::TARGET_ANONYMOUS && user.blank?) || \
      (poll.target == PollConstants::TARGET_BOTH)  
    end
  
    def get_view_dir(view_dir_param)
      view_dir = view_dir_param or view_dir = '../../vendor/plugins/acts_as_pollable/views'
      view_dir
    end
  end
end

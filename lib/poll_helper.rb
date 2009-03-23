module Mgm
  module PollHelper
    TARGET_LOGGED_USER = 1
    TARGET_ANONYMOUS = 2
    TARGET_BOTH = 3
  
    # Render the poll
    def poll(name, opthash)
      view_dir = get_view_dir(opthash[:view_dir])
      target_type     = params[:targetable_type]
      target_id     = params[:targetable_id]
      cookie_name = "acts_as_pollable"
      already_cookie = cookies[cookie_name]
      poll = Poll.find_by_name(name)
      #Check for poll existance
      if poll.blank?
        render :file => "#{view_dir}/poll_not_found.rhtml"
      else
        #poll exists confirmed
        #Now, check user existance
        unless current_user.blank? && poll.target == TARGET_LOGGED_USER
          logged_user_has_voted = false || user_has_voted_poll?(poll.name, current_user, target_type, target_id) unless current_user.blank?
          #Ask if the conditions are met to show the poll
          if user_can_see_poll?(poll, current_user.id)
            cookie_voted = (already_cookie == ["1"] and !opthash[:allow_multiple])
            now=Time.now
            if !user_logged? && cookie_voted
              render :file => "#{view_dir}/already_voted.rhtml"
            elsif user_logged? && logged_user_has_voted
              render :file => "#{view_dir}/already_voted.rhtml"
            elsif (!poll.start_date.blank? && poll.start_date > now || !poll.end_date.blank? && poll.end_date < now)
              render :file => "#{view_dir}/poll_outdated.rhtml"
            else
              poll_question = Poll.find(:first, :conditions => ["name = ? ", name])
              unless poll_question.blank?
                question = poll_question.description
                answers = poll_question.options
                render :file => "#{view_dir}/show_poll.rhtml",
                  :locals => { :question => poll_question, :answers => answers, :poll_name => name, :in_place => opthash[:in_place], :redirect => opthash[:redirect] , :view_dir => view_dir}        
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
      poll_question = Poll.find(:first, :conditions => ["name = ? ", poll_name]) 
      unless poll_question.blank?
        question = poll_question.description
        answers = poll_question.options
        votes_total = 0; 
        answers.each { |a| votes_total += a.votes }
        render :file => "#{view_dir}/show_results.rhtml",
	      :locals => { :question => question, :answers => answers, :poll_name => poll_name, :votes_total => votes_total}
      else
        render :file => "#{view_dir}/poll_not_found.rhtml"
      end
    end
  
    private
  
    def user_logged?
      !!current_user
    end
  
    def check_votes_for_logged_user?(poll)
      poll.target == PollHelper::TARGET_LOGGED_USER || poll.target == PollHelper::TARGET_BOTH && user_logged?    
    end
  
    def user_has_voted_poll?(poll_name, user, target_type, target_id)
      opts = [poll_name, user.class.to_s, user.id]
      opts += [target_type, target_id] if target_type && target_id
      !!PollAnswer.first(:include => [ :option => [:poll] ], :conditions => ['polls.name = ? AND poll_answers.pollable_type = ? AND poll_answers.pollable_id = ? ' + (target_type && target_id ? ' AND poll_answers.targetable_type = ? AND poll_answers.targetable_id = ?' : '') , *opts])
    end
  
    def user_can_see_poll?(poll, user)
      (poll.target == PollHelper::TARGET_LOGGED_USER && !user.blank?) || \
      (poll.target == PollHelper::TARGET_ANONYMOUS && user.blank?) || \
      (poll.target == PollHelper::TARGET_BOTH)  
    end
  
    def get_view_dir(view_dir_param)
      view_dir = view_dir_param or view_dir = '../../vendor/plugins/acts_as_pollable/views'
      view_dir
    end
  end
end

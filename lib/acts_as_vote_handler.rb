require 'logged_user_helper'
module Mgm
  include LoggedUserHelper

  public
    # Save the vote, render an answer
    def ap_vote_registered
      poll_name    = params[:poll_name]
      answer_ids = params[:acts_as_pollable_answer]
      in_place     = params[:in_place]
      redirect     = params[:redirect]
      target_type     = params[:targetable_type]
      target_id     = params[:targetable_id]
      pollable_type     = params[:pollable_type]
      pollable_id     = params[:pollable_id]
      view_dir     = get_view_dir(params[:view_dir])
      #change to today.now - question.start_day
      expire_time = 1.year.from_now 
      #find user model from session
      poll = Poll.find_by_name(poll_name)
      user = pollable_user(pollable_type, pollable_id)
      if user.blank?
        salt = poll.name
        cookies["acts_as_pollable_#{salt}"] = {:value => "1", :expires => 1.years.from_now, :path => home_path }
      end
    
      if poll_name.nil?
        render :file => "#{view_dir}/error.rhtml"
      elsif answer_ids.nil?
        render :file => "#{view_dir}/no_vote.rhtml"
      elsif maximum_votes_exceeded(poll, answer_ids)
        render :file => "#{view_dir}/max_votes_exceeded.rhtml"
      else
      
        # register the vote
        PollOption.transaction do
          options = PollOption.find answer_ids
          options.each do |option|
            option.increment! :votes
            answer = PollAnswer.new(:option => option)
            if !target_type.blank? && !target_id.blank?
              answer.targetable_type = target_type
              answer.targetable_id = target_id
            end
            answer.pollable = user if poll.target == Mgm::PollHelper::TARGET_LOGGED_USER || poll.target == Mgm::PollHelper::TARGET_BOTH && !user.blank?
            answer.save!
          end
        end
        
        # remember this poll as the latest poll voted at
        # to help show results
        session[:last_poll] = poll_name
        
        # render in-place or redirect
        if !in_place.nil? and in_place=="true"
    render :file => "#{view_dir}/after_vote.rhtml",
                 :locals => { :poll_name => params[:poll_name], :expire_time =>  expire_time}
        else
    logger.info "redirect to #{redirect}"
    redirect_to redirect
        end
      end
    end  
    
  module Acts
    module VoteHandler
      def self.included(base) 
        base.extend ClassMethods
      end 
      module ClassMethods
        def acts_as_vote_handler(options = {})
          include Mgm::Acts::VoteHandler::InstanceMethods    
          extend Mgm::Acts::VoteHandler::SingletonMethods        
        end
      end
      # Instance methods
      module InstanceMethods 
        include Mgm
      end        
      # Class methods
      module SingletonMethods
      end     
    end #VoteHandler
  end #Acts
   
  private
  def get_view_dir(view_dir_param)
    view_dir_param.blank? ? "#{RAILS_ROOT}/vendor/plugins/acts_as_pollable/views" : "#{RAILS_ROOT}/app/views/#{view_dir_param}"
  end

  def maximum_votes_exceeded(poll, answer_ids)
    !poll.max_multiple.blank? && answer_ids.length > poll.max_multiple
  end
end# ActsAsPollable


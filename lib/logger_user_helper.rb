module LoggedUserHelper
  def pollable_user(pollable_type, pollable_id)
    if pollable_type && pollable_id
      pollable = pollable_type.to_s.classify.constantize.send(:find_by_id, pollable_id)
    else
      current_user
    end
  end
end

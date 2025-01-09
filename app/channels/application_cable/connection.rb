module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user_id
    def connect
      self.current_user_id = find_or_reject_user
    end

    def find_or_reject_user
      cookies.encrypted[:sending_user_id] || reject_unauthorized_connection
    end
  end
end

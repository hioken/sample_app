module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user
    def connect
      self.current_user = find_or_reject_user
    end

    def find_or_reject_user
      User.find_by(id: cookies.encrypted[:sending_user_id].to_i) || reject_unauthorized_connection
    end
  end
end

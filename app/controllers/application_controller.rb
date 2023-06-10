class ApplicationController < ActionController::API
  def current_user
    @current_user ||= User.find_by(id: decoded_token[0]['user_id']) if token_present?
  end

  def decoded_token
    if token_present?
      begin
        JWT.decode(token, secret, true, algorithm: 'HS256')
      rescue JWT::DecodeError
        []
      end
    end
  end
  
end

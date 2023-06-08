class Users::SessionsController < Devise::SessionsController
  clear_respond_to 
  respond_to :json

  def destroy
    signed_out = Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
    render json: { message: "Logged out successfully" }, status: :ok if signed_out
  end

  private
  def respond_with(resource, _opts = {})
    render json: { message: 'Logged in successfully', user: resource }, status: :ok
  end

  def respond_to_on_destroy
    head :no_content
  end
  
  def require_no_authentication
    assert_is_devise_resource!
    return unless is_navigational_format?
    no_input = devise_mapping.no_input_strategies

    authenticated = if no_input.present?
                      args = no_input.dup.push scope: resource_name
                      warden.authenticate?(*args)
                    else
                      warden.authenticated?(resource_name)
                    end

    if authenticated && resource = warden.user(resource_name)
      render
    end
  end

  def set_flash_message!(*args)
    # Do nothing. We don't want to use flash in API mode.
  end
end

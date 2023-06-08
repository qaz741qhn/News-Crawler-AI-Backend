class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    auth = request.env["omniauth.auth"]

    user = User.from_omniauth(auth)

    if user.persisted?
      flash[:notice] = "Successfully logged in with Google!"
      sign_in_and_redirect user
    else
      flash[:alert] = "Error while logging in with Google."
      redirect_to new_user_registration_url
    end
  end
end

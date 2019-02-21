module UserHelper
  extend ActiveSupport::Concern

  def set_user_by_email
    raise CustomExceptions::InvalidRequest.new "'email' is required." unless params[:email]
    @user = User.find_by email: params[:email]
  end

  def set_user_by_email!
    raise CustomExceptions::InvalidRequest.new "'email' is required." unless params[:email]
    @user = User.find_by email: params[:email]
    raise CustomExceptions::EntityNotFound.new 'User' unless @user
  end

  def authenticate_user
    raise CustomExceptions::InvalidRequest.new "'email' and 'password' are required." unless params[:email] && params[:password]
    @user = User.find_by(email: params[:email]).authenticate params[:password]
    raise CustomExceptions::InvalidGrant.new "the credentials provided are invalid." unless @user
    raise CustomExceptions::InvalidGrant.new "User's email address not yet verified." unless @user.verified_email
  end

end

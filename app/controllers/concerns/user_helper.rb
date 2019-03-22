module UserHelper
  extend ActiveSupport::Concern

  def set_user_by_email
    raise CustomExceptions::InvalidRequest.new 6 unless params[:email]
    @user = User.find_by email: params[:email].downcase
  end

  def set_user_by_email!
    raise CustomExceptions::InvalidRequest.new 6 unless params[:email]
    @user = User.find_by email: params[:email].downcase
    raise CustomExceptions::EntityNotFound.new 'User' unless @user
  end

  def authenticate_user
    raise CustomExceptions::InvalidRequest.new 7 unless params[:email] && params[:password]
    @user = User.find_by(email: params[:email].downcase).try(:authenticate, params[:password])
    raise CustomExceptions::InvalidGrant.new 8 unless @user
    raise CustomExceptions::InvalidGrant.new 9 unless @user.verified_email
  end

end

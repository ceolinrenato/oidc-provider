module UserHelper
  extend ActiveSupport::Concern

  private

  def set_user_by_email
    raise CustomExceptions::InvalidRequest, 6 unless params[:email]
    @user = User.find_by email: params[:email].downcase
  end

  def set_user_by_email!
    raise CustomExceptions::InvalidRequest, 6 unless params[:email]
    @user = User.find_by email: params[:email].downcase
    raise CustomExceptions::EntityNotFound, 'User' unless @user
  end

  def authenticate_user
    raise CustomExceptions::InvalidRequest, 7 unless params[:email] && params[:password]
    @user = User.find_by(email: params[:email].downcase).try(:authenticate, params[:password])
    raise CustomExceptions::InvalidGrant, 8 unless @user
    raise CustomExceptions::InvalidGrant, 9 unless @user.verified_email
  end

  def set_user_by_id!
    @user = User.find_by id: params[:user_id]
    raise CustomExceptions::EntityNotFound, 'User' unless @user
  end

  def target_user_authorization
    raise CustomExceptions::InsufficientPermissions, 38 unless @user == @authenticated_user
  end
end

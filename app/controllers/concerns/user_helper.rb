module UserHelper
  extend ActiveSupport::Concern

  def set_user_by_email
    @user = User.find_by email: params[:email]
  end

  def set_user_by_email!
    @user = User.find_by email: params[:email]
    raise CustomExceptions::EntityNotFound.new 'User' unless @user
  end

end

class UsersController < ApplicationController

  before_action :bearer_authorization

  def show
    render json: UserInfoSerializer.new(@authenticated_user)
  end

end

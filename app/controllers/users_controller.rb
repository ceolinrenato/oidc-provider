class UsersController < ApplicationController

  before_action :bearer_authorization

  def show
    user = User.find_by id: @access_token.first["sub"]
    render json: user
  end

end

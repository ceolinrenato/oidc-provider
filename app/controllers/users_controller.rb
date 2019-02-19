class UsersController < ApplicationController
  include UserHelper

  def lookup
    set_user_by_email
    render json: EmailLookupSerializer.new(@user)
  end

end

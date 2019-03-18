module ParamsHelper
  extend ActiveSupport::Concern

  def check_for_unsupported_params
    raise CustomExceptions::RequestNotSupported if params[:request]
    raise CustomExceptions::RequestUriNotSupported if params[:request_uri]
    raise CustomExceptions::RegistrationNotSupported if params[:registration]
  end

end

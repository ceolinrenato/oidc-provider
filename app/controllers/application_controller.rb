class ApplicationController < ActionController::API
  include ActionController::Cookies

  def redirect_with_params(location, params)
    uri = URI(location)
    uri_params = Rack::Utils.parse_nested_query uri.query
    uri.query = uri_params.deep_merge(params).to_query
    redirect_to uri.to_s, status: :found
  end

  def redirect_with_error(location, exception)
    redirect_with_params location,
      {
        error: exception.error,
        error_description: exception.error_description,
        state: params[:state]
      }
  end

end

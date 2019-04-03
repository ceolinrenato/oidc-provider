class ErrorSerializer < BaseSerializer
  def initialize(exception)
    error = {
      error: exception.error,
      error_code: exception.error_code,
      error_description: exception.error_description
    }
    super(error)
  end
end

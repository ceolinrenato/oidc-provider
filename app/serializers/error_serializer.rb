class ErrorSerializer < BaseSerializer
  def initialize(exception)
    error = {
      error: exception.error,
      error_description: exception.error_description
    }
    super(error)
  end
end

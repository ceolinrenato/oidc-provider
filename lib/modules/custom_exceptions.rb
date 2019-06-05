module CustomExceptions
  class BaseException < StandardError
    attr_reader :error, :error_code, :error_description

    def initialize(message, code = nil)
      self.error_description = code if code
      super message
    end

    private

    def error_description=(code)
      error_object = error_list.find { |error| error[:error_code] == code }
      raise ErrorNotFound.new code unless error_object
      @error_code = error_object[:error_code]
      @error_description = error_object[:error_description]
    end

    def error_list
      YAML.load_file "#{Rails.root.join}/config/errors.yml"
    end
  end

  class EntityNotFound < BaseException
    def initialize(entity)
      @error = "entity_not_found"
      @error_code = 0
      @error_description = "Entity not found: #{entity}."
      super @error_description
    end
  end

  class InvalidClient < BaseException
    def initialize
      @error = "invalid_client"
      super @error_description, 1
    end
  end

  class InvalidRequest < BaseException
    def initialize(code)
      @error = "invalid_request"
      super @error_description, code
    end
  end

  class InvalidRedirectURI < BaseException
    def initialize
      @error = "invalid_redirect_uri"
      super @error_description, 4
    end
  end

  class InvalidGrant < BaseException
    def initialize(code)
      @error = "invalid_grant"
      super @error_description, code
    end
  end

  class ErrorNotFound < BaseException
    def initialize(code)
      super "There isn't an error with code: ##{code}"
    end
  end

  class UnauthorizedClient < BaseException
    def initialize(code)
      @error = "unauthorized_client"
      super @error_description, code
    end
  end

  class LoginRequired < BaseException
    def initialize
      @error = "login_required"
      super @error_description, 17
    end
  end

  class AccountSelectionRequired < BaseException
    def initialize
      @error = "account_selection_required"
      super @error_description, 18
    end
  end

  class RequestNotSupported < BaseException
    def initialize
      @error = "request_not_supported"
      super @error_description, 19
    end
  end

  class RequestUriNotSupported < BaseException
    def initialize
      @error = "request_uri_not_supported"
      super @error_description, 20
    end
  end

  class RegistrationNotSupported < BaseException
    def initialize
      @error = "registration_not_supported"
      super @error_description, 21
    end
  end

  class UnsupportedResponseType < BaseException
    def initialize
      @error = "unsupported_response_type"
      super @error_description, 22
    end
  end

  class UnrecognizedDevice < BaseException
    def initialize
      @error = "unrecognized_device"
      super @error_description, 2
    end
  end

  class CompromisedDevice < BaseException
    def initialize
      @error = "compromised_device"
      super @error_description, 23
    end
  end

  class UnsupportedGrantType < BaseException
    def initialize
      @error = "unsupported_grant_type"
      super @error_description, 28
    end
  end

  class InvalidAccessToken < BaseException
    def initialize
      @error = "invalid_token"
      super @error_description, 32
    end
  end

  class InvalidIDToken < BaseException
    def initialize
      @error = "invalid_id_token"
      super @error_description, 33
    end
  end

  class InsufficientScopes < BaseException
    def initialize
      @error = "insufficient_scopes"
      super @error_description, 37
    end
  end

  class InsufficientPermissions < BaseException
    def initialize(code)
      @error = "insufficient_permissions"
      super @error_description, code
    end
  end
end

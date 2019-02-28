module CustomExceptions

  class BaseException < StandardError
    attr_reader :error, :error_code, :error_description

    def initialize(message, code = nil)
      set_description_by_code(code) if code
      super message
    end

    private

    def set_description_by_code(code)
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
    def initialize
      @error = "unauthorized_client"
      super @error_description, 11
    end
  end

end

module CustomExceptions

  class BaseException < StandardError
    attr_reader :error, :error_description
  end

  class EntityNotFound < BaseException
    def initialize(entity)
      @error = "entity_not_found"
      @error_description = "Entity not found: #{entity}."
      super @error_description
    end
  end

  class InvalidRequest < BaseException
    def initialize(description)
      @error = "invalid_request"
      @error_description = description
      super @error_description
    end
  end

  class InvalidGrant < BaseException
    def initialize(description)
      @error = "invalid_grant"
      @error_description = description
      super @error_description
    end
  end

  class InvalidClient < BaseException
    def initialize
      @error = "invalid_client"
      @error_description = "Client authentication failed."
      super @error_description
    end
  end

end

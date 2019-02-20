module CustomExceptions

  class EntityNotFound < StandardError
    attr_reader :error, :error_description
    def initialize(entity)
      @error = 'entity_not_found'
      @error_description = "Entity not found: #{entity}"
      super @error_description
    end
  end

end

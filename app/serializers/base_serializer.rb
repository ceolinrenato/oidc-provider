class BaseSerializer < Hash
  def initialize(object)
    object.each { |key, value| self[key] = value }
  end
end

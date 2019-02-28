class BaseCollectionSerializer < Array
  def initialize(object)
    object.each { |value| self << value }
  end
end

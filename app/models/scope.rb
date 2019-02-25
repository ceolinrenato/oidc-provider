class Scope < ApplicationRecord
  validates :name, presence: true, uniqueness: true


  def self.scope_list
    list = []
    Scope.all.each { |scope| list << scope.name }
    list.sort
  end

end

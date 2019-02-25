class Scope < ApplicationRecord
  validates :name, presence: true, uniqueness: true
end

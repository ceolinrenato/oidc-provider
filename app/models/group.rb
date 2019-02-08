class Group < ApplicationRecord
  belongs_to :company

  validates :name, presence: true, uniqueness: { scope: :company }
  validates :desc, length: { minimum: 10 }
end

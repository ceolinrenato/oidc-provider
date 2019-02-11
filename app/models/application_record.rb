class ApplicationRecord < ActiveRecord::Base
  include Validators
  self.abstract_class = true
end

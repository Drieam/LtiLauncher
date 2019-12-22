# frozen_string_literal: true

# Abstract base class for models backed by ActiveRecord
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end

class Tag < ApplicationRecord
  belongs_to :user

  validates :name, presence: true
  # TODO CRUDの実装
end

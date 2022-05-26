class Tag < ApplicationRecord
  belongs_to :user
  # Twitterにおけるハッシュタグの最大文字数は100が上限のため
  validates :name, presence: true, length: { maximum: 100 }, uniqueness: { scope: :user_id }
  # TODO CRUDの実装
end

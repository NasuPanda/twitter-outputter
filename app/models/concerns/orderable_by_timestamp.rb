# タイムスタンプ順に並び替えるためのユーティリティモジュール
module OrderableByTimestamp
  extend ActiveSupport::Concern

  included do
    scope :by_earliest_created, -> { order(created_at: :asc) }
    scope :by_recently_created, -> { order(created_at: :desc) }
    scope :by_earliest_updated, -> { order(updated_at: :asc) }
    scope :by_recently_updated, -> { order(updated_at: :desc) }
    # post_at attribute で並び替える
    scope :by_earliest_posted, -> { order(post_at: :asc) }
    scope :by_recently_posted, -> { order(post_at: :desc) }
  end
end
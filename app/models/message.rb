class Message < ActiveRecord::Base
  belongs_to :user
  belongs_to :room, touch: true

  validates :text, presence: true
end

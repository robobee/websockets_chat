class Room < ActiveRecord::Base
  has_many :users, through: :messages
  has_many :messages, dependent: :destroy
  belongs_to :creator, class_name: "User", foreign_key: "user_id"

  validates :name, presence: true
  validates :user_id, presence: true

  before_create do
    self.name = self.name.capitalize
  end
end

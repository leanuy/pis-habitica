# frozen_string_literal: true

class UserHomeSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :nickname, :email
  has_many :individual_habits
  has_one :character do |object|
    object.user_characters.find_by_is_alive(true).character
  end
end
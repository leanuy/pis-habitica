# frozen_string_literal: true

class GroupHabitSerializer
  include FastJsonapi::ObjectSerializer

  set_id :id
  attributes :name, :description, :difficulty, :privacy, :frequency, :negative
  attribute :count_track do |object, params|
    time_zone = params.nil? || params['time_zone'].nil? ? UTC_HOURS : params['time_zone']
    now = Time.now.in_time_zone(time_zone.hours).to_date
    if object.instance_of? GroupHabit
      object.track_group_habits.select { |track| track.date.in_time_zone(time_zone.hours).to_date == now }.length
    else
      object.track_individual_habits.select { |track| track.date.in_time_zone(time_zone.hours).to_date == now }.length
    end
  end
  has_many :types
end

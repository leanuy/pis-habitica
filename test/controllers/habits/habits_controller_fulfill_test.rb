# frozen_string_literal: true

require 'test_helper'

class HabitsControllerFulfillTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create(nickname: 'Example', email: 'example@example.com', password: 'Example123')
    post '/user_token', params: {
      'auth': {
        'email': @user.email,
        'password': @user.password
      }
    }
    @user_token = JSON.parse(response.body)['jwt']

    @individual_type = IndividualType.create(user_id: @user.id, name: 'Example', description: 'Example')
    @individual_habit_to_track = IndividualHabit.create(
      user_id: @user.id,
      name: 'Example',
      description: 'Example',
      difficulty: 3,
      privacy: 1,
      frequency: 1,
      active: true
    )

    @individual_habit_has_type = IndividualHabitHasType.create(
      habit_id: @individual_habit_to_track.id,
      type_id: @individual_type.id
    )

    @individual_habit_to_track.individual_habit_has_types << @individual_habit_has_type
    @individual_type.individual_habit_has_types << @individual_habit_has_type

    # If Habit frequency is daily habit must not have been fulfilled today
    @user_fulfilled = User.create(nickname: 'Example123', email: 'example123@example.com', password: '112312312323')
    post '/user_token', params: {
      'auth': {
        'email': @user_fulfilled.email,
        'password': @user_fulfilled.password
      }
    }
    @user_fulfilled_token = JSON.parse(response.body)['jwt']

    # Characters
    @char = Character.create(name: 'Mago', description: I18n.t('mage_description'))
    req = {
      'data': {
        'id': @char.id.to_s,
        'type': 'characters',
        'attributes': { 'name': 'Mago', 'description': I18n.t('mage_description') }
      },
      'included': [{ 'type': 'date', 'attributes': { 'date': '2018-09-07T12:00:00Z' } }]
    }
    post '/me/characters', headers: {
      'Authorization': 'Bearer ' + @user_fulfilled_token
    }, params: req
    post '/me/characters', headers: {
      'Authorization': 'Bearer ' + @user_token
    }, params: req

    @individual_type3 = IndividualType.create(user_id: @user_fulfilled.id, name: 'Example', description: 'Example')

    @individual_habit_already_tracked = IndividualHabit.create(
      user_id: @user_fulfilled.id,
      name: 'Example',
      description: 'Example',
      difficulty: 3,
      privacy: 1,
      frequency: 2,
      active: true
    )

    @individual_habit_has_type3 = IndividualHabitHasType.create(
      habit_id: @individual_habit_already_tracked.id,
      type_id: @individual_type3.id
    )
    @individual_habit_already_tracked.individual_habit_has_types << @individual_habit_has_type3
    @individual_type3.individual_habit_has_types << @individual_habit_has_type3

    @track_individual_habit3 = TrackIndividualHabit.create(
      habit_id: @individual_habit_already_tracked.id,
      date: Time.zone.now
    )
  end

  test 'should be valid' do
    assert @user.valid?
    assert @user_fulfilled.valid?

    assert @individual_type.valid?
    assert @individual_habit_to_track.valid?
    assert @individual_habit_has_type.valid?

    assert @individual_type3.valid?
    assert @individual_habit_already_tracked.valid?
    assert @individual_habit_has_type3.valid?
    assert @track_individual_habit3.valid?
  end
  test 'CumplirHabito: should track habit' do
    post '/habits/' + @individual_habit_to_track.id.to_s + '/fulfill', headers: {
      'Authorization': 'Bearer ' + @user_token
    }, params: { 'data': { 'type': 'date', 'attributes': { 'date': '2018-09-05T21:39:27+00:00' } } }
    expected = {
      'data': {
        'id': JSON.parse(response.body)['data']['id'],
        'type': 'track',
        'attributes': {
          'max_health': User.find_by_id(@user.id).max_health,
          'health_difference': 0, # Is at full health
          'max_experience': User.find_by_id(@user.id).max_experience,
          'experience_difference': @individual_habit_to_track.increment_of_experience(@user)
        },
        'relationships': {
          'individual_habit': {
            'data': {
              'id': @individual_habit_to_track.id.to_s,
              'type': 'individual_habit'
            }
          }
        }
      }
    }
    assert expected.to_json == response.body
    assert_equal 201, status # Created
  end
  test 'CumplirHabito: habit should exist' do
    post '/habits/9090999/fulfill', headers: {
      'Authorization': 'Bearer ' + @user_token
    }, params: {
      'data': {
        'type': 'date',
        'attributes': {
          'date': '2018-09-05T21:39:27+00:00'
        }
      }
    }
    assert_equal 404, status # Not Found
  end
  test 'CumplirHabito: User should exist' do
    post '/habits/' + @individual_habit_to_track.id.to_s + '/fulfill', headers: {
      'Authorization': 'Bearer asdasd'
    }, params: {
      'data': {
        'type': 'date',
        'attributes': {
          'date': '2018-09-05T21:39:27+00:00'
        }
      }
    }
    assert_equal 401, status # Unauthorized
  end
  test 'CumplirHabito: User should have this habit' do
    post '/habits/' + @individual_habit_to_track.id.to_s + '/fulfill', headers: {
      'Authorization': 'Bearer ' + @user_fulfilled_token
    }, params: {
      'data': {
        'type': 'date',
        'attributes': {
          'date': '2018-09-05T21:39:27+00:00'
        }
      }
    }
    assert_equal 403, status # Forbbiden
  end
  test 'CumplirHabito: If Habit frequency is daily habit must not have been fulfilled today' do
    post '/habits/' + @individual_habit_already_tracked.id.to_s + '/fulfill', headers: {
      'Authorization': 'Bearer ' + @user_fulfilled_token
    }, params: {
      'data': {
        'type': 'date',
        'attributes': {
          'date': Time.zone.now.iso8601
        }
      }
    }
    assert_equal 409, status # :conflict
  end
  test 'CumplirHabito: Date should be in ISO 8601' do
    post '/habits/' + @individual_habit_to_track.id.to_s + '/fulfill', headers: {
      'Authorization': 'Bearer ' + @user_token
    }, params: {
      'data': {
        'type': 'date',
        'attributes': {
          'date': Time.now.rfc2822
        }
      }
    }
    assert_equal 400, status # :bad_request
  end
  test 'CumplirHabito: Habit should be active' do
    @individual_habit_to_track.active = false
    @individual_habit_to_track.save
    post '/habits/' + @individual_habit_to_track.id.to_s + '/fulfill', headers: {
      'Authorization': 'Bearer ' + @user_token
    }, params: {
      'data': {
        'type': 'date',
        'attributes': {
          'date': '2018-09-05T21:39:27+00:00'
        }
      }
    }
    assert_equal 404, status # Not Found
  end
  test 'CumplirHabito: should have correct Format' do
    post '/habits/' + @individual_habit_to_track.id.to_s + '/fulfill', headers: {
      'Authorization': 'Bearer ' + @user_token
    }, params: {
      'data': {
        'type': 'date',
        'attributes': {
          'asdasdsad': '2018-09-05T21:39:27+00:00'
        }
      }
    }
    assert_equal 400, status # Bad Request
  end
  test 'undo_habit without alive character' do
    character = User.find(@user.id).user_characters.find_by(is_alive: true)
    character.update_column(:is_alive, false)

    post '/habits/' + @individual_habit_to_track.id.to_s + '/fulfill', headers: {
      'Authorization': 'Bearer ' + @user_token
    }, params: { 'data': { 'type': 'date', 'attributes': { 'date': '2018-09-05T21:39:27+00:00' } } }

    expected = { "errors":
      [
        { "status": 404, "title": 'Not found', "message": 'This user has not created a character yet' }
      ] }
    assert expected.to_json == response.body
    assert_equal 404, status # Accepted
  end
end

# frozen_string_literal: true

require 'test_helper'

class UsersViewOtherPerfilControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create(nickname: 'Example', email: 'example@example.com', password: 'Example123')
    post '/user_token', params: {
      'auth': {
        'email': @user.email,
        "password": @user.password
      }
    }
    @user_token = JSON.parse(response.body)['jwt']

    @user1 = User.create(nickname: 'Example2', email: 'example2@example.com', password: 'Example123')
    post '/user_token', params: {
      'auth': {
        'email': @user1.email,
        "password": @user1.password
      }
    }
    @user1_token = JSON.parse(response.body)['jwt']

    @user2 = User.create(nickname: 'Example3', email: 'example3@example.com', password: 'Example123')
    post '/user_token', params: {
      'auth': {
        'email': @user2.email,
        'password': @user2.password
      }
    }
    @user2_token = JSON.parse(response.body)['jwt']

    @user3 = User.create(nickname: 'Ozuna', email: 'latino@negritojosclaro.com', password: 'dontcare')
    @user4 = User.create(nickname: 'barack', email: 'notpresidentanymore@usa.com', password: 'dontcare23')
    @user5 = User.create(nickname: 'aaaaabaracaaaaa', email: 'notpresidentanymore1@usa.com', password: 'dontcare1')

    ### friends
    @friendship = Friendship.create(user_id: @user2.id, friend_id: @user1.id)

    ### Characters creation
    @character = Character.create(name: 'Humano',
                                  description: 'Descripcion humano')
    @character1 = Character.create(name: 'Brujo',
                                   description: 'Descripcion brujo')

    ### Parameters for requests
    @parameters = { "data": { "id": @character.id.to_s,
                              "type": 'characters',
                              "attributes": { "name": 'Mago',
                                              "description": 'Una descripcion de mago' } },
                    "included": [{ "type": 'date',
                                   "attributes": { "date": '2018-09-07T12:00:00Z' } }] }
    @parameters2 = { "data": { "id": @character1.id.to_s,
                               "type": 'characters',
                               "attributes": { "name": 'Mago',
                                               "description": 'Una descripcion de mago' } },
                     "included": [{ "type": 'date',
                                    "attributes": { "date": '2018-09-07T12:00:00Z' } }] }

    # Add character to user
    @user_character = UserCharacter.create(user_id: @user1.id,
                                           character_id: @character.id,
                                           creation_date: '2018-09-07T12:00:00Z',
                                           is_alive: true)

    @user1.user_characters << @user_character

    # Add habits to user
    @individual_habit = IndividualHabit.create(
      user_id: @user1.id,
      name: 'Example',
      description: 'Example desc',
      difficulty: 3,
      privacy: 1,
      frequency: 1,
      active: true
    )

    @individual_habit2 = IndividualHabit.create(
      user_id: @user1.id,
      name: 'Example2',
      description: 'Example2 desc',
      difficulty: 2,
      privacy: 2,
      frequency: 2,
      active: true
    )

    @individual_habit3 = IndividualHabit.create(
      user_id: @user1.id,
      name: 'Example3',
      description: 'Example3 desc',
      difficulty: 2,
      privacy: 3,
      frequency: 2,
      active: true
    )
    @individual_type = IndividualType.create(user_id: @user1.id, name: 'Example_seed', description: 'Example_seed')
    @habit_type = IndividualHabitHasType.create(habit_id: @individual_habit.id, type_id: @individual_type.id)

    @user1.individual_types << @individual_type
    @individual_habit.individual_habit_has_types << @habit_type
    @individual_habit2.individual_habit_has_types << @habit_type
    @individual_habit3.individual_habit_has_types << @habit_type
    @user1.individual_habits << @individual_habit
    @user1.individual_habits << @individual_habit2
    @user1.individual_habits << @individual_habit3

    @no_friend = UserSerializer.new(@user1, params: { current_user: @user }).serialized_json
    @friend = UserSerializer.new(@user1, params: { current_user: @user2 }).serialized_json
  end
  test 'Ver Perfil de otro usuario: friend all OK ' do
    result = get '/users/' + @user1.id.to_s, headers: { 'Authorization': 'Bearer ' + @user2_token }
    assert result == 200
    assert_equal response.body, @friend
  end

  test 'Ver Perfil de otro usuario: no friend all OK ' do
    result = get '/users/' + @user1.id.to_s, headers: { 'Authorization': 'Bearer ' + @user_token }
    assert result == 200
    assert_equal response.body, @no_friend
  end

  test 'Ver Perfil de otro usuario: user not found' do
    result = get '/users/123', headers: { 'Authorization': 'Bearer ' + @user2_token }
    assert result == 404
  end

  test 'Ver Perfil de otro usuario: dont attach Authorization token' do
    result = get '/users/123'
    assert result == 401
  end
end

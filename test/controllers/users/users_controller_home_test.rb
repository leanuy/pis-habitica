# frozen_string_literal: true

require 'test_helper'

class UsersHomeControllerTest < ActionDispatch::IntegrationTest
  def setup
    # User
    @user = User.create(nickname: 'Example', email: 'example@example.com', password: 'Example123')
    post '/user_token', params: {
      'auth': {
        'email': @user.email,
        "password": @user.password
      }
    }
    @user_token = JSON.parse(response.body)['jwt']

    # Add character to user
    @character = Character.create(name: 'Humano', description: 'Descripcion humano')
    @user_character = UserCharacter.create(user_id: @user.id,
                                           character_id: @character.id,
                                           creation_date: '2018-09-07T12:00:00Z',
                                           is_alive: true)

    @user.user_characters << @user_character

    # Add habit to user
    @individual_habit = IndividualHabit.create(
      user_id: @user.id,
      name: 'Correr',
      description: 'Correr seguido',
      difficulty: 3,
      privacy: 2,
      frequency: 2
    )

    @individual_type = IndividualType.create(user_id: @user.id, name: 'Ejercicio', description: 'Ejercicio seguido')
    @habit_type = IndividualHabitHasType.create(habit_id: @individual_habit.id, type_id: @individual_type.id)

    # User1
    @user1 = User.create(nickname: 'Example2', email: 'example2@example.com', password: 'Example123')
    post '/user_token', params: {
      'auth': {
        'email': @user1.email,
        "password": @user1.password
      }
    }
    @user1_token = JSON.parse(response.body)['jwt']

    @character1 = Character.create(name: 'Brujo',
                                   description: 'Descripcion brujo')

    # Add character to user1
    @user_character1 = UserCharacter.create(user_id: @user1.id,
                                            character_id: @character1.id,
                                            creation_date: '2018-09-07T12:00:00Z',
                                            is_alive: true)

    # Add habits to user
    @individual_habit1 = IndividualHabit.create(
      user_id: @user1.id,
      name: 'Example',
      description: 'Example desc',
      difficulty: 3,
      privacy: 1,
      frequency: 1
    )

    @individual_habit2 = IndividualHabit.create(
      user_id: @user1.id,
      name: 'Example2',
      description: 'Example2 desc',
      difficulty: 2,
      privacy: 2,
      frequency: 2
    )
    @individual_type1 = IndividualType.create(user_id: @user1.id, name: 'Example_seed', description: 'Example_seed')
    @habit_type1 = IndividualHabitHasType.create(habit_id: @individual_habit1.id, type_id: @individual_type1.id)

    # Has user3 as friend  - relationship created later

    # User 2
    @user2 = User.create(nickname: 'Example3', email: 'example3@example.com', password: 'Example123')
    post '/user_token', params: {
      'auth': {
        'email': @user2.email,
        'password': @user2.password
      }
    }
    @user2_token = JSON.parse(response.body)['jwt']

    # User 3
    @user3 = User.create(nickname: 'Ozuna', email: 'latino@negritojosclaro.com', password: 'dontcare')
    post '/user_token', params: {
      'auth': {
        'email': @user3.email,
        'password': @user3.password
      }
    }
    @user3_token = JSON.parse(response.body)['jwt']

    # Add character to user3
    @user_character3 = UserCharacter.create(user_id: @user3.id,
                                            character_id: @character.id,
                                            creation_date: '2018-09-07T12:00:00Z',
                                            is_alive: true)

    # Add notification to user1 - friendship request from user3 to user1
    @req1 = Request.new
    @req1.user_id = @user3.id
    @req1.receiver_id = @user1.id
    @req1.save

    @fr1 = FriendRequestNotification.new
    @fr1.user_id = @user1.id
    @fr1.request_id = @req1.id
    @fr1.seen = false
    @fr1.save

    # User1 and User3 are now friends
    post '/me/friends/', headers: {
      'Authorization': 'Bearer ' + @user1_token
    }, params: {
      'data': {
        'id': @req1.id,
        'type': 'request',
        'relationships': { 'user': { 'data': { 'id': @user3.id, 'type': 'user' } } }
      }
    }

    # Add notification to user3 - friendship accepted from user1 to user3
    @not = FriendshipNotification.new
    @not.sender_id = @user1.id
    @not.user_id = @user3.id
    @not.seen = false
    @not.save

    # Add another notification to user3 - friendship request from user2 to user3
    @req2 = Request.new
    @req2.user_id = @user2.id
    @req2.receiver_id = @user3.id
    @req2.save

    @fr2 = FriendRequestNotification.new
    @fr2.user_id = @user3.id
    @fr2.request_id = @req2.id
    @fr2.seen = false
    @fr2.save

    # User 4
    @user4 = User.create(nickname: 'barack', email: 'notpresidentanymore@usa.com', password: 'dontcare23')
    post '/user_token', params: {
      'auth': {
        'email': @user4.email,
        "password": @user4.password
      }
    }
    @user4_token = JSON.parse(response.body)['jwt']

    # Add character to user4
    @user_character4 = UserCharacter.create(user_id: @user4.id,
                                            character_id: @character1.id,
                                            creation_date: '2018-09-07T12:00:00Z',
                                            is_alive: true)

    # Add seen notification to user4 - friendship request from user2 to user4
    @req3 = Request.new
    @req3.user_id = @user2.id
    @req3.receiver_id = @user4.id
    @req3.save

    @fr3 = FriendRequestNotification.new
    @fr3.user_id = @user4.id
    @fr3.request_id = @req3.id
    @fr3.seen = true
    @fr3.save

    # Add friend to user4
    @user4.friendships.create(friend_id: @user2)

    # groups for testing
    @group = Group.create(name: 'Propio', description: 'Propio description', privacy: false)
    @group1 = Group.create(name: 'Propio1', description: 'Propio1 description', privacy: false)
    Membership.create(user_id: @user.id, group_id: @group.id, admin: false)
    Membership.create(user_id: @user.id, group_id: @group1.id, admin: true)
    Membership.create(user_id: @user1.id, group_id: @group.id, admin: true)
  end

  # Tests /me - Ir a home
  test 'Ir a home: user1 with all data' do
    get '/me', headers: { 'Authorization': 'Bearer ' + @user1_token.to_s }
    assert_equal 200, status
    body = JSON.parse(response.body)
    assert body['data']['attributes']['nickname'] == @user1.nickname
    assert body['data']['attributes']['has_notifications'].zero?
    assert body['data']['relationships']['character'].length == 1
  end

  # Tests /me - Ir a home
  test 'Ir a home: user1 with created but dead character' do
    @user1.update_column(:health, 0)
    @user1.death
    get '/me', headers: { 'Authorization': 'Bearer ' + @user1_token.to_s }
    assert_equal 200, status
    body = JSON.parse(response.body)
    assert body['data']['attributes']['nickname'] == @user1.nickname
    assert body['data']['attributes']['has_notifications'].zero?
    assert body['data']['attributes']['is_dead']
    assert body['data']['relationships']['character']['data'].nil?
  end

  test 'Ir a home: user2 with no created character' do
    get '/me', headers: { 'Authorization': 'Bearer ' + @user2_token.to_s }
    assert_equal 404, status
    body = JSON.parse(response.body)
    assert body['errors'][0]['message'] == 'This user has not created a character yet'
  end

  test 'Ir a home: user4 with seen notifications' do
    get '/me', headers: { 'Authorization': 'Bearer ' + @user4_token.to_s }
    assert_equal 200, status
    body = JSON.parse(response.body)
    assert body['data']['attributes']['has_notifications'].zero?
  end

  test 'Ir a home: user3 with notifications' do
    get '/me', headers: { 'Authorization': 'Bearer ' + @user3_token.to_s }
    assert_equal 200, status
    body = JSON.parse(response.body)
    assert body['data']['attributes']['has_notifications'] == 3
  end
end

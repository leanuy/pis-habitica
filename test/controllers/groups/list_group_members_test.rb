# frozen_string_literal: true

require 'test_helper'

class ListGroupMembersTest < ActionDispatch::IntegrationTest
  def setup
    # Create users
    @user = User.create(nickname: 'Admin', email: 'example@example.com', password: 'Example123')
    post '/user_token', params: {
      'auth': {
        'email': @user.email,
        "password": @user.password
      }
    }
    @user_token = JSON.parse(response.body)['jwt']

    @user1 = User.create(nickname: 'Germo', email: 'example1@example.com', password: 'Example123')
    post '/user_token', params: {
      'auth': {
        'email': @user1.email,
        "password": @user1.password
      }
    }
    @user1_token = JSON.parse(response.body)['jwt']

    @user2 = User.create(nickname: 'Feli', email: 'example2@example.com', password: 'Example123')
    post '/user_token', params: {
      'auth': {
        'email': @user2.email,
        "password": @user2.password
      }
    }
    @user2_token = JSON.parse(response.body)['jwt']

    @user3 = User.create(nickname: 'Example3', email: 'example3@example.com', password: 'Example123')
    post '/user_token', params: {
      'auth': {
        'email': @user3.email,
        "password": @user3.password
      }
    }
    @user3_token = JSON.parse(response.body)['jwt']

    # Characters
    @character = Character.create(name: 'Humano', description: 'Descripcion humano')
    @character1 = Character.create(name: 'Brujo', description: 'Descripcion brujo')
    @user_character = UserCharacter.create(user_id: @user.id,
                                           character_id: @character.id,
                                           creation_date: '2018-09-07T12:00:00Z',
                                           is_alive: true)
    @user_character1 = UserCharacter.create(user_id: @user1.id,
                                            character_id: @character1.id,
                                            creation_date: '2018-09-07T12:00:00Z',
                                            is_alive: true)
    @user_character2 = UserCharacter.create(user_id: @user2.id,
                                            character_id: @character1.id,
                                            creation_date: '2018-09-07T12:00:00Z',
                                            is_alive: true)
    @user_character3 = UserCharacter.create(user_id: @user3.id,
                                            character_id: @character1.id,
                                            creation_date: '2018-09-07T12:00:00Z',
                                            is_alive: true)

    # Create groups:

    # public group
    @group = Group.create(name: 'Grupito prueba', description: 'Grupito prueba desc', privacy: false)
    @group3 = Group.create(name: 'Grupito prueba3', description: 'Grupito prueba desc', privacy: false)

    # private group
    @group1 = Group.create(name: 'Grupito prueba1', description: 'Grupito prueba desc', privacy: true)
    @group2 = Group.create(name: 'Grupito prueba2', description: 'Grupito prueba desc', privacy: true)

    # Add admins
    Membership.create(user_id: @user.id, admin: true, group_id: @group.id)
    Membership.create(user_id: @user.id, admin: true, group_id: @group1.id)
    Membership.create(user_id: @user1.id, admin: true, group_id: @group3.id)

    # Add members (not admins)
    Membership.create(user_id: @user1.id, admin: false, group_id: @group.id)
    Membership.create(user_id: @user2.id, admin: false, group_id: @group.id)
    Membership.create(user_id: @user.id, admin: false, group_id: @group3.id)
    Membership.create(user_id: @user2.id, admin: false, group_id: @group3.id)
  end
  # Endpoint /me/groups/id
  test 'List my group members score order' do
    url = '/groups/' + @group.id.to_s + '/members'
    result = get url, headers: { 'Authorization': 'Bearer ' + @user_token }
    assert result == 200
    body = JSON.parse(response.body)
    assert body['data'].length == @group.users.length
  end

  test 'My group where the only member is the admin' do
    url = '/groups/' + @group1.id.to_s + '/members'
    result = get url, headers: { 'Authorization': 'Bearer ' + @user_token }
    assert result == 200
    body = JSON.parse(response.body)
    assert body['data'].length == @group1.users.length
  end

  # Endpoint /users/user_id/groups/id
  test 'List other users group members and admin alphabetically' do
    url = '/groups/' + @group3.id.to_s + '/members'
    result = get url, headers: { 'Authorization': 'Bearer ' + @user3_token }
    assert result == 200
    body = JSON.parse(response.body)
    assert body['data'].length == @group3.users.length
  end
end

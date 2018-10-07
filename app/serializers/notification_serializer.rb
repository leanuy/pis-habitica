# frozen_string_literal: true

class NotificationSerializer
  include FastJsonapi::ObjectSerializer
  attributes :type, :created_at, :seen

  belongs_to :sender, record_type: :user, id_method_name: :sender_id, serializer: :user,
                      if: proc { |record| record.type.eql? 'FriendshipNotification' }, params: { current_user: :sender }

  belongs_to :request, record_type: :request,
                       serializer: :request, if: proc { |record| record.type.eql? 'FriendRequestNotification' }

  belongs_to :request_sender, record_type: :user, id_method_name: :user_id, serializer: :user,
                              if: proc { |record| record.type.eql? 'FriendRequestNotification' },
                              params: { current_user: :sender } do |object|
                                object.request.user
                              end
end

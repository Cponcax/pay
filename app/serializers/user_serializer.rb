class UserSerializer < ActiveModel::Serializer
  attributes  :active,
              :birthday,
              :nationality,
              :last_name,
              :first_name,
              :title,
              :identification_type,
              :identification_value,
              :uuid
  has_one :token , serializer: AccessTokenSerializer

  def tokens
    object.token
  end
end

class AccessTokenSerializer < ActiveModel::Serializer
  attributes :access_token

  def access_token
    object.token
  end

  def token_type
    'bearer'
  end

  def scope
    'write'
  end

  def created_at
    object.created_at.to_i
  end
end

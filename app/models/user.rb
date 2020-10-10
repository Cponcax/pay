class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :confirmable,
          :recoverable, :rememberable, :trackable, :validatable, :authentication_keys => [:login]

  validates_presence_of :email
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
  # validates_format_of :first_name, :last_name,  :with => /^[^0-9`!@#\$%\^&*+_=]+$/, :multiline => true 

  before_create :generate_uuid
  before_update :formate_birthday

  after_create :create_access_token

  has_many :tokens, class_name: 'Doorkeeper::AccessToken',
            foreign_key: :resource_owner_id

  has_one :token, -> { order 'created_at DESC' },
          class_name: 'Doorkeeper::AccessToken', foreign_key: :resource_owner_id

  has_many :stores, foreign_key: :user_id, dependent: :destroy

  def create_access_token
   @request ||= Doorkeeper::OAuth::PasswordAccessTokenRequest.new(
        Doorkeeper.configuration,
        nil,
        self,
        { grant_type: "password", scope: "write" })
    @response = @request.authorize
    @token = @response.token
  end

  def alive_tokens
    tokens.order(created_at: :asc).select {|token| !token.revoked? }
  end

  def full_name
    first_name+' '+last_name
  end

  private

  def generate_uuid
    begin
      self.uuid  = 'us_' + SecureRandom.hex(15)
    end while !User.where(uuid: self.uuid).empty?
  end

  def formate_birthday
    unless   self.birthday.nil?
      self.birthday = self.birthday.gsub("/", "")
    end
  end
end

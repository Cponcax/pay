class ApplicationMailer < ActionMailer::Base
  default from: 'support@datapaga.com'
  layout 'mailer'

  def notify_of_received_doc(user)
    @user = user
    mail(to: @user.email, subject: 'DataPaga support')
  end

  def notify_cards_created(cards, user_id)
    @cards = cards
    @user = User.find(user_id)
    mail(to: @user.email, subject: 'DataPaga support')
  end

end

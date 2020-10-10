class CreateMultipleCards
  include Sidekiq::Worker

  def perform(user_id, store_uuid, number_cards_requested)
    cards = []
    number_cards_requested.times do |t|
      card = ::LamdaServices::MultipleCards.new(user_id, store_uuid).call
      puts "==============REQUEST=============="
      if card.succeed?
        cards <<  card.response.response
      end
    end
    puts "==============CARDS==============="
    puts cards
    unless cards.blank?
      MultipleCardsMailer.notify_cards_created(cards, user_id).deliver_now
    end
  end
end

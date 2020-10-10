class CardWorker
  include Sidekiq::Worker

  def perform(id)
    user = User.find(id)
    arguments= {
      user: user,
      store: user.stores.last,
      card: user.stores.last.cards.last
    }
    ::Cards::CardInfo.new(arguments).call
    ::Cards::CardBalance.new(arguments).call
  end

end

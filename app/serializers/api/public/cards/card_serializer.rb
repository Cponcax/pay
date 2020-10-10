module Api
  module Public
    module Cards
      class CardSerializer < ActiveModel::Serializer
        attributes  :uuid,
                    :status,
                    :expiration_date,
                    :emboss_name,
                    :card_number,
                    :order_status,
                    :card_id,
                    :card_default,
                    :balance,
                    :description,
                    :type_of_transfer,
                    :days,
                    :suspended
      end
    end
  end
end

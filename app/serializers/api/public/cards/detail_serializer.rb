module Api
  module Public
    module Cards
      class DetailSerializer < ActiveModel::Serializer
        attributes  :uuid,
                    :status,
                    :balance
      end
    end
  end
end

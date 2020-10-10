class DetailStoreSerializer < ActiveModel::Serializer
  attributes  :name,
              :uuid,
              :description,
              :phone,
              :phone_country_code,
              :address_one,
              :address_two,
              :city,
              :state,
              :country,
              :client_id,
              :postalcode,
              :web_site_url,
              :api_key,
              :api_secret,
              :api_secret_encoded

end

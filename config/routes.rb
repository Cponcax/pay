Rails.application.routes.draw do
  use_doorkeeper
  scope module: :api, defaults: { format: :json } do
    scope module: :datapaga do
      scope module: :dashboard do
        namespace  :v1 do
          devise_for :users, only: [:registrations, :confirmations, :passwords],
                                    controllers: {registrations: 'api/datapaga/dashboard/v1/devise/registrations',
                                    confirmations: 'api/datapaga/dashboard/v1/devise/confirmations'}

          namespace :stores do
            post '/create', to: 'stores#create'
            get '/store_list', to:'stores#index'
            get '/store_detail/:uuid', to: 'stores#show'
            post '/new_store/:uuid', to: 'stores#new_store'
            # get '/:store_uuid/card_info/:card_uuid', to: 'cards#card_info'
            post '/suspend/:uuid', to: 'stores#suspend'
          end

          post 'store/:store_uuid/documents', to: 'documents#create'

          get 'store/balance/:store_uuid', to: 'merchants#balance'


          namespace :cards do
            get '/card_detail/:store_uuid/:uuid', to: 'cards#show'
            post 'cards/:store_uuid', to: 'cards#create'
            get '/card_list/:store_uuid', to: 'cards#index'
            get '/card_info/:card_uuid/:uuid_store', to: 'cards#card_info'

            get '/balance/:store_uuid/card/:card_uuid', to: 'cards#balance'

            get '/selected_card/:store_uuid', to: 'cards#selected_card'
            post '/create_multiple_cards/:store_uuid', to: 'cards#create_multiple_cards'
            post 'programmed/:store_uuid', to: 'cards#programmed'
            post 'transfer_by_card/:store_uuid', to: 'cards#transfer_by_card'
            post '/set_card_default/:store_uuid', to: 'cards#set_card_default'

            get '/:store_uuid/card_info/:card_uuid', to: 'cards#card_info'
            post '/suspend/:card_uuid', to: 'cards#suspend'
           end

          namespace :merchants do

          end

          resources :users, only: [:create] do
            collection do
              post 'me',          to: 'users#update'
              delete 'me',       to: 'users#destroy'
              post 'login', to: 'users#login'
              get 'desactive', to: 'users#desactive_user'
              get 'active', to: 'users#active_user'
              post 'update_password'
              post 'forgot_password'
              post 'update_password_forgot'
              get 'me', to: 'users#me'
            end
          end

          resources :account_movements, only: [:create] do
            collection do
              get "/:store_uuid/history/",to: 'account_movements#index'
              get "/:store_uuid/history/:account_movement_id", to: 'account_movements#show'
            end
          end

          resources :transaction_card_histories, only: [:create]
          get '/filters/:store_uuid', to: 'filters#filter_account_movements'
          get '/clients/:store_uuid', to: 'filters#filters_clients'
          get '/charts/:store_uuid', to: 'charts#filters_by_range'

          get '/chart_home/:store_uuid', to: 'charts#last_seven_days'

          resources :alerts, only: [:index]
        end
      end

      scope module: :public do
        namespace  :v1 do
          namespace :account_movements do
            post '/charge', to: 'account_movements#charge'
            post "/transaction_history", to: 'account_movements#index'
            post "/transaction_history/:uuid", to: 'account_movements#show'
            post '/refund', to: 'account_movements#refund'
          end
          namespace :cards do
            post '/list/', to: 'cards#index'
            post '/detail/:uuid', to: 'cards#show'
          end
          namespace :stores do
            post '/balance', to: 'stores#balance'
            post '/transaction_card', to: 'stores#card_transfer'
          end
        end
      end
    end
  end
end

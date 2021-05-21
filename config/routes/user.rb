resources :users, only: [:show] do
  resources :direct_messages, only: [:new, :create, :show]
end

resources :oecd_representative_requests, only: [:new, :create]

namespace :oecd_representative, path: "oecd-representative" do
  root to: "dashboard#index"
  namespace :legislation, path: :engagement do
    resources :processes do
      resources :questions
      resources :proposals do
        member { patch :toggle_selection }
      end
      resources :draft_versions
      resources :milestones
      resources :progress_bars, except: :show
      resource :homepage, only: [:edit, :update]
    end
  end

  resources :comments do
    get :to_export, on: :collection
    get "export/:process_id", on: :collection, to: "comments#export", as: :export,
        defaults: { format: :csv }
  end

  namespace :moderation do
    resources :comments, only: :index do
      put :hide, on: :member
      put :moderate, on: :collection
    end

    resources :proposals, only: :index do
      put :hide, on: :member
      put :moderate, on: :collection
    end
  end
end

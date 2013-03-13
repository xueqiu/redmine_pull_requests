resources :projects do
  resources :pulls do
    member do
      put :comment, :update, :review, :close, :merge, :cancel
    end
  end
end
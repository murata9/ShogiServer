Rails.application.routes.draw do
  #追加
  #チャット
  get  'chats/:id/chat_get' => 'chats#GetChat'
  post 'chats/chat_post'    => 'chats#PostChat'
  get  'plays/:id/chat_get' => 'plays#GetChat'
  post 'plays/chat_post'    => 'plays#PostChat'
  #部屋検索
  get 'plays/GetRoom'      => 'plays#GetRoom'
  post 'plays/SearchRoomForUserName' => 'plays#SearchRoomForUserName'

  post 'users/login'      => 'users#login'
  post 'users/logout'     => 'users#logout'
  get  'plays/:id/state'  => 'plays#state'
  get  'plays/:id/users'  => 'plays#users'
  get  'plays/:id'        => 'plays#show'
  get  'plays/:id/winner' => 'plays#get_winner'
  get  'plays/:id/pieces' => 'plays#get_pieces'
  post 'plays/update'     => 'plays#update'

  # debug用
  get 'plays/end/:id' => 'plays#end'
  # test用
  get 'users/test'    => 'users#test'
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end

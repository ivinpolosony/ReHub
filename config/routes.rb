Rails.application.routes.draw do

  resources :profiles

  devise_for :users
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'file_managers#home'
  get '/tf' => 'file_managers#index'
  
  get '/cosine' => 'file_managers#sim'
  post '/cosine' => 'file_managers#sim' 
  
  post '/bubble_chart' => 'file_managers#bubble_chart'

 # get 'bubble_chart' => 'file_managers#bubble_chart'
  #post 'bubble_chart' => 'file_managers#bubble_chart'
  get '/new' => 'file_managers#new'
  post '/new' => 'file_managers#new'


  get '/search' => 'search#index'
  post '/search' => 'search#index'

  get "load" => 'upload#load'
  get '/bubble_chart' => 'upload#bubble_chart'
  
  get '/upload' => 'upload#index'
  post '/upload' => 'upload#index'

  
  post '/upload/uploadFile' => 'upload#uploadFile'

  get '/search/read' => 'search#read'

  get '/length' => 'upload#length' 

get '/signedinuserprofile' => 'profiles#signedinuserprofile'
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

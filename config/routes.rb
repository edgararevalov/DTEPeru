Rails.application.routes.draw do
  get 'upload/index'
  get 'upload/new'
  post 'upload/uploadFile'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end

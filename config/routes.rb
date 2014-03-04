RailsImageBrowser::Application.routes.draw do
  root :to => 'slide_file#requests'
  #get '/preview' => 'slide_file#preview'
  get '*path' => 'slide_file#requests'
end

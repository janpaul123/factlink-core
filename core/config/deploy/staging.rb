server 'staging.factlink.com', :app, :web, :primary => true

set :full_url, 'https://staging.factlink.com'

set :deploy_env, 'staging'
set :rails_env,  'staging' # Also used by capistrano for some specific tasks

role :web, "staging.factlink.com"                          # Your HTTP server, Apache/etc
role :app, "staging.factlink.com"                          # This may be the same as your `Web` server
role :db,  "staging.factlink.com", :primary => true # This is where Rails migrations will run
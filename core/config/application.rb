require File.expand_path('../boot', __FILE__)

require "action_controller/railtie"
require "action_mailer/railtie"
require "active_resource/railtie"

Mime::Type.register "image/png", :png
Mime::Type.register "image/gif", :gif


# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)



if ['test', 'development'].include? Rails.env
  require 'metric_fu'
  
  require 'simplecov'
  require 'simplecov-rcov-text'
  
  class SimpleCov::Formatter::MergedFormatter
      def format(result)
         SimpleCov::Formatter::HTMLFormatter.new.format(result)
         SimpleCov::Formatter::RcovTextFormatter.new.format(result)
      end
  end
  SimpleCov.formatter = SimpleCov::Formatter::MergedFormatter
	
  MetricFu::Configuration.run do |config|  
    # config.metrics -= [:churn]  
    # config.metrics -= [:flay] 
    config.flay ={:dirs_to_flay => ['app', 'lib', 'spec'],
                  :minimum_score => 10,
                  :filetypes => ['rb'] }
    # config.metrics -= [:stats]
    # config.metrics -= [:rails_best_practices]
    # config.metrics -= [:rcov] 
    # config.rcov[:external] = 'coverage/rcov/rcov.txt'
    
    # Flog does not work with metric_fu, don't use it:
    config.metrics -= [:flog]
  
    # reek does not work (only the first three):
    config.metrics -= [:reek] 
    # config.reek = {:dirs_to_reek => ['app'] } 
  
    # roodi does not work:
    config.metrics -= [:roodi] 
    # config.roodi = { :dirs_to_roodi => ['app/**/*.rb'] } 
  end
end

module FactlinkUI
  class Application < Rails::Application
    # Auto load files in lib directory
    config.autoload_paths << "#{config.root}/lib"
    config.autoload_paths << "#{config.root}/app/classes"
    config.autoload_paths << "#{config.root}/app/ohm-models"
    config.autoload_paths << "#{config.root}/app/views"
    
    config.mongoid.logger = nil

    autoload :RelatedUsersCalculator, "#{config.root}/app/classes/related_users_calculator.rb"

    autoload :FactData, "#{config.root}/app/models/fact_data.rb"
    autoload :User, "#{config.root}/app/models/user.rb"
    
    autoload :OurOhm, "#{config.root}/app/ohm-models/our_ohm.rb"
    autoload :FactGraph, "#{config.root}/app/ohm-models/fact_graph.rb"
    autoload :Basefact, "#{config.root}/app/ohm-models/basefact.rb"
    autoload :Fact, "#{config.root}/app/ohm-models/fact.rb"
    autoload :FactRelation, "#{config.root}/app/ohm-models/fact_relation.rb"
    autoload :GraphUser, "#{config.root}/app/ohm-models/graph_user.rb"
    autoload :Site, "#{config.root}/app/ohm-models/site.rb"
    autoload :Channel, "#{config.root}/app/ohm-models/channel.rb"
    
    autoload :Opinion, "#{config.root}/app/ohm-models/opinion.rb"
    
    autoload :Activity, "#{config.root}/app/ohm-models/activities.rb"
    autoload :ActivitySubject, "#{config.root}/app/ohm-models/activities.rb"
    
    [ 
      RelatedUsersCalculator,
      OurOhm, 
      Activity,
      ActivitySubject,
      FactGraph, 
      Opinion, 
      Basefact, 
      FactData, 
      Fact, 
      FactRelation, 
      GraphUser, 
      Site,
      Channel
    ]
    require "#{config.root}/lib/mustache_rails.rb"

    require "#{config.root}/app/views/facts/_fact_wheel.rb"
    require "#{config.root}/app/views/facts/_fact_bubble.rb"
    require "#{config.root}/app/views/facts/_channel_listing.rb"
    
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Use Mongoid as ORM
    config.generators do |g|
      g.orm             :mongoid
    end

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    # Error reporting
    config.middleware.use ExceptionNotifier,
      :email_prefix => "[FL##{Rails.env}] ",
      :sender_address => %{"#{Rails.env} - FL - Bug notifier" <bugs@factlink.com>},
      :exception_recipients => %w{bugs@factlink.com}

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # JavaScript files you want as :defaults (application.js is always included).
    # config.action_view.javascript_expansions[:defaults] = %w(jquery rails)

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]
    
  end
end

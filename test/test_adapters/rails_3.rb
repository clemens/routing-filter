require 'test_helper'

require "rails"
require 'rack/test'

class Subdomain
  def self.matches?(request)
    request.subdomain(1).present? && request.subdomain(1) != "www"
  end
end

module TestRailsAdapter
  include ::Rack::Test::Methods

  APP = Class.new(Rails::Application).tap do |app|
    app.config.secret_token = "3b7cd727ee24e8444053437c36cc66c4"
    app.config.session_store :cookie_store, :key => "_myapp_session"
    app.config.active_support.deprecation = :log
    app.routes.draw do
      match "/" => "rails_test/tests#index" # <= you could move this ...
      match "/foo/:id" => "rails_test/tests#show", :as => 'foo'
      constraints(Subdomain) do
        match '/', :to => 'rails_test/tests#profile', :as => :profile
      end
      # <= ... here and have other tests failing
      filter :uuid, :pagination ,:locale, :extension
    end
    app.initialize!
  end

  def app
    APP
  end

  def response
    last_response
  end
end

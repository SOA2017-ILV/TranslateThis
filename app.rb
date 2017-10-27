
# frozen_string_literal: true

require 'roda'
require 'econfig'
require_relative 'lib/init.rb'

module TranslateThis
  # Web API
  class Api < Roda
    plugin :environments
    plugin :json
    plugin :halt

    extend Econfig::Shortcut
    Econfig.env = environment.to_s
    Econfig.root = '.'

    route do |routing|
      app = Api
      config = Api.config

      # GET / request
      routing.root do
        { 'message' => "TranslateThis API v0.1 up in #{app.environment}
        Brought to you by TACO::DE" }
      end

      routing.on 'api' do
        # /api/v0.1/ branch
        routing on 'v0.1' do
          # /api/v0.1/
        end
      end
    end
  end
end

# frozen_string_literal: true

require "active_model/type"
require "active_support"
require "zeitwerk"

module Permisi
  LOADER = Zeitwerk::Loader.for_gem

  class Engine < ::Rails::Engine
    unless !Rails.env.production? || ENV['GEM_FULL_LIST'].present?
      config.after_initialize do
        Permisi::Access.call
      rescue
        nil
      end
    end
  end

  class Railtie < Rails::Railtie
    initializer 'permisi.action_controller' do
      ActiveSupport.on_load(:action_controller_base) do
        unless !Rails.env.production? || ENV['GEM_FULL_LIST'].present?
          $permisi_host = nil
          ApplicationController.include(Permisi::AccessLogging)
        end
      end
    end
  end

  class << self
    def init
      yield config if block_given?
    end

    def config
      @config ||= Config.new
    end

    def actors
      config.backend.actors
    end

    def actor(aka)
      config.backend.findsert_actor(aka)
    end

    def roles
      config.backend.roles
    end
  end
end

Permisi::LOADER.ignore("#{__dir__}/generators")
Permisi::LOADER.ignore("#{__dir__}/permisi/backend/mongoid.rb") # todo
Permisi::LOADER.setup

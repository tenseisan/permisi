# frozen_string_literal: true

module Permisi
  class Config
    class InvalidCacheStore < StandardError; end

    NULL_CACHE_STORE = ActiveSupport::Cache::NullStore.new

    attr_reader :permissions, :default_permissions
    attr_accessor :mute_pre_0_1_4_warning

    def initialize
      @permissions = ::HashWithIndifferentAccess.new
      @default_permissions = ::HashWithIndifferentAccess.new
    end

    def backend=(chosen_backend)
      chosen_backend = "::Permisi::Backend::#{chosen_backend.to_s.classify}".constantize if chosen_backend.is_a? Symbol

      @backend = chosen_backend
    rescue NameError
      raise Backend::InvalidBackend
    end

    def backend
      @backend || Backend::NullBackend
    end

    def permissions=(permissions_hash)
      permissions_hash = HashWithIndifferentAccess.new(permissions_hash)
      @default_permissions = PermissionUtil.transform_namespace(permissions_hash)
      @permissions = permissions_hash
    end

    def cache_store=(cache_store)
      raise InvalidCacheStore unless cache_store.respond_to?(:fetch)

      @cache_store = cache_store
    end

    def cache_store
      @cache_store || NULL_CACHE_STORE
    end
  end
end

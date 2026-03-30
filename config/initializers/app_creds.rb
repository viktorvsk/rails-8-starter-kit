# frozen_string_literal: true

# Polyfill for Rails 8.2 CombinedCredentials and Rails.app alias
unless Rails.respond_to?(:app)
  Rails.singleton_class.alias_method(:app, :application)
end

module CombinedCredentialsPolyfill
  class CombinedCreds
    def require(*keys)
      env_key = keys.join("__").upcase
      return ENV.fetch(env_key) if ENV.key?(env_key)

      val = Rails.application.credentials.dig(*keys)
      raise KeyError, "Key not found: #{keys.join(".")}" if val.nil?

      val
    end

    def option(*keys, default: nil)
      env_key = keys.join("__").upcase
      return ENV.fetch(env_key) if ENV.key?(env_key)

      val = Rails.application.credentials.dig(*keys)
      return val unless val.nil?

      default.respond_to?(:call) ? default.call : default
    end
  end

  def creds
    @creds ||= CombinedCreds.new
  end
end

Rails::Application.include(CombinedCredentialsPolyfill) unless Rails::Application.method_defined?(:creds)

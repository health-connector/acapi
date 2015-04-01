module Acapi
  class ConfigurationSettings
    attr_accessor :remote_broker_uri
    attr_accessor :remote_event_queue
    attr_accessor :remote_request_exchange
  end
end

class Rails::Application::Configuration < Rails::Engine::Configuration
  def acapi
    @acapi ||= ::Acapi::ConfigurationSettings.new
  end
end

module Acapi
  module Railties
    class AmqpConfigurationSettings < Rails::Railtie
      initializer "local_amqp_publisher_railtie.configure_rails_initialization" do |app|
        setting = Rails.application.config.acapi.remote_broker_uri
        if !setting
          disable_requestor
        else
          boot_requestor(setting)
        end
      end

      def disable_requestor
        Rails.logger.info "Setting 'acapi.remote_request_exchange' not provided - disabling requestor."
        ::Acapi::Requestor.disable!
      end

      def boot_requestor(uri)
        ::Acapi::LocalAmqpPublisher.boot!(uri)
      end
    end
  end
end

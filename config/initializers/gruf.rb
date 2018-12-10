require 'proto/tolymer_services_pb'

Gruf.configure do |c|
  c.logger = Rails.logger
  c.grpc_logger = Rails.logger
  c.server_binding_url = ENV.fetch('GRPC_SERVER_URL', '0.0.0.0:8000')
  c.backtrace_on_error = !Rails.env.production?
  c.use_exception_message = !Rails.env.production?
  c.interceptors.use(Gruf::Interceptors::Instrumentation::RequestLogging::Interceptor)
end

# https://guides.rubyonrails.org/initialization.html#rails-server-start
if Rails.env.development?
  console = ActiveSupport::Logger.new(STDOUT)
  console.formatter = Rails.logger.formatter
  console.level = Rails.logger.level

  unless ActiveSupport::Logger.logger_outputs_to?(Rails.logger, STDOUT)
    Rails.logger.extend(ActiveSupport::Logger.broadcast(console))
  end
end

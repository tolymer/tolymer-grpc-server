require 'proto/tolymer_services_pb'

Gruf.configure do |c|
  c.server_binding_url = ENV.fetch('GRPC_SERVER_URL', '0.0.0.0:5200')
  c.backtrace_on_error = !Rails.env.production?
  c.use_exception_message = !Rails.env.production?

  c.interceptors.use(Gruf::Interceptors::Instrumentation::RequestLogging::Interceptor, formatter: :logstash)
end

task :proto do
  sh 'grpc_tools_ruby_protoc', '--ruby_out=app/rpc', '--grpc_out=app/rpc', 'proto/tolymer.proto'
end

class HelloService < Gruf::Controllers::Base
  bind Tolymer::Hello::Service

  def greet
    Tolymer::GreetResponse.new(id: request.message.id, name: 'hello')
  end
end

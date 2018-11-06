module Tolymer
  class HelloService < Gruf::Controllers::Base
    bind Tolymer::Hello::Service

    def greet
      Tolymer::GreetResponse.new(id: 1, name: 'hello')
    end
  end
end

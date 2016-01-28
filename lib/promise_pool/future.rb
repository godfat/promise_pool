
module PromisePool
  class Future < BasicObject
    def initialize promise
      @promise = promise
    end

    def method_missing msg, *args, &block
      @promise.yield.__send__(msg, *args, &block)
    end

    def respond_to_missing? msg, *args, &block
      @promise.yield.respond_to?(msg, *args, &block)
    end
  end
end

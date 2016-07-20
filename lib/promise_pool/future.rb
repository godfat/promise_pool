
module PromisePool
  class Future < BasicObject
    def self.resolve future
      if future.kind_of?(::Array)
        future.map(&method(:resolve))

      elsif future.kind_of?(::Hash)
        future.inject({}) do |r, (k, v)|
          r[k] = resolve(v)
          r
        end

      else
        future.itself
      end
    end

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

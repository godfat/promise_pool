
module PromisePool
  class Future < BasicObject
    def initialize promise
      @promise = promise
    end

    def method_missing msg, *args, &block
      case result = @promise.yield
      when ::Exception
        ::Kernel.raise result
      else
        result.__send__(msg, *args, &block)
      end
    end
  end
end

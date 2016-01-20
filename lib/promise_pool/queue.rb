
require 'thread'

module PromisePool
  class Queue
    def initialize
      @queue = []
      @condv = ConditionVariable.new
    end

    def size
      @queue.size
    end

    def << task
      queue << task
      condv.signal
    end

    def pop mutex, timeout=60
      if queue.empty?
        condv.wait(mutex, timeout)
        queue.shift || lambda{ |_| false } # shutdown idle workers
      else
        queue.shift
      end
    end

    def clear
      queue.clear
    end

    protected
    attr_reader :queue, :condv
  end
end

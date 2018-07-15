
# reference implementation: puma
# https://github.com/puma/puma/blob/v2.7.1/lib/puma/thread_pool.rb

require 'thread'
require 'promise_pool/queue'
require 'promise_pool/task'

module PromisePool
  class ThreadPool
    attr_reader :workers
    attr_accessor :max_size, :idle_time

    def initialize max_size, idle_time=60
      @max_size  = max_size
      @idle_time = idle_time
      @queue     = Queue.new
      @mutex     = Mutex.new
      @workers   = []
      @waiting   = 0
    end

    def size
      workers.size
    end

    def queue_size
      queue.size
    end

    def defer promise_mutex, &job
      mutex.synchronize do
        task = Task.new(job, promise_mutex)
        queue << task
        spawn_worker if waiting < queue_size && workers.size < max_size
        task
      end
    end

    def trim force=false
      mutex.synchronize do
        queue << lambda{ |_| false } if force || waiting > 0
      end
    end

    # Block on shutting down, and should not add more jobs while shutting down
    def shutdown
      workers.size.times{ trim(true) }
      workers.first.join && trim(true) until workers.empty?
      mutex.synchronize{ queue.clear }
    end

    protected
    attr_reader :queue, :mutex, :condv, :waiting

    private
    def spawn_worker
      workers << Thread.new{
        Thread.current.abort_on_exception = true

        task = nil
        begin
          mutex.synchronize do
            @waiting += 1
            task = queue.pop(mutex, idle_time)
            @waiting -= 1
          end
        end while task.call(Thread.current)

        mutex.synchronize{ workers.delete(Thread.current) }
      }
    end
  end
end


require 'thread'
require 'promise_pool/future'

module PromisePool
  class Promise
    def self.claim value
      promise = new
      promise.fulfill(value)
      promise
    end

    def self.backtrace
      Thread.current[:promise_pool_backtrace] || []
    end

    # should never raise!
    def self.set_backtrace e
      e.set_backtrace((e.backtrace || caller) + backtrace)
    end

    def initialize timer=nil
      self.value = self.error = self.result = nil
      self.resolved = self.called = false

      self.k     = []
      self.timer = timer
      self.condv = ConditionVariable.new
      self.mutex = Mutex.new
    end

    # called in client thread
    def defer pool=nil
      backtrace = caller + self.class.backtrace # retain the backtrace so far
      if pool
        mutex.synchronize do
          # still timing it out if the task never processed
          timer.on_timeout{ cancel_task } if timer
          self.task = pool.defer(mutex) do
            Thread.current[:promise_pool_backtrace] = backtrace
            protected_yield{ yield }
            Thread.current[:promise_pool_backtrace] = nil
          end
        end
      else
        self.thread = Thread.new do
          Thread.current[:promise_pool_backtrace] = backtrace
          protected_yield{ yield }
        end
      end
      self
    end

    def call
      self.thread = Thread.current # set working thread
      protected_yield{ yield } # avoid any exception and do the job
    end

    def future
      Future.new(self)
    end

    # called in client thread (client.wait)
    def wait
      # it might be awaken by some other futures!
      mutex.synchronize{ condv.wait(mutex) until resolved? } unless resolved?
    end

    # called in client thread (from the future (e.g. body))
    def yield
      wait
      mutex.synchronize{ callback }
    end

    # called in requesting thread after the request is done
    def fulfill value
      mutex.synchronize{ fulfilling(value) }
    end

    # called in requesting thread if something goes wrong or timed out
    def reject error
      mutex.synchronize{ rejecting(error) }
    end

    # append your actions, which would be called when we're calling back
    def then &action
      k << action
      self
    end

    def resolved?
      resolved
    end

    protected
    attr_accessor :value, :error, :result, :resolved, :called,
                  :k, :timer, :condv, :mutex, :task, :thread

    private
    def fulfilling value
      self.value = value
      resolve
    end

    def rejecting error
      self.error = error
      resolve
    end

    def resolve
      self.resolved = true
      yield if block_given?
    ensure
      condv.broadcast # client or response might be waiting
    end

    # called in a new thread if pool_size == 0, otherwise from the pool
    # i.e. requesting thread
    def protected_yield
      value = if timer
                timeout_protected_yield{ yield }
              else
                yield
              end
      fulfill(value)
    rescue Exception => err
      self.class.set_backtrace(err)
      reject(err)
    end

    def timeout_protected_yield
      # timeout might already be set for thread_pool (pool_size > 0)
      timer.on_timeout{ cancel_task } unless timer
      yield
    ensure
      timer.cancel
    end

    # called in client thread, when yield is called
    def callback
      return result if called
      self.result = k.inject(error || value){ |r, i| i.call(r) }
    ensure
      self.called = true
    end

    # timeout!
    def cancel_task
      mutex.synchronize do
        if resolved?
          # do nothing if it's already done
        elsif t = thread || task.thread
          t.raise(timer.error) # raise Timeout::Error to working thread
        else
          # task was queued and never started, just cancel it and
          # fulfill the promise with Timeout::Error
          task.cancel
          rejecting(timer.error)
        end
      end
    end
  end
end

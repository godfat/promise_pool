
require 'thread'
require 'promise_pool/future'

module PromisePool
  class Promise
    def self.claim value, &callback
      promise = new
      promise.then(&callback) if block_given?
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
      self.resolved = false
      self.callbacks = []

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
      self
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
      case result
      when Exception
        raise result
      else
        result
      end
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
      callbacks << action
      self
    end

    def resolved?
      resolved
    end

    def started?
      !!working_thread
    end

    protected
    attr_accessor :value, :error, :result, :resolved, :callbacks,
                  :timer, :condv, :mutex, :task, :thread

    private
    def fulfilling value # should be synchronized
      self.value = value
      resolve
    end

    def rejecting error # should be synchronized
      self.error = error
      resolve
    end

    def resolve # should be synchronized
      self.result = callbacks.inject(error || value){ |r, k| k.call(r) }
    rescue Exception => err
      self.class.set_backtrace(err)
      self.result = err
      log_callback_error(err)
    ensure
      self.resolved = true
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
      timer.on_timeout{ cancel_task } unless timer.timer
      yield
    ensure
      timer.cancel
    end

    # timeout!
    def cancel_task
      mutex.synchronize do
        if resolved?
          # do nothing if it's already done
        elsif t = working_thread
          t.raise(timer.error) # raise Timeout::Error to working thread
        else
          # task was queued and never started, just cancel it and
          # fulfill the promise with Timeout::Error
          task.cancel
          rejecting(timer.error)
        end
      end
    end

    def working_thread
      thread || (task && task.thread)
    end

    # log user callback error, should never raise
    def log_callback_error err
      warn "#{self.class}: ERROR: #{err}\n  from #{err.backtrace.inspect}"
    rescue Exception => e
      Thread.main.raise(e) if !!$DEBUG
    end
  end
end

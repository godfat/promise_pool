
require 'promise_pool/promise'

module PromisePool
  class PromiseEager < Promise
    attr_accessor :error_callback

    def initialize timer=nil, &error_callback
      super(timer)
      self.error_callback = error_callback
    end

    def resolved?
      super && called
    end

    private
    def resolve
      super{ callback } # under ASYNC callback, should call immediately
    rescue Exception => err
      self.class.set_backtrace(err)
      call_error_callback(err)
    end

    # log user callback error, should never raise
    def call_error_callback err
      if error_callback
        error_callback.call(err)
      else
        warn "#{self.class}: ERROR: #{err}\n  from #{err.backtrace.inspect}"
      end
    rescue Exception => e
      Thread.main.raise(e) if !!$DEBUG
    end
  end
end

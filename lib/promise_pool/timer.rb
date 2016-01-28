
require 'thread'
require 'timers'

module PromisePool
  class Timer
    Error = Class.new(RuntimeError)

    @mutex = Mutex.new
    @interval = 1

    singleton_class.module_eval do
      attr_accessor :interval

      def group
        @group ||= @mutex.synchronize{ @group ||= group_new }
      end

      private
      def group_new
        g = Timers::Group.new
        g.every(interval){}
        @thread = Thread.new do
          begin
            g.wait
          rescue => e
            warn "#{self.class}: ERROR: #{e}\n  from #{e.backtrace.inspect}"
          end while g.count > 1
          @group = nil
        end
        g
      end
    end

    attr_accessor :timeout, :error, :timer
    def initialize timeout, error=Error.new('execution expired')
      self.timeout = timeout
      self.error   = error
    end

    def on_timeout &block
      self.block = block
      start
    end

    # should never raise!
    def cancel
      timer.cancel if timer
      self.block = nil
    end

    def start
      return if timeout.nil? || timeout.zero?
      self.timer = self.class.group.after(timeout){ block.call if block }
    end

    protected
    attr_accessor :block
  end
end

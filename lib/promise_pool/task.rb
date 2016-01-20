
module PromisePool
  class Task < Struct.new(:job, :mutex, :thread, :cancelled)
    # this should never fail
    def call working_thread
      mutex.synchronize do
        return if cancelled
        self.thread = working_thread
      end
      job.call
      true
    end

    def cancel
      self.cancelled = true
    end
  end
end

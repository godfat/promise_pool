
require 'promise_pool/test'

describe PromisePool::Timer do
  would 'cancel timeout even if task has not started' do
    pool = ThreadPool.new(0)
    timer = Timer.new(0.01)
    expect.raise(timer.error.class) do
      Promise.new(timer).defer(pool) do
        never called
      end.yield
    end.should.eq timer.error
  end
end

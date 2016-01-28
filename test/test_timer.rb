
require 'promise_pool/test'

describe PromisePool::Timer do
  before do
    @timer = Timer.new(0.01)
  end

  def expect_raise
    expect.raise(@timer.error.class) do
      yield
    end.should.eq @timer.error
  end

  would 'raise timeout if task has not started' do
    pool = ThreadPool.new(0)
    expect_raise do
      Promise.new(@timer).defer(pool) do
        never called
      end.yield
    end
  end

  describe 'with flag' do
    before do
      @flag = false
    end

    after do
      @flag.should.eq true
    end

    would 'raise timeout if the task started' do
      pool = ThreadPool.new(1)
      expect_raise do
        Promise.new(@timer).defer(pool) do
          @flag = true
          sleep
          never called
        end.yield
      end
      pool.shutdown
    end

    would 'raise timeout in the thread' do
      expect_raise do
        Promise.new(@timer).defer do
          @flag = true
          sleep
          never called
        end.yield
      end
    end

    would 'raise timeout even with inline call' do
      expect_raise do
        Promise.new(@timer).call do
          @flag = true
          sleep
          never called
        end.yield
      end
    end
  end
end

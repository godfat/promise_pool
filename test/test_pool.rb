
require 'promise_pool/test'

describe PromisePool::ThreadPool do
  before do
    @pool = ThreadPool.new(1)
    @promise = Promise.new
  end

  after do
    @pool.shutdown
    @pool.size.should.eq 0
  end

  def defer &block
    @promise.defer(@pool, &block)
  end

  would 'use the pool if passed' do
    @pool.size.should.eq 0
    defer do
      @pool.size
    end.yield.should.eq 1
  end

  would 'call in thread pool if pool_size > 0' do
    flag = 0
    rd, wr = IO.pipe
    defer do
      rd.gets
      flag.should.eq 0
      flag += 1
      raise 'nnf'
    end
    p1 = Promise.new
    p1.defer(@pool) do # block until promise #0 is done because max_size == 1
      flag.should.eq 1
      flag += 1
      raise 'boom'
    end
    wr.puts # start promise #0

    # even if we're not yielding, the block should still be resolved,
    # so there should not have any deadlock here.
    expect.raise(RuntimeError){       p1.yield }.message.should.eq 'boom'
    expect.raise(RuntimeError){ @promise.yield }.message.should.eq 'nnf'

    flag.should.eq 2
  end
end

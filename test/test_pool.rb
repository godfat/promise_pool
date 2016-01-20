
require 'promise_pool/test'

describe PromisePool::ThreadPool do
  before do
    @pool = ThreadPool.new(3)
    @promise = Promise.new
  end

  after do
    @pool.shutdown
    @pool.size.should.eq 0
  end

  would 'work, reject, yield' do
    @pool.max_size = 1
    flag = 0
    @promise.defer(@pool) do
      flag.should.eq 0
      flag += 1
      raise 'boom'
    end.yield
    flag.should.eq 1
    @promise.send(:error).message.should.eq 'boom'
  end

  would 'work, fulfill, yield' do
    value = 'body'
    @pool.max_size = 2
    flag = 0
    @promise.defer(@pool) do
      flag.should.eq 0
      flag += 1
      value
    end
    @promise.future.should.eq value
    @promise.send(:value).should.eq value
    @promise.send(:result).should.eq value
    @promise.should.resolved?
    flag.should.eq 1
  end

  would 'work, check body', :groups => [:only] do
    flag = 0
    result = @promise.defer(@pool) do
      flag.should.eq 0
      flag += 1
    end.future
    result.should.eq 1
    flag.should.eq 1
  end

  would 'call in thread pool if pool_size > 0' do
    @pool.max_size = 1
    flag = 0
    rd, wr = IO.pipe
    @promise.defer(@pool) do
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
    wr.puts  # start promise #0
    @promise.yield
    p1.yield # block until promise #1 is done
    flag.should.eq 2
  end
end

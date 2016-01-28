
require 'promise_pool/test'

describe PromisePool::Promise do
  describe 'claim' do
    would 'without block' do
      value = 'body'
      Promise.claim(value).yield.should.eq value
    end

    would 'with block' do
      value = 'body'
      Promise.claim(value, &:reverse).yield.should.eq 'ydob'
    end
  end

  describe 'then' do
    describe 'with mock' do
      after do
        Muack.verify
      end

      would 'handle exceptions in callbacks' do
        errors = []
        promise = Promise.new.then(&errors.method(:<<))

        mock(promise).warn(is_a(String)) do |msg|
          msg.should.start_with?("PromisePool::Promise: ERROR: nnf\n")
        end

        promise.then do |es|
          es.first.message.should.eq 'boom'
          raise 'nnf'
        end

        promise.defer do
          raise 'boom'
        end.wait

        errors.map(&:message).should.eq ['boom']
      end
    end

    would 'then then then' do
      plusone = lambda{ |r| r + 1 }
      promise = Promise.new
      2.times{ promise.then(&plusone).then(&plusone).then(&plusone) }
      promise.fulfill(0)
      promise.yield.should.eq 6
    end

    would 'transform to an exception and raise it' do
      promise = Promise.new
      promise.then(&RuntimeError.method(:new))
      promise.defer{ 'nnf' }
      expect.raise(RuntimeError) do
        promise.yield
      end.message.should.eq 'nnf'
    end
  end

  describe 'defer' do
    describe 'with mock' do
      after do
        Muack.verify
      end

      would 'call in a new thread if no pool' do
        thread = nil
        rd, wr = IO.pipe
        mock(Thread).new.with_any_args.peek_return do |t|
          thread = t
          wr.puts
        end
        Promise.new.defer do
          rd.gets
          Thread.current.should.eq thread
        end.yield
      end
    end

    would 'use the pool if passed' do
      pool = ThreadPool.new(10)
      pool.size.should.eq 0
      Promise.new.defer(pool) do
        pool.size
      end.yield.should.eq 1
      pool.shutdown
      pool.size.should.eq 0
    end
  end
end

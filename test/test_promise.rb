
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

  describe 'call' do
    would 'call in the current thread' do
      promise = Promise.new
      promise.call{ raise 'nnf' }
      promise.send(:thread).should.eq Thread.current
      promise.send(:task)  .should.eq nil
      promise.send(:error).message.should.eq 'nnf'
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

    would 'work, fulfill, yield' do
      value = 'body'
      flag = 0
      promise = Promise.new
      promise.should.not.started?
      promise.defer do
        flag.should.eq 0
        flag += 1
        value
      end
      promise.should.started?
      promise.yield.should.eq value
      promise.send(:value).should.eq value
      promise.send(:result).should.eq value
      promise.should.resolved?
      flag.should.eq 1
    end

    would 'work, reject, wait' do
      flag = 0
      promise = Promise.new.defer do
        flag.should.eq 0
        flag += 1
        raise 'boom'
      end
      promise.wait
      flag.should.eq 1
      promise.send(:error).message.should.eq 'boom'
    end
  end

  describe 'wait' do
    would 'broadcast to different threads' do
      flag = 0
      mutex = Mutex.new
      promise = Promise.new
      threads = 3.times.map do
        Thread.new do
          mutex.synchronize{ flag += 1 }
          promise.wait
          mutex.synchronize{ flag += 1 }
          promise.yield
        end
      end
      Thread.pass until flag == 3
      promise.fulfill('ok')
      Thread.pass until flag == 6
      threads.map(&:value).should.eq %w[ok ok ok]
    end
  end
end

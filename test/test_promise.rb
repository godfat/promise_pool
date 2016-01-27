
require 'promise_pool/test'

describe PromisePool::Promise do
  would 'claim' do
    value = 'body'
    Promise.claim(value).future.should.eq value
  end

  would 'then then then' do
    plusone = lambda{ |r| r + 1 }
    promise = Promise.new
    2.times{ promise.then(&plusone).then(&plusone).then(&plusone) }
    promise.fulfill(0)
    promise.future.should.eq 6
  end

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

  would 'pass error to callbacks' do
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

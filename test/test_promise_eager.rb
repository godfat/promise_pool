
require 'promise_pool/test'

describe PromisePool::PromiseEager do
  would 'call error_callback on errors' do
    errors = []
    promise = PromiseEager.new(&errors.method(:<<))

    promise.then do |err|
      err.message.should.eq 'boom'
      raise 'nnf'
    end

    promise.defer do
      raise 'boom'
    end.wait

    errors.map(&:message).should.eq ['nnf']
  end

  after do
    Muack.verify
  end

  would 'warn if there is no error_callback' do
    promise = PromiseEager.new

    mock(promise).warn(is_a(String)) do |msg|
      msg.should.start_with?("PromisePool::PromiseEager: ERROR: nnf\n")
    end

    promise.then do |value|
      value.should.eq 'value'
      raise 'nnf'
    end

    promise.defer do
      'value'
    end.wait
  end
end


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
end

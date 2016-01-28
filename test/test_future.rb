
require 'promise_pool/test'

describe PromisePool::Future do
  would 'return the value' do
    Promise.new.defer{ 'value' }.future.should.eq 'value'
  end

  would 'raise an exception' do
    expect.raise(RuntimeError) do
      Promise.new.defer do
        raise 'nnf'
      end.future.oops
    end.message.should.eq 'nnf'
  end

  would 'raise an exception if it is returning an exception' do
    expect.raise(RuntimeError) do
      Promise.new.defer{ RuntimeError.new('nnf') }.future.oops
    end.message.should.eq 'nnf'
  end

  would 'respond_to_missing? properly' do
    [Promise.new.defer{0}.future].flatten.first.should.eq 0
  end
end

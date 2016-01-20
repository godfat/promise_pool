
require 'promise_pool/test'

describe PromisePool::Future do
  would 'raise an exception' do
    expect.raise(RuntimeError) do
      Promise.new.defer do
        raise 'nnf'
      end.future.oops
    end.message.should.eq 'nnf'
  end
end

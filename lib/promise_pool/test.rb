
require 'promise_pool'
require 'pork/auto'
require 'muack'

Pork::Executor.include(Muack::API)
include PromisePool

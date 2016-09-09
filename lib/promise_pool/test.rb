
require 'promise_pool'
require 'pork/auto'
require 'muack'

Pork::Suite.include(Muack::API)
include PromisePool

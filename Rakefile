
begin
  require "#{__dir__}/task/gemgem"
rescue LoadError
  sh 'git submodule update --init --recursive'
  exec Gem.ruby, '-S', $PROGRAM_NAME, *ARGV
end

Gemgem.init(__dir__) do |s|
  require 'promise_pool/version'
  s.name    = 'promise_pool'
  s.version = PromisePool::VERSION

  s.add_runtime_dependency('timers', '>=4.0.1')
end

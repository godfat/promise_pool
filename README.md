# promise_pool [![Build Status](https://secure.travis-ci.org/godfat/promise_pool.png?branch=master)](http://travis-ci.org/godfat/promise_pool) [![Coverage Status](https://coveralls.io/repos/github/godfat/promise_pool/badge.png)](https://coveralls.io/github/godfat/promise_pool) [![Join the chat at https://gitter.im/godfat/promise_pool](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/godfat/promise_pool)

by Lin Jen-Shin ([godfat](http://godfat.org))

## LINKS:

* [github](https://github.com/godfat/promise_pool)
* [rubygems](https://rubygems.org/gems/promise_pool)
* [rdoc](http://rdoc.info/projects/godfat/promise_pool)
* [issues](https://github.com/godfat/promise_pool/issues) (feel free to ask for support)

## DESCRIPTION:

promise_pool is a promise implementation backed by threads or threads pool.

## FEATURES:

* PromisePool::Promise
* PromisePool::ThreadPool
* PromisePool::Timer

## WHY?

This was extracted from [rest-core][] because rest-core itself is getting
too complex, and extracting promises from it could greatly reduce complexity
and improve modularity for both rest-core and promise_pool.

[rest-core]: https://github.com/godfat/rest-core

## REQUIREMENTS:

* Tested with MRI (official CRuby) and JRuby.
* gem [timers][]

[timers]: https://github.com/celluloid/timers

## INSTALLATION:

``` shell
gem install promise_pool
```

Or if you want development version, put this in Gemfile:

``` ruby
gem 'promise_pool', :git => 'git://github.com/godfat/promise_pool.git',
                    :submodules => true
```

## SYNOPSIS:

### Basic Usage

``` ruby
require 'promise_pool/promise'
promise = PromisePool::Promise.new
promise.defer do
  sleep 1
  puts "Doing works..."
  sleep 1
  "Done!"
end
puts "It's not blocking!"
puts promise.yield
```

Prints:

```
It's not blocking!
Doing works...
Done!
```

### Multiple Concurrent Promises

Doing multiple things at the same time, and wait for all of them at once.

``` ruby
require 'promise_pool/promise'

futures = 3.times.map do |i|
  PromisePool::Promise.new.defer do
    sleep i
    i
  end.future
end

futures.each(&method(:puts))
```

Prints:

```
0
1
2
```

### Error Handling

If an exception was raised in the `defer` block, it would propagate whenever
`yield` is called. Note that futures would implicitly call `yield` for you.

``` ruby
require 'promise_pool/promise'

future = PromisePool::Promise.new.defer do
  raise 'nnf'
end.future

begin
  future.to_s
  never reached
rescue RuntimeError => e
  puts e
end
```

Prints:

```
nnf
```

### Serialization for single future

Sometimes we would like to serialize the result from future, however although
futures are full-blown proxies, some serializers just can't serialize them.

For example, while `JSON` could dump and load them, `Marshal` can't. So it
would be great that if we could somehow uncover the future and get the result
underneath.

For single value future, we could just call `itself` or `tap{}` to do that.

``` ruby
require 'promise_pool/promise'

future = PromisePool::Promise.new.defer{ 0 }.future
puts Marshal.load(Marshal.dump(future.itself))
```

Prints:

```
0
```

### Serialization for nested futures

For nested futures, we could use `PromisePool::Future.resolve` to help us.

``` ruby
require 'promise_pool/promise'

value = PromisePool::Promise.new.defer{ 0 }.future
array = PromisePool::Promise.new.defer{ [value] }.future

puts Marshal.load(Marshal.dump(PromisePool::Future.resolve(array)))
```

Prints:

```
[0]
```

### PromisePool::ThreadPool

With a thread pool, we could throttle the process and avoid exhausting
resources whenever needed.

``` ruby
require 'promise_pool/promise'
require 'promise_pool/thread_pool'

pool = PromisePool::ThreadPool.new(10, 60) # max_size=10, idle_time=60
future = PromisePool::Promise.new.defer(pool) do
  'Only process this whenever a worker is available.'
end.future

puts future

pool.shutdown # Make sure all the tasks are done in the pool before exit.
              # You'll surely need this for shutting down gracefully.
```

Prints:

```
Only process this whenever a worker is available.
```

### PromisePool::Timer

If a task is taking too much time, we could time it out.

``` ruby
require 'promise_pool/promise'
require 'promise_pool/timer'

timer = PromisePool::Timer.new(1)
future = PromisePool::Promise.new(timer).defer do
  sleep
  never reached
end.future

begin
  future.to_s
rescue PromisePool::Timer::Error => e
  puts e.message
end
```

Prints:

```
execution expired
```

## CHANGES:

* [CHANGES](CHANGES.md)

## CONTRIBUTORS:

* Lin Jen-Shin (@godfat)

## LICENSE:

Apache License 2.0 (Apache-2.0)

Copyright (c) 2016-2018, Lin Jen-Shin (godfat)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   <http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

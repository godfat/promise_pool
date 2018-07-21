# CHANGES

## promise_pool 0.9.2 -- 2018-07-21

* Added `Promise#started?` so we could pick the promise is starting or not.
* Potentially fixed an exception when the promise is not scheduled yet timed
  out. It's unlikely to happen but it should be fine now.
* Added `ThreadPool#queue_size` to peek the size of the queue.

## promise_pool 0.9.1 -- 2018-03-20

* Introduced PromisePool::Future.resolve to convert nested futures

## promise_pool 0.9.0 -- 2016-01-29

* First beta!

## promise_pool 0.5.0 -- 2016-01-26

* Birthday!

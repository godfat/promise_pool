# -*- encoding: utf-8 -*-
# stub: promise_pool 0.9.2 ruby lib

Gem::Specification.new do |s|
  s.name = "promise_pool".freeze
  s.version = "0.9.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Lin Jen-Shin (godfat)".freeze]
  s.date = "2018-07-21"
  s.description = "promise_pool is a promise implementation backed by threads or threads pool.".freeze
  s.email = ["godfat (XD) godfat.org".freeze]
  s.files = [
  ".gitignore".freeze,
  ".gitmodules".freeze,
  ".travis.yml".freeze,
  "CHANGES.md".freeze,
  "Gemfile".freeze,
  "README.md".freeze,
  "Rakefile".freeze,
  "lib/promise_pool.rb".freeze,
  "lib/promise_pool/future.rb".freeze,
  "lib/promise_pool/promise.rb".freeze,
  "lib/promise_pool/queue.rb".freeze,
  "lib/promise_pool/task.rb".freeze,
  "lib/promise_pool/test.rb".freeze,
  "lib/promise_pool/thread_pool.rb".freeze,
  "lib/promise_pool/timer.rb".freeze,
  "lib/promise_pool/version.rb".freeze,
  "promise_pool.gemspec".freeze,
  "task/README.md".freeze,
  "task/gemgem.rb".freeze,
  "test/test_future.rb".freeze,
  "test/test_promise.rb".freeze,
  "test/test_readme.rb".freeze,
  "test/test_thread_pool.rb".freeze,
  "test/test_timer.rb".freeze]
  s.homepage = "https://github.com/godfat/promise_pool".freeze
  s.licenses = ["Apache-2.0".freeze]
  s.rubygems_version = "2.7.7".freeze
  s.summary = "promise_pool is a promise implementation backed by threads or threads pool.".freeze
  s.test_files = [
  "test/test_future.rb".freeze,
  "test/test_promise.rb".freeze,
  "test/test_readme.rb".freeze,
  "test/test_thread_pool.rb".freeze,
  "test/test_timer.rb".freeze]

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<timers>.freeze, [">= 4.0.1"])
    else
      s.add_dependency(%q<timers>.freeze, [">= 4.0.1"])
    end
  else
    s.add_dependency(%q<timers>.freeze, [">= 4.0.1"])
  end
end

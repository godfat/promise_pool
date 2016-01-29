# -*- encoding: utf-8 -*-
# stub: promise_pool 0.9.0 ruby lib

Gem::Specification.new do |s|
  s.name = "promise_pool"
  s.version = "0.9.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Lin Jen-Shin (godfat)"]
  s.date = "2016-01-29"
  s.description = "promise_pool is a promise implementation backed by threads or threads pool."
  s.email = ["godfat (XD) godfat.org"]
  s.files = [
  ".gitignore",
  ".gitmodules",
  ".travis.yml",
  "CHANGES.md",
  "Gemfile",
  "README.md",
  "Rakefile",
  "lib/promise_pool.rb",
  "lib/promise_pool/future.rb",
  "lib/promise_pool/promise.rb",
  "lib/promise_pool/queue.rb",
  "lib/promise_pool/task.rb",
  "lib/promise_pool/test.rb",
  "lib/promise_pool/thread_pool.rb",
  "lib/promise_pool/timer.rb",
  "lib/promise_pool/version.rb",
  "promise_pool.gemspec",
  "task/README.md",
  "task/gemgem.rb",
  "test/test_future.rb",
  "test/test_promise.rb",
  "test/test_readme.rb",
  "test/test_thread_pool.rb",
  "test/test_timer.rb"]
  s.homepage = "https://github.com/godfat/promise_pool"
  s.licenses = ["Apache License 2.0"]
  s.rubygems_version = "2.5.1"
  s.summary = "promise_pool is a promise implementation backed by threads or threads pool."
  s.test_files = [
  "test/test_future.rb",
  "test/test_promise.rb",
  "test/test_readme.rb",
  "test/test_thread_pool.rb",
  "test/test_timer.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<timers>, [">= 4.0.1"])
    else
      s.add_dependency(%q<timers>, [">= 4.0.1"])
    end
  else
    s.add_dependency(%q<timers>, [">= 4.0.1"])
  end
end


require 'promise_pool/test'

describe 'README.md' do
  readme = File.read("#{__dir__}/../README.md")
  codes  = readme.scan(
    /### ([^\n]+).+?``` ruby\n(.+?)\n```\n\nPrints:\n\n```\n(.+?)```/m)

  context = Class.new(Struct.new(:result)) do
    def sleep sec=nil
      if sec
        Kernel.sleep(sec / 100.0)
      else
        Kernel.sleep
      end
    end

    def puts str
      result << "#{str}\n"
    end
  end

  codes.each.with_index do |(title, code, test), index|
    would "pass README.md #%02d #{title}" % index do
      ctx = context.new([])
      ctx.instance_eval(code, 'README.md', 0)
      ctx.result.should.eq test.lines
    end
  end
end

require "rake/testtask"

Rake::TestTask.new do |t|
  t.libs << "test"
  t.libs << "."
  t.test_files = FileList["test/**/*_test.rb"]
  # t.require = 'test/test_helper'
end
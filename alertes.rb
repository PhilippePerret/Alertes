#!/usr/bin/env ruby


begin
  APP_FOLDER = __dir__
  require_relative 'lib/required'
  Alertes.run
rescue Exception => e
  puts "ERREUR : #{e.message}\n#{e.backtrace.join("\n")}".rouge
end

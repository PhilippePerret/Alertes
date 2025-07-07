#!/usr/bin/env ruby


begin
  require_relative 'lib/required'
  Alertes.run
rescue Exception => e
  puts "ERREUR : #{e.message}\n#{e.backtrace.join("\n")}".rouge
end

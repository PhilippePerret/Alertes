#!/usr/bin/env ruby

begin
  APP_FOLDER = __dir__
  require_relative 'lib/required'
  Alertes.run
  clear
rescue TTY::Reader::InputInterrupt => e
  clear
  # Interruption forcée
  puts "\nOk, bye bye.".gris
rescue Exception => e
  puts "ERREUR : #{e.message}\n#{e.backtrace.join("\n")}".rouge
end

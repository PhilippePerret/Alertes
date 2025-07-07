#!/usr/bin/env ruby


begin
  require_relative 'lib/required'
  puts "Je dois apprendre à lancer les alertes".jaune
rescue Exception => e
  puts "ERREUR : #{e.message}\n#{e.backtrace.join("\n")}".rouge
end

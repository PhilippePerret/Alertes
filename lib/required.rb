require 'clir'
require 'yaml'
require 'date'

class Alertes; end
Dir["#{__dir__}/first_classes/*.rb"].each{|m| require m}
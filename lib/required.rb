require 'clir'
require 'yaml'

class Alertes; end
Dir["#{__dir__}/first_classes/*.rb"].each{|m| require m}
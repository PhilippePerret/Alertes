class Alertes
class << self
  def run
    puts "Je dois apprendre à jouer les alertes".jaune

    deadline = "10:00".fill_in_as_time


    puts "Je simule une alerte et je la joue"
    alerte = Alerte.new({
      content: "Une longue tâche pour voir ce qu'elle va faire", 
      duration: nil,
      deadline: deadline,
      folder: "/Users/philippeperret/"
    })
    alerte.run
  end
end #/class << self
end #/Alertes

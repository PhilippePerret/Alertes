class Alertes
class << self
  def run
    clear
    case Q.select("Que voulez-vous faire ?".jaune, choices)
    when nil then return
    when :ponct   then usage_ponctuel
    when :program then programmer_des_alertes
    when :file    then lancer_alertes_programmed
    end
  end

  def usage_ponctuel
    puts "Je dois apprendre à faire un usage ponctuel".jaune
    Alerte.define_and_run
  end
  def programmer_des_alertes
    puts "Je dois apprendre à programmer des alertes".jaune
  end
  def lancer_alertes_programmed
    puts "Je dois apprendre à lancer des alertes programmées".jaune
  end

  def choices
    [
      {name: "Utilisation ponctuelle pour maintenant", value: :ponct},
      {name: "Enregistrer des alertes/tâches", value: :program},
      {name: "Lancer les alertes/tâches enregistrées", value: :file},
      {name: "Ne rien faire".orange, value: nil}
    ]
  end

  def simulation
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

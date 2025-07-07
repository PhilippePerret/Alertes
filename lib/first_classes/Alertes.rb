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
    Alerte.define_and_run
  end
  def programmer_des_alertes
    new_alertes = []
    while true
      alerte = Alerte.define_data_alerte(headline: true)
      unless alerte.nil?
        new_alertes << alerte
      end
      break unless Q.yes?("Programmer une autre alerte ?".jaune)
    end
    case Q.select("Que doit-on faire ?".jaune, [{name: "Les lancer maintenant", value: :now}, {name: "Les enregistrer", value: :save}, {name: "Ne rien faire".orange, value: nil}])
    when nil then return
    when :save
      toutes_les_alertes = read_alertes + new_alertes
      puts "toutes_les_alertes: #{toutes_les_alertes}"
      YAML.dump(toutes_les_alertes, IO.open(data_path, 'w'))
    when :now
      jouer_alertes(new_alertes)
    end    
  end

  def jouer_alertes(alertes)
    alertes    
    .each do |dalerte|
      # TODO : NON, ÇA N'EST PAS DU TOUT COMME ÇA QU'IL FAUT FAIRE
      # Il faut regarder quand l'alerte doit être lancée et la
      # programmer pour ce temps là.
      Alerte.new(dalerte).run
      break
    end
  end

  def lancer_alertes_programmed
    jouer_alertes(read_alertes)
  end

  def read_alertes
    if File.exist?(data_path)
      YAML.save_load(IO.read(data_path), **YAML_OPTIONS)
    else
      []
    end
  end

  def data_path
    @data_path ||= File.join(APP_FOLDER, 'data.yaml')
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

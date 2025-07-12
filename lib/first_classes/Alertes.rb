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
      YAML.dump(toutes_les_alertes, File.open(data_path, 'w'))
    when :now
      jouer_alertes(new_alertes)
    end    
  end

  def jouer_alertes(alertes)
    @all_alertes = 
      Marshal.load(Marshal.dump(alertes))
      .map{|data| Alerte.new(data)}
    if @all_alertes.count > 1
      @all_alertes = organiser(@all_alertes)
    end
    jouer_next_alerte()
  end
  def jouer_next_alerte
    alerte = @all_alertes.shift || return # fin
    # puts "alerte: #{alerte.inspect}"
    alerte.run
  end

  # @return True si on est en inactivité depuis une minute
  def inactivite?
    idle_time = IO.popen(['ioreg', '-c', 'IOHIDSystem']) do |io|
      io.read[/HIDIdleTime" = (\d+)/, 1].to_i / 1_000_000_000
    end
    idle_time > 60
  end

  # Pour mettre l'+alerte+ après la première (première qui sera
  # certainement jouée juste maintenant)
  def set_after_first_alert(alerte)
    @all_alertes.insert(1, alerte)
  end

  def lancer_alertes_programmed
    jouer_alertes(read_alertes)
  end

  def read_alertes
    if File.exist?(data_path)
      YAML.safe_load(IO.read(data_path), **YAML_OPTIONS)
    else
      []
    end
  end

  def data_path
    @data_path ||= File.join(APP_FOLDER, 'alertes.yaml')
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

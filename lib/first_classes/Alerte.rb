=begin
Pour la gestion d'une instance d'alerte

PROPRIÉTÉS

  :content    Le contenu du texte de la tâche/alerte
  :duration   La durée, si fournie. On définit la durée quand on 
              attend une durée de travail précise. Sinon, si on
              travaille jusqu'à une heure précise, régler plutôt
              la valeur de :deadline. C'est une HORLOGE ou un
              nombre de secondes
  :deadline   La tâche doit s'arrêter à cette heure-là. C'est une
              horloge.
  :folder     Le dossier éventuellement à ouvrir
  :script     Le script éventuellement à lancer au début de la
              tâche.

=end
class Alertes::Alerte
  # === C L A S S E ====
  class << self

    # Méthode appelée pour définir une alerte et la lancer
    def define_and_run
      data_alerte = define_data_alerte || return
      alerte = new(data_alerte)
      alerte.run
    end

    def define_data_alerte
      content = duration = deadline = nil
      content = Q.ask("Texte de l'alerte".jaune)
      case Q.select("Que veux-tu programmer ?".jaune, [{name: "La durée du travail", value: :duration}, {name: "L’échéance de travail", value: :deadline}])
      when :duration
        hduration = Q.ask("Durée en minutes (horloge possible)".jaune)
        duration = hduration.to_minutes
        puts "duration = #{duration.inspect}"
      when :deadline
        hdeadline = Q.ask("Heure d’échéance (H:MM)".jaune)
        deadline = hdeadline.fill_in_as_time
        puts "deadline = #{deadline.inspect}"
      end

      {content: content, duration: duration, deadline: deadline}
    end

  end #/class << self  
  # === I N S T A N C E ===

  attr_reader :content, :deadline, :folder, :script
  def duration
    if deadline?
      ((deadline.as_time - Time.now).round / 60).round
    else
      @duration
    end
  end

  def initialize(data)
    @duration = data[:duration]
    @content  = data[:content]
    @deadline = data[:deadline]
    @folder   = data[:folder]
    @script   = data[:script]
  end

  # Pour lancer la tâche
  def run
    rdd = Ruby2DClass.new(self)
    rdd.open
  end

  def deadline?; !@deadline.nil? end

  def deadline_time
    @deadline_time ||= deadline.as_time
  end

  # Pour recalculer la durée restante de travail après une pause
  # de la tâche.
  # Cela n'est utile que si c'est la deadline qui est définie
  def duration_refreshed
    (deadline_time - Time.now).round
  end

  # Pour ouvrir le dossier stipuler
  def open_folder
    if folder.nil?
      return "Pas de dossier stipulé"
    elsif File.exist?(folder)
      `open -a Finder "#{folder}"`
      return "Dossier ouvert dans le Finder"
    else
      return "Le dossier #{folder.inspect} est introuvable…"
    end
  end

  def run_script
    if script.nil?
      return "Aucun script n'est stipulé."
    elsif File.exist?(script)
      return "Je dois appendre à jouer le script #{script}"
      return true
    else
      return "Le script #{script.inspect} est introuvable…"
    end
  end

end
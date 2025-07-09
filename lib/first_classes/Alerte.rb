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
  :open_with  Dans quoi il faut ouvrir le dossier (:folder). 
              possibilités : 'Finder', 'VSCode', 'both' (les deux)
  :script     Le script éventuellement à lancer au début de la
              tâche.

=end
class Alertes::Alerte
  # === C L A S S E ====
  class << self

    # Méthode appelée par une alerte pour la lancer
    def run(alerte)
      if @rdd.nil?
        @rdd = Ruby2DClass.new()
        @rdd.open(alerte)
      else
        @rdd.run(alerte)
      end
    end


    # Méthode appelée pour définir une alerte et la lancer
    def define_and_run
      data_alerte = define_data_alerte || return
      alerte = new(data_alerte)
      self.class.run(alerte)
    end

    def define_data_alerte(params = {})
      clear 
      puts "Définition d'une nouvelle alerte\n".bleu

      content = duration = deadline = headline = nil
      content = Q.ask("Texte de l'alerte : ".jaune)

      # Pour des données complètes
      if params[:headline]
        case Q.select("Tâche ponctuelle ou répétée ?".jaune, [{name: "Ponctuelle (un jour précis)", value: :ponct}, {name: "Répétée", value: :reccur}])
        when :reccur
          hheadline = Q.ask("À quelle heure ? (horloge H:MM ou H,MM)".jaune)
          headline = hheadline.to_full_horloge(no_seconde: true)
        when :ponct
          hheadline = Q.ask("Date et heure de début de l’alerte (p.e. 12 10:30 : ".jaune)
          headline = hheadline.fill_in_as_time
        end
        puts "headline: #{headline.inspect}".bleu
      end

      case Q.select("Que veux-tu programmer ?".jaune, [{name: "La durée du travail", value: :duration}, {name: "L’échéance de travail", value: :deadline}])
      when :duration
        hduration = Q.ask("Durée en minutes (horloge H:MM possible)".jaune)
        duration = hduration.to_minutes
      when :deadline
        hdeadline = Q.ask("Heure d’échéance (H:MM)".jaune)
        deadline = hdeadline.fill_in_as_time
      end


      {content: content, duration: duration, deadline: deadline, headline: headline}
    end

  end #/class << self  
  # === I N S T A N C E ===

  # ID défini par certaines fonctions
  attr_accessor :id

  attr_reader :data
  attr_reader :content, :folder, :open_with, :script
  def duration
    if deadline?
      ((deadline.as_time - Time.now).round / 60).round
    else
      @duration
    end
  end
  def duration=(value)
    @duration = value
    data[:duration] = value
    @deadline = nil # pour recalcul
  end

  def initialize(data)
    @data = data
    @duration   = data[:duration]
    @content    = data[:content]
    @folder     = data[:folder]
    @script     = data[:script]
    @open_with  = data[:open_with]
  end

  # Pour lancer la tâche et la fenêtre
  def run
    self.class.run(self)
  end
  def deadline?; !@deadline.nil? end
  
  # @return True si l'alerte est du jour
  def today?
    headline_time >= Time.start_of_today && headline_time <= Time.end_of_today
  end

  def headline_time
    @headline_time ||= headline && headline.as_time
  end
  def headline
    @headline ||= begin
      hd = data[:headline]
      if hd.nil?
        nil
      elsif hd.is_time?
        hd
      else
        # Il peut n'y avoir que l'heure
        n = Time.now
        "#{n.year}-#{n.month.to2}-#{n.day.to2} #{hd.to8}"
      end
    end
  end

  def deadline_time
    @deadline_time ||= deadline.as_time
  end

  def deadline
    @deadline ||= begin
      if data[:deadline]
        data[:deadline]
      elsif data[:headline] && duration
        (headline.as_time + duration * 60).strftime(Time::TIME_FORMAT)
      end
    end
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
      case open_with
      when  nil, 'Finder'
        `open -a Finder "#{folder}"`
      when 'VSCode'
        `code "#{folder}"`
      when 'both'
        `open -a Finder "#{folder}"`
        `code "#{folder}"`
      end
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
      # return true
    else
      return "Le script #{script.inspect} est introuvable…"
    end
  end

end
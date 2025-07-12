
module Ruby2D
  class Window
    attr_reader :text_blocs
    def add_text_bloc(btext)
      @text_blocs ||= []
      @text_blocs << btext
    end
    # Met la couleur de tous les textes à +color+
    # Rappel : chaque ligne de texte est un bloc différent, même
    # si le texte se suit.
    def set_color_texts(color)
      @text_blocs.each {|tb| tb.color = color }
    end
    def remove_all_text_blocs
      return if @text_blocs.nil? || @text_blocs.empty?
      @text_blocs.each {|tb| remove(tb)}
      @text_blocs = []
    end
  end
end

class Ruby2DClass
  
  attr_reader :window, :alerte, :tache

  require 'ruby2d'
  include Ruby2D
  WIDTH       = 800
  HEIGHT      = 600
  NORMAL_FONT = "resources/fonts/NunitoSans.ttf"
  LEFT_MARG   = 20
  FOND_ROUGE  = Ruby2D::Color.new([1,0,0,1])

  def info(msg)
    @binfo.text = msg
  end

  def ask(msg)
    write(msg + ' (ok: return, no: esc)', color: 'blue')
  end
  def ask_with_choices(msg, choices)
    write(msg, color: 'blue')
    choices.each_with_index do |choix, i|
      write("#{i + 1}: #{choix[0]}", color: 'blue', keep: true)
    end
    @choices = choices
  end

  # Définit l'aide en fonction de l'alerte courante
  def set_aide
    window.remove(@baide) if @baide
    aides = %w([F]inie (suivante) [S]stop [N]ext [P]revious)
    aides << "[O]pen" if alerte.folder
    aides << "[X]run script" if alerte.script
    aides += %w([Q]uitter [H]elp)
    @baide = Ruby2D::Text.new(
      aides.join(' '),
      x: 100, y: HEIGHT - 30, color: 'gray', font: NORMAL_FONT, z: 10
    )
    window.add(@baide)
  end

  def open(alerte)
    @window = Ruby2D::Window.new
    window.set(title: "Alertes", 
      width: WIDTH, 
      height: HEIGHT,
      background: 'white',
      foreground: 'black',
      fps_cap: 1
    )

    # Pour le fond
    @rect = Rectangle.new(x: 0, y: 0, width: WIDTH, height: HEIGHT, color: 'white', z: 0)
    window.add(@rect)
    
    # Pour les informations
    @binfo = Ruby2D::Text.new(
      "---", x: LEFT_MARG, y: HEIGHT - 60, color: 'blue', font: NORMAL_FONT, size: 20
    )
    window.add(@binfo)

    # Le compteur
    noirc = Ruby2D::Color.new([0.3,0.3,0.3,1])
    @bcompteur = Ruby2D::Text.new("0:00:00", size: 48, x: WIDTH - 260, y: 10, color: noirc, font: "resources/fonts/Courier.ttf")
    window.add(@bcompteur)

    window.on :key_down do |ev|
      case ev.key
      when '1', 'keypad 1'
        exec_choix(1)
      when '2', 'keypad 2'
        exec_choix(2)
      when '3', 'keypad 3'
        exec_choix(3)
      when '4', 'keypad 4'
        exec_choix(4)
      when '5', 'keypad 5'
        exec_choix(5)
      when 'o'
        @next_operation = -> { 
          info alerte.open_folder 
          write(tache)
        }
        ask("Voulez-vous ouvrir le dossier de l’alerte ?")
      when 'x'
        @next_operation = -> { info alerte.run_script }
        ask("Voulez-vous jouer le script de l’alerte ?")
      when 'return', 'space' then
        if @next_operation
          run_next_operation
          # write(tache)
        end
        run_ensure_operation if @ensure_operation
      when 'escape'
        @next_operation = nil
        if @ensure_operation
          run_ensure_operation
        else
          write(tache)
        end
      when 'a', 'A' then 
        ask("Vous voulez quitter le programme ?")
        @next_operation = -> { window.close }
      when 'f', 'F'
        ask("Cette tâche est-elle vraiment finie ?")
        @next_operation = -> { Alertes.jouer_next_alerte }
      when 'N', 'n'
        ask_with_choices("Voulez-vous passer à l’alerte/tâche suivante ?",
        [
          ["oui, en passant cette tâche après", -> {Alertes.set_after_first_alert(alerte); Alertes.jouer_next_alerte}], 
          ["oui, en retirant cette tâche", -> { Alertes.jouer_next_alerte }], 
          ["non, renoncer", -> { write(tache) } ]
        ])
      when 's', 'S' then ask("Vous voulez faire une pause ?")
        @next_operation = -> { 
          @stop_counter = true;
          info("Frappez 'R' quand vous voudrez reprendre") 
        }
      when 'r', 'R' then 
        ask("Vous voulez reprendre ?")
        @next_operation = -> do
          @stop_counter = false
          if alerte.deadline?
            @countdown = alerte.duration_refreshed
            msg = "La durée a été recalculée en fonction de l’échéance définie."
            info(msg)
          else
            info("")
          end
          set_fond('white', 'black')
          write(tache)
        end
      when 'p', 'P' then 
        ask("Vous voulez revenir à la précédente ?")
      else puts "Vous avez pressé la touche #{ev.key}"
      end
    end

    run(alerte)

    window.show

  end #/open

  def exec_choix(indice)
    unless @choices.nil?
      choix = @choices[indice - 1]
      # => ["message", <procédure>]
      choix[1].call unless choix.nil?
      @choices = nil
    end
  end

  def run_ensure_operation
    @ensure_operation.call
    @ensure_operation = nil
  end
  def run_next_operation
    @next_operation.call
    @next_operation = nil
  end

  def run(alerte)

    @alerte = alerte
    # Pour l'aide (qui dépend de chaque tâche)
    set_aide

    # Pour les textes principaux (la tâche par exemple)
    @tache = alerte.content
    write(tache)

    # On repasse toujours en blanc
    set_fond('white', 'black')

    @countdown = alerte.duration * 60
    @bcompteur.text = @countdown.to_horloge
    precount = 0
    window.update do # boucle toutes les secondes
      if Alertes.inactivite?
        @stop_counter = true
        set_fond('yellow', 'red')
        write("Vous êtes resté plus d’une minute sans activité. J’arrête le compteur.", color: 'red')
        info("Frappez 'R' quand vous voudrez reprendre")
      end
      if @stop_counter
        next
      else
        @countdown -= 1 
        if precount < 5
          @bcompteur.text = @countdown.to_horloge
          precount += 1
        elsif @countdown % 5 == 0
          @bcompteur.text = @countdown.to_horloge
        end
        if @countdown < 0
          if @countdown > -20
            # Pour ne le faire que quelques fois
            set_fond(FOND_ROUGE, 'white')
          end
        elsif @countdown <= 60
          set_fond('orange', 'white')
        end
      end
    end
  end

  def set_fond(couleur, couleur_textes = 'black')
    @rect.color = couleur
    window.set_color_texts(couleur_textes)
  end

  # Écris le texte +texte+ dans la fenêtre +window+
  # (en tenant compte du fait qu'on ne peut pas enrouler du texte
  #  avec Ruby2D, donc il faut créer des lignes successives)
  def write(texte, options = {})
    # puts "TEXTE = #{texte.inspect}"
    # puts "OPTIONS = #{options.inspect}"
    # puts "text_blocs = #{(window.text_blocs||[]).count} élément(s)"
    window = @window
    text_blocs = window.text_blocs
    color = options[:color] || 'black'
    top = 
      unless options[:keep]
        window.remove_all_text_blocs
        80
      else
        80 + (text_blocs||[]).count * 24
      end
    text_props = {size: 20, x: LEFT_MARG, y: top, color: color, font: NORMAL_FONT}
    btext = Ruby2D::Text.new("", **text_props)
    window.add_text_bloc(btext)
    window.add(btext)
    mots = texte.split(" ")
    bloc = ""
    until mots.empty?
      while mots.any?
        break if mots.empty?
        btext.text = bloc + mots[0] + ' '
        break if btext.width > (WIDTH - 100)
        bloc += mots.shift + ' '
      end
      break if mots.empty?
      btext = Ruby2D::Text.new("", **text_props.merge(y: btext.y + 24))
      window.add_text_bloc(btext)
      window.add(btext)
      bloc = ""
    end
    # puts "text_blocs à la fin = #{window.text_blocs.count} élément(s)"
  end

end
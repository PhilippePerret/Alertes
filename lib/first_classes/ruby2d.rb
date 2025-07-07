
module Ruby2D
  class Window
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
  
  attr_reader :window, :alerte

  require 'ruby2d'
  include Ruby2D
  WIDTH       = 800
  HEIGHT      = 600
  NORMAL_FONT = "resources/fonts/NunitoSans.ttf"
  LEFT_MARG   = 20

  def initialize(alerte)
    @alerte = alerte
  end

  def info(msg)
    @binfo.text = msg
  end
  def ask(msg)
    write(msg, window, 'blue')
  end

  def open
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

    # Pour l'aide
    aides = %w([S]stop [N]ext [P]revious)
    aides << "[O]pen" if alerte.folder
    aides << "[X]run script" if alerte.script
    aides += %w([Q]uitter [H]elp)
    baide = Ruby2D::Text.new(
      aides.join(' '),
      x: 100, y: HEIGHT - 30, color: 'gray', font: NORMAL_FONT, z: 10
    )
    window.add(baide)
    
    # Pour les informations
    @binfo = Ruby2D::Text.new(
      "---", x: LEFT_MARG, y: HEIGHT - 60, color: 'blue', font: NORMAL_FONT, size: 20
    )
    window.add(@binfo)

    # Pour les textes principaux (la tâche par exemple)
    tache = alerte.content
    write(tache, window)



    # Le compteur
    noirc = Ruby2D::Color.new([0.3,0.3,0.3,1])
    bcompteur = Ruby2D::Text.new("0:00:00", size: 48, x: WIDTH - 260, y: 10, color: noirc, font: "resources/fonts/Courier.ttf")
    window.add(bcompteur)

    window.on :key_down do |ev|
      case ev.key
      when 'o'
        @next_operation = -> { info alerte.open_folder }
        ask("Voulez-vous ouvrir le dossier de l’alerte ?")
      when 'x'
        @next_operation = -> { info alerte.run_script }
        ask("Voulez-vous jouer le script de l’alerte ?")
      when 'return', 'space' then
        if @next_operation
          @next_operation.call
          @next_operation = nil
          write(tache, window)
        end
      when 'escape'
        @next_operation = nil
        write(tache, window)
      when 'a', 'A' then 
        ask("Vous voulez quitter le programme ? (return/esc)")
        @next_operation = -> { window.close }
      when 's', 'S' then ask("Vous voulez faire une pause ? (return/esc)")
        @next_operation = -> { @stop_counter = true; ask("Frappez 'R' quand vous voudrez reprendre") }
      when 'r', 'R' then ask("Vous voulez reprendre ? (return/esc)")
        @next_operation = -> do 
          @stop_counter = false
          if alerte.deadline?
            @countdown = alerte.duration_refreshed
            msg = "La durée a été recalculée en fonction de l’échéance définie."
            info(msg)
          end
          write(tache, window)
        end
      when 'p', 'P' then 
        ask("Vous voulez revenir à la précédente ? (return/esc)")
      when 'n', 'N' then 
        ask("Vous voulez passer à la suivante ? (return/esc)")
      else puts "Vous avez pressé la touche #{ev.key}"
      end
    end
    @countdown = alerte.duration * 60
    window.update do # boucle toutes les secondes
      @countdown -= 1 unless @stop_counter
      if @countdown % 5 == 0
        bcompteur.text = @countdown.to_horloge
      end
      if @countdown < 0 && @countdown > -10
        set_fond(Ruby2D::Color.new([1,0,0,1]), 'white')
      elsif @countdown <= 60
        set_fond('orange', 'white')
      end
    end

    window.show

  end

  def set_fond(couleur, couleur_textes = 'black')
    @rect.color = couleur
    window.set_color_texts(couleur_textes)
  end

  # Écris le texte +texte+ dans la fenêtre +window+
  # (en tenant compte du fait qu'on ne peut pas enrouler du texte
  #  avec Ruby2D, donc il faut créer des lignes successives)
  def write(texte, window, color = 'black')
    window.remove_all_text_blocs
    text_props = {size: 20, x: LEFT_MARG, y: 80, color: color, font: NORMAL_FONT}
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
  end

end
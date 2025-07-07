
module Ruby2D
  class Window
    def add_text_bloc(btext)
      @text_blocs ||= []
      @text_blocs << btext
    end
    def remove_all_text_blocs
      return if @text_blocs.nil? || @text_blocs.empty?
      @text_blocs.each {|tb| remove(tb)}
      @text_blocs = []
    end
  end
end

class Ruby2DClass
  attr_reader :window
  require 'ruby2d'
  include Ruby2D
  WIDTH  = 800
  HEIGHT = 600
  NORMAL_FONT = "resources/fonts/NunitoSans.ttf"
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
    baide = Ruby2D::Text.new(
      "[S]top [N]ext [P]revious [Q]uitter [R]un the task [H]elp",
      x: 100, y: HEIGHT - 30, color: 'gray', font: NORMAL_FONT, z: 10
    )
    window.add(baide)

    # Pour les messages
    tache = "C'est mon premier message avec ruby2d. Je vais volontairement un long message pour voir comment il va se comporter par rapport à la fenêtre entière."
    write(tache, window)

    # Le compteur
    noirc = Ruby2D::Color.new([0.3,0.3,0.3,1])
    bcompteur = Ruby2D::Text.new("0:00:00", size: 48, x: WIDTH - 300, y: 10, color: noirc, font: "resources/fonts/Courier.ttf")
    window.add(bcompteur)

    window.on :key_down do |ev|
      case ev.key
      when 'o', 'O', 'return', 'space' then
        if @next_operation
          @next_operation.call
          @next_operation = nil
        end
      when 'escape'
        @next_operation = nil
        write(tache, window)
      when 'a', 'A' then 
        write("Vous voulez quitter le programme ? (o/esc)", window)
        @next_operation = -> { window.close }
      when 's', 'S' then write("Vous voulez faire une pause ? (o/esc)", window)
        @next_operation = -> { @stop_counter = true; write("Frappez 'R' quand vous voudrez reprendre", window) }
      when 'r', 'R' then write("Vous voulez reprendre ? (o/esc)", window)
        @next_operation = -> { @stop_counter = false; write(tache, window) }
      when 'p', 'P' then 
        write("Vous voulez revenir à la précédente ? (o/esc)", window)
      when 'n', 'N' then 
        write("Vous voulez passer à la suivante ? (o/esc)", window)
      else puts "Vous avez pressé la touche #{ev.key}"
      end
    end
    counter = 0
    countdown = 100
    window.update do # boucle toutes les secondes
      counter += 1
      countdown -= 1 unless @stop_counter
      bcompteur.text = countdown.to_horloge
      if countdown < -60
        window.close
      elsif countdown <= 0
        btext.text = "On est arrivé au bout."
        btext.color = 'white'
        @rect.color = Ruby2D::Color.new([1,0,0,1])
      elsif countdown <= 60
        @rect.color = 'orange'
        btext.color = 'white'
      end
    end

    window.show

  end

  # Écris le texte +texte+ dans la fenêtre +window+
  # (en tenant compte du fait qu'on ne peut pas enrouler du texte
  #  avec Ruby2D, donc il faut créer des lignes successives)
  def write(texte, window)
    window.remove_all_text_blocs
    text_props = {size: 20, x: 10, y: 80, color: 'black', font: NORMAL_FONT}
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
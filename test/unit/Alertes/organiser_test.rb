require "test_helper"
class AlertesOrganiserTest < Test::Unit::TestCase

  # Méthode pour calculer rapidement un temps
  # Par exemple 'in_(1, :hour)' retourne le temps dans une heure de maintenant
  def in_(quantite, unite)
    now = Time.now
    secs = case unite
    when :hour then 3600
    when :day  then 3600 * 24
    when :minute then 60
    when :second then 1
    end * quantite
    tim = now + secs

    tim.strftime(Time::TIME_FORMAT)#.tap{|res| puts "-> #{res.inspect}"}
  end

  def new_alerte(msg, duree, headline = nil, deadline = nil, extra_data = {})
    minidata = {content: msg, duration: duree, headline: headline, deadline: deadline}
    minidata.merge!(extra_data)
    Alertes::Alerte.new(minidata)
  end

  # "La méthode Alertes.organiser"

  test "existe" do
    assert Alertes.respond_to?(:organiser)
  end
  test "attend une liste d'alertes" do
    assert_raise ArgumentError do
      Alertes.organiser
    end
    assert_raise ArgumentError do
      Alertes.organiser("string")
    end
    assert_raise ArgumentError do
      Alertes.organiser([nil, "string"])
    end
  end

  test "traite une liste sans échéance" do
    alertes = [
      new_alerte("Première", 120, nil),
      new_alerte("Deuxième", 60, nil),
      new_alerte("Troisième", 30, nil)
    ]
    alertes_sorted = Alertes.organiser(alertes, {interactive: false})

    assert( alertes_sorted[0] == alertes[0])
    assert( alertes_sorted[1] == alertes[1])
    assert( alertes_sorted[2] == alertes[2])
  end

  test "traite une liste avec bonnes échéances" do
    alertes = [
      new_alerte("Échéance de fin", 30, in_(4, :hour)),
      new_alerte("Échéance ensuite", 30, in_(1, :hour)),
      new_alerte("Échéance première", 30, in_(30, :minute))
    ]
    sorted = Alertes.organiser(alertes, {interactive: false})

    assert( alertes[0] == sorted[2])
    assert( alertes[1] == sorted[1])
    assert( alertes[2] == sorted[0])

  end

  test "retire les échéances des jours précédents" do

  end

  test "glisse les sans échéances entre les échéances si possible" do
    ale = [
      new_alerte("Doit être en dernier", 30, in_(4, :hour)),
      new_alerte("Doit être en premier", 30, in_(1, :hour)),
      new_alerte("Doit s'intercaler", 120)
    ]
    sor = Alertes.organiser(ale, {interactive: false})
    # puts "SOR = #{sor}"

    assert sor.count == 3
    assert sor[0].id == ale[1].id
    assert sor[1].id == ale[2].id
    assert sor[2].id == ale[0].id
  end

  test "sans échéance mise à la fin si durée trop longue" do
    ale = [
      new_alerte("Doit être en deuxième", 45, in_(2, :hour)),
      new_alerte("Doit être en troisième", 120),
      new_alerte("Soit être en premier", 60, in_(1, :hour))
    ]
    sor = Alertes.organiser(ale, {interactive: false})

    assert sor.count == 3
    assert sor[0].id == ale[2].id
    assert sor[1].id == ale[0].id
    assert sor[2].id == ale[1].id
  end

  test "découpe tâche sans échéance si paramètre le permet" do

    ale = [
      new_alerte("Doit être en troisième", 45, in_(2, :hour)),
      new_alerte("Doit être découpé en deuxième et quatrième", 120),
      new_alerte("Soit être en premier", 45, in_(1, :hour))
    ]
    sor = Alertes.organiser(ale, {allow_cut_task: true})

    assert(sor.count == 4)

    assert( sor[0].id == ale[2].id)
    assert( sor[1].id == "#{ale[1].id}.2")
    assert( sor[2].id == ale[0].id)
    assert( sor[3].id == ale[1].id)
    assert( sor[1].duration == 15, "La durée devrait être de 15, elle vaut #{sor[1].duration}")
    assert( sor[3].duration == 105, "La durée devrait être de 105, elle vaut #{sor[3].duration}")

  end


end

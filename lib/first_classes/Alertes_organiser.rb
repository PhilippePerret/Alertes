=begin
Module dédié au classement des alertes donc la méthode :

  Alertes.organiser(<alertes>)

=end
class Alertes
class << self

  def organiser(alertes, options = {})
    alertes.is_a?(Array) && alertes[0].is_a?(Alertes::Alerte) || begin
      raise(ArgumentError, "On doit transmettre à Alertes::organiser une liste d'alertes.")
    end
    # On commence par les classer par échéances
    # Les tâches sans échéances sont retirées
    sans_echeances = 
      alertes
        .each.with_index { |a, i| a.id = i}
        .select { |a| a.headline.nil? }
        .sort_by { |a| a.duration }
        .reverse

    avec_echeances = 
    alertes
    .reject   { |a| a.headline.nil? }
    .sort_by  { |a| a.headline.as_time }

    if sans_echeances.any?
      # S'il y a des tâches sans échéances, on essaie de les glisser
      # entre les tâches

      # Au besoin, on demande si on peut découper (l'information
      # a pu être donnée à la méthode — par les options)
      unless options.key?(:allow_cut_task) || options[:interactive] === false
        if Q.yes?("Puis-je découper les tâches sans échéance pour les glisser entre deux tâches à heure fixe ?".jaune)
          options.store(:allow_cut_task, true)
        end
      end

      (1..avec_echeances.length-1).each do |i|
        prev = avec_echeances[i - 1]
        curr = avec_echeances[i]
        laps = ((curr.headline.as_time - prev.deadline_time) / 60).round
        # puts "laps: #{laps.inspect}"
        sanseches = Marshal.load(Marshal.dump(sans_echeances))
        bonneeche = nil
        if laps > 0
          # On cherche une étape qu'on peut glisser là
          while true
            sanseche = sanseches.pop
            if sanseche.duration <= laps
              bonneeche = sanseche
              break
            elsif options[:allow_cut_task]
              # Si on permet de découper la tâche
              bonneeche = Alerte.new(sanseche.data)
              bonneeche.id = "#{sanseche.id}.2" 
              bonneeche.duration = laps
              sans_echeances.each do |a|
                if a.id == sanseche.id
                  a.duration = a.duration - laps
                  break
                end
              end
              break
            end
            break if sanseches.empty?
          end 
        end
        unless bonneeche.nil?
          # puts "On en a trouvé une"
          # On a trouvé une tâche pour se glisser entre les 
          # deux
          avec_echeances = avec_echeances.insert(i, bonneeche)
          # puts "avec_echeances: #{avec_echeances}"
          sans_echeances.delete_if { |a| a.id == bonneeche.id }
          # puts "sans_echeances: #{sans_echeances}"
        end
      end
    end
    
    return avec_echeances + sans_echeances

  end

end #/class << self
end #/Alertes
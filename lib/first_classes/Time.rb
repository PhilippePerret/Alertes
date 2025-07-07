class Time

TIME_FORMAT = '%Y-%m-%d %H:%M:%S'

class << self

  def start_of_today
    @start_of_today ||= Time.new(now.year, now.month, now.day, 0, 0, 0)
  end
  def end_of_today
    @end_of_today ||= Time.new(now.year, now.month, now.day, 23, 59, 59)
  end

end #/class << self
end
class Integer
  def to_horloge
    h = self / 3600
    r = self - h * 3600
    m = r / 60 ; 
    r = r - m * 60
    m = m < 10 ? "0#{m}" : m
    r = r < 10 ? "0#{r}" : r
    if h > 0
      "#{h}:#{m}:#{r}"
    else
      "  #{m}:#{r}"
    end
  end
  def to8; self.to_s.to8 end # "0:12:23" => "00:12:23"
  def to2; self.to_s.to2 end # 2 => "02", 10 => "10"
end
class String

  def to8; self.rjust(8,'0') end
  def to2; self.rjust(2,'0') end

  def to_full_horloge(no_seconde: false)
    if :no_seconde
      secondes = 0
      minutes, heures = self.split(/[,\:]/).map{|s|s.strip.to_i}.reverse
    else
      secondes, minutes, heures = self.split(/[,\:]/).map{|s|s.strip.to_i}.reverse
    end
    minutes ||= 0
    heures  ||= 0
    "#{heures}:#{minutes.to_s.rjust(2,'0')}:#{secondes.to_s.rjust(2,'0')}"
  end
  
  def to_minutes
    if self.match?(/[,\:]/)
      secondes, minutes, heures = self.split(/[,\:]/).map{|s|s.strip.to_i}.reverse
      minutes ||= 0
      heures  ||= 0
      secondes / 60 + minutes + heures * 60
    else
      self.to_i
    end
  end

  REG_TIME1 = /(\d{4})\/(\d{2})\/(\d{2}) (\d{2})\:(\d{2})\:(\d{2})/.freeze
  REG_TIME2 = /(\d{4})\-(\d{2})\-(\d{2}) (\d{2})\:(\d{2})\:(\d{2})/.freeze

  def is_time?
    self.match?(REG_TIME1) || self.match?(REG_TIME2)
  end

  def as_time
    self.is_time? || begin
      raise "Temps #{self} mal défini. Il faut 'AAAA-MM-JJ HH:MM:SS'"
    end
    temps = if self.match?(REG_TIME1)
      self.gsub(/\//, '-')
    else 
      self 
    end
    Time.new(temps)
  end

  # Quand self est un temps impartiel
  def fill_in_as_time
    now = Time.now
    date, horloge = self.split(' ')
    date, horloge = [horloge, date] if date.match?(/\:/)

    heures, minutes, secondes = (horloge||"").split(':').map{|s| s.strip.to2}
    heures    = (heures  || now.hour).to2
    minutes   = (minutes || now.min).to2
    secondes  = (secondes||= "0").to2

    jour, mois, annee = (date||"").split(/[\-\/]/).reverse
    annee ||= now.year.to_s
    annee = "20#{annee}" if annee.length == 2
    mois = (mois || now.month).to2
    jour  = (jour || now.day).to2
    "#{annee}-#{mois}-#{jour} #{heures}:#{minutes}:#{secondes}"
  end
end
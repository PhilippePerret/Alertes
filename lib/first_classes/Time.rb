class Time
class << self
end #/class << self
end
class Integer
  def to_horloge
    h = self / 3600
    r = self - h * 3600
    m = r / 60 ; 
    r = r - m * 60
    m = m > 10 ? m : "0#{m}"
    r = r > 10 ? r : "0#{r}"
    if h > 0
      "#{h}:#{m}:#{r}"
    else
      "  #{m}:#{r}"
    end
  end
end
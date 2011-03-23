class Point
  attr_reader :x, :y
  def initialize(x, y)
    @x, @y = x, y
  end
  def <=>(other)
    angle <=> other.angle
  end
  
  def angle
    result = Math::atan2(y,x) rescue 0.0
    result += Math::PI * 2 if result < 0
    result
  end
  include Comparable
end


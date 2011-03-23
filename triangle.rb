require File.expand_path('../point', __FILE__)

class Triangle
  def initialize(p0, p1, p2)
    @vertices = [p0, p1, p2].sort
  end

  def area
    unless @area
      result = 0
      @vertices.each_cons(2) do |a, b|
        result += a.x*b.y - b.x*a.y
      end
      @area = result / 2.0    
    end
    @area
  end
  
  # special-case of isosceles triangle
  #
  class Triangle::Preisach < self
    attr_reader :x0, :x1
    def initialize(x0, x1)
      @x0, @x1 = [x0, x1].sort
      super(Point.new(@x0, @x0), Point.new(@x0, @x1), Point.new(@x1, @x1))
    end

    def areaz
      #(@x1 - @x0)**0.25 / 2.0
      #(@x1 - @x0)**2 / 2.0
      #(@x1 - @x0)**6 / 2.0
      b = (@x1 - @x0)**2 / 2.0
      #b * Math::atan(@x1)
    end
    
    alias y0 x0
    alias y1 x1
  end

end

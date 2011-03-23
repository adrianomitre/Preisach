#!/usr/bin/env ruby

require File.expand_path('../hysteron', __FILE__)
require File.expand_path('../triangle', __FILE__)

=begin
  TODO: usar mais hipóteses do problema, ex:
    * triângulos retângulos, com lado paralelos aos eixos
      + isso acelera tanto a ordenação dos vértices (não precisa de atan) 
      + qto o cálculo da área
=end

class Preisach2
  def initialize
    @prev_x = 0
  end
  def update(x)
    if x >= @prev_x
      area = x**2/2.0
    else
      area = 0.5 - (1-x)**2/2.0
    end
    @prev_x = x
    area * 2
  end
end

class Preisach
  def initialize(n=3)
    eps = 1.0e-5
    @h = []
    dx = 1/(n-1.0)
    0.step 1, dx do |x|
      dy = (1.0+eps-x)/(n-1.0)
      x.step 1.0, dy do |y|
        @h << Hysteron.new(x, y)
      end
    end
  end
  def update(x)
    @h.inject(0) {|s,k| s + k.update(x) }.to_f / @h.size
  end
end

class PreisachFast
  def initialize
    reset
  end
  
  def reset
    @prev_x = 0
    @triangles = [Triangle::Preisach.new(0, 0)]
  end
  
  def update(*x)
    x.flatten!
    if x.size > 1
      return x.map {|item| update(item) }
    end
    x = x.first
    
    if x >= @prev_x
      ts = @triangles.select {|t| t.y1 <= x }
      unless ts.empty?
        tss = ts.select {|t| @triangles.index(t) % 2 == 0 }
        #p :YEAH if tss != ts
        @prev_x = tss.map {|t| t.x0 }.min unless tss.empty?
        @triangles -= ts
      end
    else
      ts = @triangles.select {|t| t.x0 >= x && t.x0 > 0 }
      unless ts.empty?
        tss = ts.select {|t| @triangles.index(t) % 2 == 1 }
        #p :YEAH if tss != ts
        @prev_x = tss.map {|t| t.y1 }.max unless tss.empty?
        @triangles -= ts
      end
    end
    @triangles << Triangle::Preisach.new(@prev_x, x)
    @prev_x = x
    tot_area = 0
    @triangles.each_with_index do |t, n|
      tot_area += t.area * (n % 2 == 0 ? 1 : -1)
    end
    #p @triangles.size
    #p @triangles
    tot_area * 2
  end
  
  alias << update
  
  # Compute the area of the polygon from its vertices using Surveyor's Formula
  # The vertices must be ordered clockwise or counterclockwise; if they are
  # ordered counterclockwise, the area will be negative but correct in absolute
  # value.
  #
  def self.area_polygon(points)
    result = 0
    points.each_cons(2) do |a, b|
      result += a[0]*b[1] - b[0]*a[1]
    end
    result / 2.0
  end

  def calc_area(x)
    p = @points.clone
    case orientation
    when :increasing
      p << [@last_x, x]
      p << [x, x]
    when :decreasing    
      @points << [@last_x, x]
      @points << [x, x]
    end
    tot_area = 0
    pair = []
    t = [0] + @turns.clone + [x]
    until t.empty?
      pair << t.shift
      pair.shift
      curr_area = (pair[0] - pair[1]/2)*pair[1]
      tot_area += curr_area
    end
    tot_area += x*x/2.0
    tot_area
  end
end

def sat(x, a=1, b=2); x < 0 ? tanh(a*x)/a.to_f : tanh(b*x)/b.to_f; end
def f(x); x*0.5+0.5; end
def g(x); x*2-1; end

if $0 == __FILE__
  opt = :new
  case opt
  when :orig
    include Math
    n = 1024
    xs = 1.upto(n).to_a
    ys = xs.map {|x| sin(2 * PI * x / n) }
    pr = PreisachFast.new
    #u = ys.map {|y| pr.update(y) }
    a=1; b=4
    u = ys.map {|y| g( pr.update( f(sat(y, a, b)) ) ) }
    v = ys.map {|y| sat(y, a, b) }
    rise, fall = xs.zip(u), xs.zip(v)
  when :new
    n = 1024
    xs = 0.step(1, 1.0/(n-1)).to_a
    pr = PreisachFast.new
    rise = xs.map {|x| [x, pr.update(x)] }
    fall = xs.reverse.map {|x| [x, pr.update(x)] }
  end
  begin
    require 'easy_plot'
    EasyPlot.plot rise, fall
  rescue
    File.open('/tmp/preisach3.dat','w') {|f| xs.zip(u).each {|pair| f.puts pair.join(' ') } }
  end
end


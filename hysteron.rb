class Hysteron
  On = 1
  Off = 0
  def initialize(off_thr, on_thr, ini_state=Off)
    on_thr >= off_thr or raise ArgumentError, 'on_thr must be >= off_thr'
    @on_thr, @off_thr = on_thr, off_thr
    @prev_state = ini_state
  end

  def update(x)
    if x >= @on_thr
      @prev_state = On
    elsif x <= @off_thr
      @prev_state = Off
    else
      @prev_state
    end
  end

  def turn_on; @prev_state = On; end
  def turn_off; @prev_state = Off; end
end


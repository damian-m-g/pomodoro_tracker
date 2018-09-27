# An instance of this class knows how to interpret if there's an Arduino connected, also can speak to it.
class ArduinoInterpreter

  attr_reader :sp

  # @param serial_port [String]
  # @return [TrueClass, FalseClass]
  # Try to synchronize with Arduino.
  def arduino_present?(serial_port)
    puts("Seeking #{serial_port} opened...")
    @sp = Serial.new(serial_port)
    puts("#{serial_port} opened.")
    true
  rescue RubySerial::Exception
    # there is nothing connected on *serial_port*
    puts("#{serial_port} not opened.")
    false
  end

  def close_stream
    if(@sp)
      @sp.close
    end
  rescue Exception
    nil
  end

=begin
  EVENTS
=end

  # Arduino understand this message but never used(by now).
  def make_system_on_light_game
    @sp.write('MSOLG-')
  end

  def make_pomodoro_finished_light_game
    @sp.write('MPFLG-')
  end

  def make_pomodoro_n_12_finished_light_game
    @sp.write('MPN12FLG-')
  end

  def make_pomodoro_n_22_finished_light_game
    @sp.write('MPN22FLG-')
  end

  def make_break_finished_light_game
    @sp.write('MBFLG-')
  end

  def sound_sad_buzzer
    @sp.write('SSB-')
  end

  def sound_happy_buzzer
    @sp.write('SHB-')
  end

=begin
  STATES
=end

  # @param state [Symbol]
  # @param pomodoros_finished [Fixnum]
  # @param current_counting [Fixnum]
  # *state* is one of :running, :break or :stopped.
  def transmit_status(state, pomodoros_finished = 0, current_counting = 0)
    # be sure that *pomodoros_finished* isn't bigger than 99
    if(pomodoros_finished > 99)
      pomodoros_finished = ((pomodoros_finished % 99) + 3)
      if(pomodoros_finished > 99)
        pomodoros_finished = ((pomodoros_finished % 99) + 3)
      end
    end
    # judge state
    case(state)
      when(:running)
        @sp.write("#{format("%02i", pomodoros_finished)}R#{format("%04i", current_counting)}-")
      when(:break)
        @sp.write("#{format("%02i", pomodoros_finished)}B#{format("%04i", current_counting)}-")
      when(:stopped)
        @sp.write("#{format("%02i", pomodoros_finished)}S0000-")
    end
  end
end
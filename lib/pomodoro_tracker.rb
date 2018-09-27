### CODED BY DAMIAN M. GONZALEZ ###

# external libraries
require 'fox16'
include Fox
require 'rubyserial'
require 'fastimage'
require 'date'
require 'win32/clipboard'
require 'win32/mutex'

# source code
require_relative './pomodoro_tracker/v_fxgui'
require_relative './pomodoro_tracker/v_fxcolor'
require_relative './pomodoro_tracker/v_fxpainter'
require_relative './pomodoro_tracker/m_pomodoro_tracker'
require_relative './pomodoro_tracker/m_pomodoro_system'
require_relative './pomodoro_tracker/m_pomodoro'
require_relative './pomodoro_tracker/m_break'
require_relative './pomodoro_tracker/m_arduino_interpreter'
require_relative './pomodoro_tracker/m_gamification'
require_relative './pomodoro_tracker/m_reward'
require_relative '../ext/autoit-ffi'

# prevent ocra to execute the app when compiling
if(defined?(Ocra))
  exit()
else
  begin
    # invoque a mutex so no more than one pt app can be opned at same time
    mx = Win32::Mutex.new(true, 'Pomodoro Tracker', false)
    begin
      mx.wait
      pt = PomodoroTracker.new()
    ensure
      # make sure arduino channel get closed before leaving
      if(pt.arduino_connected rescue nil)
        pt.arduino_interpreter.transmit_status(:stopped)
        pt.arduino_interpreter.close_stream()
      end
      # release mutex
      mx.release
    end
  rescue RuntimeError => e
    warn(e.message)
    warn(e.backtrace)
    warn('Please take a screen-capture and send it to the programmer.')
    sleep(60)
    exit!()
  end
end
class Break

  attr_reader :start_time, :long, :current_counting

  # @param pomodoro_system [PomodoroSystem], @param long [TrueClass or FalseClass].
  def initialize(pomodoro_system, long = false)
    @long = long
    # note the delay, that is to synchronize well with the GUI
    @start_time = Time.now + 4.5
    @current_counting = 0
    @pomodoro_system = pomodoro_system
  end

  # @return [TrueClass or FalseClass]. Changes value of *@current_counting* but it also checks for overdue time. Returns true if break has finished.
  def increase_counter
    @current_counting = (Time.now - @start_time).floor
    if(@long)
      if(@current_counting >= 900)
        # break finished
        finish()
        @pomodoro_system.current_break_finished()
        return(true)
      else
        # send data to arduino, if present
        if(@pomodoro_system.pomodoro_tracker.arduino_connected)
          @pomodoro_system.pomodoro_tracker.arduino_interpreter.transmit_status(:break, @pomodoro_system.pomodoros_finished[:working_day], @current_counting)
        end
        return(false)
      end
    else
      if(@current_counting >= 300)
        # break finished
        finish()
        @pomodoro_system.current_break_finished()
        return(true)
      else
        # send data to arduino, if present
        if(@pomodoro_system.pomodoro_tracker.arduino_connected)
          @pomodoro_system.pomodoro_tracker.arduino_interpreter.transmit_status(:break, @pomodoro_system.pomodoros_finished[:working_day], @current_counting)
        end
        return(false)
      end
    end
  end

  # Stop this break.
  def stop
    @stop_time = Time.now
  end

  # @return [TrueClass or FalseClass]. Has this break finished?
  def finished?
    if(@finished_time)
      true
    else
      false
    end
  end

  # Hooker. Specific serialization.
  def marshal_dump
    [@start_time, @long, @current_counting]
  end

  # Hooker. Specific serialization.
  def marshal_load(obj)
    @start_time, @long, @current_counting = obj
  end

  private

  # This break has been totally completed.
  def finish
    @finished_time = Time.now
  end
end
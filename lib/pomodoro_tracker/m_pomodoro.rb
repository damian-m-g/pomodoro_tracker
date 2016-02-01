class Pomodoro

  attr_accessor :consecutive, :current_counting, :stop_time, :start_time, :proyect, :finished_time

  # @param pomodoro_system [PomodoroSystem], @param proyect [String], @param consecutive [TrueClass or FalseClass].
  def initialize(pomodoro_system, proyect, consecutive)
    # measured in seconds
    @start_time = Time.now
    @current_counting = 0
    @pomodoro_system = pomodoro_system #: PomodoroSystem
    @proyect = proyect #: String
    @consecutive = consecutive #: FalseClass or TrueClass
  end

  # @return [TrueClass or FalseClass]. Changes value of *@current_counting* but it also checks for overdue time. Returns true if pomodoro has finished.
  def increase_counter()
    @current_counting = (Time.now - @start_time).floor
    if(@current_counting >= 1500)
      # pomodoro has finished
      finish()
      @pomodoro_system.current_pomodoro_finished()
      return(true)
    else
      # send data to arduino, if present
      if(@pomodoro_system.pomodoro_tracker.arduino_connected)
        @pomodoro_system.pomodoro_tracker.arduino_interpreter.transmit_status(:running, @pomodoro_system.pomodoros_finished[:working_day], @current_counting)
      end
      return(false)
    end
  end

  # Stop this pomodoro.
  def stop
    @stop_time = Time.now
  end

  # Hooker. Specific serialization.
  def marshal_dump
    [@start_time, @current_counting, @proyect, @consecutive, @finished_time, @stop_time]
  end

  # Hooker. Specific serialization.
  def marshal_load(obj)
    @start_time, @current_counting, @proyect, @consecutive, @finished_time, @stop_time = obj
  end

  private

  # This pomodoro has been completed.
  def finish
    @finished_time = Time.now
  end
end
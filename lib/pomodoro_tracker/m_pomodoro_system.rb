# An instance of this class is a wise robot that knows a lot about how to deal with pomodoros data.
class PomodoroSystem

  # *current_project* is a #String or #NilClass. On each hash the projects are saved as symbols.
  # there is no need to persist the @current_pomodoro
  # last break remains on RAM, even if isn't running
  attr_accessor :pomodoros_finished, :pomodoros_stopped, :breaks_completed, :breaks_stopped, :consecutive_pomodoros, :stop_time_rate_of_pomodoros, :all_pomodoros, :current_project, :current_pomodoro, :current_break, :pomodoro_tracker

  # @param persisted_data [Array, NilClass]
  # @param pomodoro_tracker [PomodoroTracker]
  def initialize(persisted_data, pomodoro_tracker)
    @pomodoro_tracker = pomodoro_tracker
    if(persisted_data)
      load_persisted_data(persisted_data)
    else
      start_fresh()
    end
  end

  # New working day.
  def reset_working_day
    [@pomodoros_finished, @pomodoros_stopped, @breaks_completed, @breaks_stopped, @consecutive_pomodoros].each do |data|
      data[:working_day] = 0
    end
    @stop_time_rate_of_pomodoros[:working_day] = nil
    @all_pomodoros[:working_day] = []
  end

  # @return [Array]
  def build_package_to_persist
    package = []
    [@pomodoros_finished, @pomodoros_stopped, @breaks_completed, @breaks_stopped, @consecutive_pomodoros, @stop_time_rate_of_pomodoros, @all_pomodoros, @current_project].each do |data|
      package << data
    end
    return(package)
  end

  # Initialize a new pomodoro.
  def pomodoro_started
    # check if this is going to be a consecutive pomodoro
    consecutive_pomodoro = is_next_pomodoro_going_to_be_consecutive?
    # create instance
    @current_pomodoro = Pomodoro.new(self, @current_project, consecutive_pomodoro)
  end

  # The current pomodoro has finished.
  def current_pomodoro_finished
    @pomodoros_finished[@current_project.to_sym] += 1 rescue nil
    @pomodoros_finished[:working_day] += 1
    # send data to arduino if present
    if(@pomodoro_tracker.arduino_connected)
      @pomodoro_tracker.arduino_interpreter.sound_happy_buzzer()
      case(@pomodoros_finished[:working_day])
        when(12)
          @pomodoro_tracker.arduino_interpreter.make_pomodoro_n_12_finished_light_game()
        when(22)
          @pomodoro_tracker.arduino_interpreter.make_pomodoro_n_22_finished_light_game()
        else
          @pomodoro_tracker.arduino_interpreter.make_pomodoro_finished_light_game()
      end
    end
    # continue updating
    @pomodoros_finished[:global] += 1
    @all_pomodoros[@current_project.to_sym] << @current_pomodoro rescue nil
    @all_pomodoros[:global] << @current_pomodoro
    @all_pomodoros[:working_day] << @current_pomodoro
    # is this a consecutive pomodoro?
    if(@current_pomodoro.consecutive)
      @consecutive_pomodoros[@current_project.to_sym] += 1 rescue nil
      @consecutive_pomodoros[:working_day] += 1
      @consecutive_pomodoros[:global] += 1
      # raise gold
      @pomodoro_tracker.gamification.raise_gold(2)
    else
      # raise gold
      @pomodoro_tracker.gamification.raise_gold(1)
    end
    # reset placeholder
    @current_pomodoro = nil
    # start the break
    start_break()
  end

  # A break has started.
  def start_break
    # check out if this should be a long or short break
    if((@pomodoros_finished[:working_day] % 4) == 0)
      # long
      @current_break = Break.new(self, true)
    else
      # short
      @current_break = Break.new(self, false)
    end
  end

  # The current break has finished.
  def current_break_finished
    if(@pomodoro_tracker.arduino_connected)
      @pomodoro_tracker.arduino_interpreter.make_break_finished_light_game()
    end
    @breaks_completed[@current_project.to_sym] += 1 rescue nil
    @breaks_completed[:working_day] += 1
    @breaks_completed[:global] += 1
  end

  # Current pomodoro has been stopped.
  def pomodoro_stopped
    # if arduino present, sound sad buzzer
    if(@pomodoro_tracker.arduino_connected)
      @pomodoro_tracker.arduino_interpreter.sound_sad_buzzer()
    end
    @current_pomodoro.stop()
    @pomodoros_stopped[@current_project.to_sym] += 1 rescue nil
    @pomodoros_stopped[:global] += 1
    @pomodoros_stopped[:working_day] += 1
    @all_pomodoros[@current_project.to_sym] << @current_pomodoro rescue nil
    @all_pomodoros[:global] << @current_pomodoro
    @all_pomodoros[:working_day] << @current_pomodoro
    @pomodoro_tracker.gamification.raise_gold(-1)
    recalculate_stop_time_rate_of_pomodoros()
  end

  # Current break has been stopped.
  def break_stopped
    @current_break.stop()
    @breaks_stopped[@current_project.to_sym] += 1 rescue nil
    @breaks_stopped[:global] += 1
    @breaks_stopped[:working_day] += 1
  end

  # @param name [String, Symbol]
  # @return [TrueClass or FalseClass]
  def exists_project?(name)
    @all_pomodoros.has_key?(name.to_sym)
  end

  # @param name [String]
  def add_new_project(name)
    name_as_sym = name.to_sym
    @pomodoros_finished[name_as_sym] = 0
    @pomodoros_stopped[name_as_sym] = 0
    @breaks_completed[name_as_sym] = 0
    @breaks_stopped[name_as_sym] = 0
    @consecutive_pomodoros[name_as_sym] = 0
    @stop_time_rate_of_pomodoros[name_as_sym] = nil
    @all_pomodoros[name_as_sym] = []
    # be aware that if there's no current project this becomes the one
    if(!@current_project) then @current_project = name end
  end

  # @param name [String, Symbol]
  def delete_project(name = @current_project)
    name_as_sym = name.to_sym
    # erase all track of that project
    @pomodoros_finished.delete(name_as_sym)
    @pomodoros_stopped.delete(name_as_sym)
    @breaks_completed.delete(name_as_sym)
    @breaks_stopped.delete(name_as_sym)
    @consecutive_pomodoros.delete(name_as_sym)
    @stop_time_rate_of_pomodoros.delete(name_as_sym)
    @all_pomodoros.delete(name_as_sym)
    # if this is the current project clean the placeholder
    @current_project = nil
  end

  def try_select_random_project_as_current
    projects = @all_pomodoros.keys.select {|p| (p != :global) && (p != :working_day)}
    _current_project = projects.sample
    if(_current_project) then @current_project = _current_project.to_s else @current_project = nil end
  end

  # @param project [String, Symbol]
  def change_current_project(project)
    @current_project = project.to_s
  end

  # @return [Array]
  def show_me_greater_amount_of_pomodoros_completed_on_last_7_days
    unsorted_summary = []
    @all_pomodoros.each_pair do |project, pomodoros|
      if((project == :global) || (project == :working_day)) then next end
      pomodoros_finished = 0
      pomodoros.each do |pomodoro|
        if((pomodoro.finished_time) && ((Time.now - pomodoro.finished_time) <= 604800))
          pomodoros_finished += 1
        end
      end
      unsorted_summary << [project.to_s, pomodoros_finished]
    end
    # sort
    unsorted_summary.sort {|a, b| b[1] <=> a[1]}
  end

  # @return [Array]
  def show_me_greater_amount_of_pomodoros_interrupted_on_last_7_days
    unsorted_summary = []
    @all_pomodoros.each_pair do |project, pomodoros|
      if((project == :global) || (project == :working_day)) then next end
      pomodoros_interrupted = 0
      pomodoros.each do |pomodoro|
        if((!pomodoro.finished_time) && ((Time.now - pomodoro.stop_time) <= 604800))
          pomodoros_interrupted += 1
        end
      end
      unsorted_summary << [project.to_s, pomodoros_interrupted]
    end
    # sort
    unsorted_summary.sort {|a, b| b[1] <=> a[1]}
  end

  # @return [Array]
  def show_me_greater_amount_of_consecutive_pomodoros_completed_on_last_7_days
    unsorted_summary = []
    @all_pomodoros.each_pair do |project, pomodoros|
      if((project == :global) || (project == :working_day)) then next end
      consecutive_pomodoros_finished = 0
      pomodoros.each do |pomodoro|
        if((pomodoro.finished_time) && (pomodoro.consecutive) && ((Time.now - pomodoro.finished_time) <= 604800))
          consecutive_pomodoros_finished += 1
        end
      end
      unsorted_summary << [project.to_s, consecutive_pomodoros_finished]
    end
    # sort
    unsorted_summary.sort {|a, b| b[1] <=> a[1]}
  end

  # @return [Array]
  def show_me_greater_amount_of_pomodoros_completed_ever
    unsorted_summary = []
    @all_pomodoros.each_pair do |project, pomodoros|
      if((project == :global) || (project == :working_day)) then next end
      pomodoros_finished = 0
      pomodoros.each do |pomodoro|
        if(pomodoro.finished_time)
          pomodoros_finished += 1
        end
      end
      unsorted_summary << [project.to_s, pomodoros_finished]
    end
    # sort
    unsorted_summary.sort {|a, b| b[1] <=> a[1]}
  end

  # @return [Array]
  def show_me_greater_amount_of_pomodoros_interrupted_ever
    unsorted_summary = []
    @all_pomodoros.each_pair do |project, pomodoros|
      if((project == :global) || (project == :working_day)) then next end
      pomodoros_interrupted = 0
      pomodoros.each do |pomodoro|
        if(!pomodoro.finished_time)
          pomodoros_interrupted += 1
        end
      end
      unsorted_summary << [project.to_s, pomodoros_interrupted]
    end
    # sort
    unsorted_summary.sort {|a, b| b[1] <=> a[1]}
  end

  # @return [Array]
  def show_me_greater_amount_of_consecutive_pomodoros_completed_ever
    unsorted_summary = []
    @all_pomodoros.each_pair do |project, pomodoros|
      if((project == :global) || (project == :working_day)) then next end
      consecutive_pomodoros_finished = 0
      pomodoros.each do |pomodoro|
        if((pomodoro.finished_time) && (pomodoro.consecutive))
          consecutive_pomodoros_finished += 1
        end
      end
      unsorted_summary << [project.to_s, consecutive_pomodoros_finished]
    end
    # sort
    unsorted_summary.sort {|a, b| b[1] <=> a[1]}
  end

  # @return [NilClass, Array]
  def show_me_pomodoros_finished_on_last_twelve_weeks(project)
    if(@all_pomodoros.has_key?(project.to_sym))
      to_return = [] #: Array of Pomodoro
      last_twelve_weeks = ((Time.now.-(7_257_600))..(Time.now)) #: Range
      @all_pomodoros[project.to_sym].each do |p|
        if(p.finished_time && last_twelve_weeks.include?(p.finished_time))
          to_return << p
        end
      end
      to_return
    else
      nil
    end
  end

  # @return [NilClass, Array]
  def show_me_pomodoros_stopped_on_last_twelve_weeks(project)
    if(@all_pomodoros.has_key?(project.to_sym))
      to_return = [] #: Array of Pomodoro
      last_twelve_weeks = ((Time.now.-(7_257_600))..(Time.now)) #: Range
      @all_pomodoros[project.to_sym].each do |p|
        if(p.stop_time && last_twelve_weeks.include?(p.stop_time))
          to_return << p
        end
      end
      to_return
    else
      nil
    end
  end

  # @return [NilClass, Array]
  def show_me_consecutive_pomodoros_finished_on_last_twelve_weeks(project)
    if(@all_pomodoros.has_key?(project.to_sym))
      to_return = [] #: Array of Pomodoro
      last_twelve_weeks = ((Time.now.-(7_257_600))..(Time.now)) #: Range
      @all_pomodoros[project.to_sym].each do |p|
        if(p.finished_time && p.consecutive && last_twelve_weeks.include?(p.finished_time))
          to_return << p
        end
      end
      to_return
    else
      nil
    end
  end

  private

  # @param persisted_data [Array]
  # If there's some persisted data, load it into self.
  def load_persisted_data(persisted_data)
    @pomodoros_finished = persisted_data[0]
    @pomodoros_stopped = persisted_data[1]
    @breaks_completed = persisted_data[2]
    @breaks_stopped = persisted_data[3]
    @consecutive_pomodoros = persisted_data[4]
    @stop_time_rate_of_pomodoros = persisted_data[5]
    @all_pomodoros = persisted_data[6]
    @current_project = persisted_data[7]
  end

  # If there's not persisted data, initialize some variables to self.
  def start_fresh
    # general information
    @pomodoros_finished = {global: 0, working_day: 0}
    @pomodoros_stopped = {global: 0, working_day: 0}
    @breaks_completed = {global: 0, working_day: 0}
    @breaks_stopped = {global: 0, working_day: 0}
    @consecutive_pomodoros = {global: 0, working_day: 0}
    @stop_time_rate_of_pomodoros = {global: nil, working_day: nil}
    # specific information
    @all_pomodoros = {global: [], working_day: []}
    @current_project = nil
  end

  # @return [TrueClass, FalseClass]
  def is_next_pomodoro_going_to_be_consecutive?
    if(@current_break)
      start_time_of_last_break = @current_break.start_time #: Time
      current_time = Time.now #: Time
      time_difference = current_time - start_time_of_last_break
      if(@current_break.long)
        # have 16 minutes of deliverance
        if(time_difference <= 960)
          true
        else
          false
        end
      else
        # have 6 minutes of deliverance
        if(time_difference <= 360)
          true
        else
          false
        end
      end
    else
      false
    end
  end

  def recalculate_stop_time_rate_of_pomodoros
    interests = [:global, :working_day]
    if(@current_project) then interests.<<(@current_project.to_sym) end
    interests.each do |interest|
      accumulation = []
      @all_pomodoros[interest].each do |pomodoro|
        if(pomodoro.stop_time)
          accumulation << (pomodoro.stop_time - pomodoro.start_time)
        end
      end
      @stop_time_rate_of_pomodoros[interest] = (accumulation.inject(:+) / accumulation.size) / 60.0
    end
  end
end
# Main class of the program.
class PomodoroTracker

  DROPBOX_PATH = "#{ENV['HOME']}/Dropbox".gsub('\\', '/')
  PROGRAM_DATA_PATH = "#{ENV['ProgramData'] || ENV['ALLUSERSPROFILE']}".gsub('\\', '/')
  PROGRAM_DATA_PT_PATH = "#{PROGRAM_DATA_PATH}/Pomodoro Tracker"
  PERSISTED_DATA_FILENAME = 'pd.pt'
  VERSION = '1.0'
  BUG_REPORTS_AND_FEATURES_REQUEST_URI = 'https://github.com/IgorJorobus/pomodoro_tracker/issues'
  DONATIONS_URI = 'http://jorobuslab.net/main/en/pomodoro_tracker.html'
  JOROBUSLAB_WEBSITE = 'http://jorobuslab.net'

  # *dropbox_present* is #TrueClass or #FalseClass
  # *arduino_connected* is #TrueClass or #FalseClass
  # *arduino_interpreter* is #ArduinoInterpreter
  # *pomodoro_system* is #PomodoroSystem
  # *gamification* is Gamification
  attr_reader :dropbox_present, :arduino_connected, :arduino_interpreter, :pomodoro_system, :gamification
  # *serial_port_number* is String
  attr_accessor :serial_port_number

  def initialize
    # try to load persisted data
    @persisted_data = try_load_persisted_data()
    # check if data has been loaded from the cloud or locally
    if(@persisted_data)
      if(@persisted_data.length == 3)
        result = try_load_from_program_data()
        if(result)
          @serial_port_number = result[3]
        else
          @serial_port_number = 'COM3'
        end
      else
        if(@persisted_data[3])
          @serial_port_number = @persisted_data[3]
        else
          @serial_port_number = 'COM3'
        end
      end
    else
      @serial_port_number = 'COM3'
    end
    # initialize the brain
    @pomodoro_system = PomodoroSystem.new((@persisted_data[0] rescue nil), self)
    # initialize gamification
    @gamification = Gamification.new((@persisted_data[1] rescue nil), self)
    # see if the pomodoro tracker hardware is on
    @arduino_interpreter = ArduinoInterpreter.new()
    @arduino_connected = @arduino_interpreter.arduino_present?(@serial_port_number) #: TrueClass or FalseClass
    # start main loop
    FXGUI.new((@persisted_data[2] rescue nil), self)
  end

  # @return [TrueClass or FalseClass]. Persist important data on cloud if can, if not it does on local machine ProgramData folder. Returns true or false depending on if could have been saved or not.
  def persist_data
    # ask the @pomodoro_system for the package of data to persist
    package_0 = @pomodoro_system.build_package_to_persist()
    package_1 = @gamification.build_package_to_persist()
    package_2 = $fxgui.build_package_to_persist()
    package_3 = @serial_port_number
    # save on ProgramData
    if(!Dir.exists?(PROGRAM_DATA_PATH)) then(Dir.mkdir("#{ENV['HOMEDRIVE']}/ProgramData")) end
    if(!Dir.exists?(PROGRAM_DATA_PT_PATH)) then(Dir.mkdir(PROGRAM_DATA_PT_PATH)) end
    big_package = [package_0, package_1, package_2, package_3] #: Array
    File.open("#{PROGRAM_DATA_PT_PATH}/#{PERSISTED_DATA_FILENAME}", 'wb') do |f|
      Marshal.dump(big_package, f)
    end
    # if DropBox is present, then save to it too
    if(File.exists?(DROPBOX_PATH))
      File.open("#{DROPBOX_PATH}/#{PERSISTED_DATA_FILENAME}", 'wb') do |f|
        Marshal.dump(big_package, f)
      end
    end
    true
  rescue Exception
    false
  end

  # @param serial_port [String or NilClass]. This method and the button in GUI which trigger it could get deprecated soon.
  def synchronize_with_dropbox(serial_port = nil)
    persist_data()
    # refresh arduino status
    if(@arduino_interpreter.sp)
      @arduino_interpreter.close_stream()
      sleep(0.75)
      @arduino_connected = @arduino_interpreter.arduino_present?(@serial_port_number) #: TrueClass or FalseClass
    else
      @arduino_connected = @arduino_interpreter.arduino_present?(@serial_port_number) #: TrueClass or FalseClass
    end
  end

  private

  # @return [NilClass or Array]. Try to find the persisted data file and load its content. Returns nil if there is no persisted data, otherway returns the data obtained.
  def try_load_persisted_data
    # check if the folder exists
    if(File.exists?(DROPBOX_PATH))
      try_load_from_dropbox()
    elsif(File.exists?("#{PROGRAM_DATA_PT_PATH}/#{PERSISTED_DATA_FILENAME}"))
      puts("INFO: Seems that Dropbox isn't installed in this system. Checking if there's persisted data on Program Data.")
      try_load_from_program_data()
    else
      puts("INFO: Seems that Dropbox isn't installed in this system, neither has persisted data locally. The app will start fresh.")
      nil
    end
  end

  # @return [NilClass or Array]. Try to load from DropBox, if can't then pass responsability to ProgramData folder.
  def try_load_from_dropbox
    # see if any data is persisted there
    if(File.exists?(dbpd = "#{DROPBOX_PATH}/#{PERSISTED_DATA_FILENAME}"))
      # bring persisted data to RAM
      File.open(dbpd, 'rb') do |f|
        begin
          persisted_data = Marshal.load(f)
          f.close
          return(persisted_data)
        rescue Exception
          puts('WARNING: A problem arised while loading persisted data on DropBox. Seeking on ProgramData.')
          f.close
          try_load_from_program_data()
        end
      end
    else
      puts("INFO: There isn't a persisted data file on Dropbox. Seeking on ProgramData.")
      try_load_from_program_data()
    end
  end

  # @return [NilClass or Array]. Try to load data from ProgramData directory.
  def try_load_from_program_data
    if(File.exists?(pdpd = "#{PROGRAM_DATA_PT_PATH}/#{PERSISTED_DATA_FILENAME}"))
      # try the load
      File.open(pdpd, 'rb') do |f|
        begin
          persisted_data = Marshal.load(f)
          f.close
          return(persisted_data)
        rescue Exception
          puts('WARNING: A problem arised while loading persisted data on ProgramData. The app will start fresh.')
          f.close
          return(nil)
        end
      end
    else
      puts("INFO: Seems that Dropbox isn't installed in this system, neither has persisted data locally. The app will start fresh.")
      nil
    end
  end
end

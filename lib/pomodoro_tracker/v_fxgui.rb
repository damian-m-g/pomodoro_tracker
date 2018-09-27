# Graphic User Interface.
class FXGUI

  # @param persisted_data [Array, NilClass]
  # @param pomodoro_tracker [PomodoroTracker]
  def initialize(persisted_data, pomodoro_tracker)
    $fxgui = self
    if(persisted_data) then load_persisted_data(persisted_data) end
    @pomodoro_tracker = pomodoro_tracker #: PomodoroTracker
    @pomodoro_system = @pomodoro_tracker.pomodoro_system #: PomodoroSystem
    @gamification_system = @pomodoro_tracker.gamification #: Gamification
    @app = FXApp.new('Pomodoro Tracker', 'JorobusLab')
    create_window()
    create_tips_system()
    create_app()
    @main_window.show(PLACEMENT_OWNER)
    @app.run
  end

  def build_package_to_persist
    package = []
    [@current_item_selected_on_listbox_general_chart, @current_selected_project_on_statistics, @current_item_selected_on_lb_individual_chart].each do |data|
      package << data
    end
    return(package)
  end

  private

  # @param persisted_data [Array]
  # If there's some persisted data, load it into self.
  def load_persisted_data(persisted_data)
    @current_item_selected_on_listbox_general_chart = persisted_data[0]
    @current_selected_project_on_statistics = persisted_data[1]
    @current_item_selected_on_lb_individual_chart = persisted_data[2]
  end

  def create_window
    @icon = FXPNGIcon.new(@app, File.read('./data/icon.png', {mode: 'rb'}), 0, 0, 30, 30)
    @main_window = FXMainWindow.new(@app, 'Pomodoro Tracker', icon: @icon, miniIcon: @miniIcon, height: 710, width: 540, opts: DECOR_TITLE|DECOR_MINIMIZE|DECOR_CLOSE|DECOR_BORDER)
    vertical0 = FXVerticalFrame.new(@main_window, opts: LAYOUT_FILL)
    create_tabbar(vertical0)
    FXPainter.paint_background(FXColor::VERDE_CLARO, vertical0, @main_window)
    @main_window.connect(SEL_CLOSE) do |sender, selector, data|
      @pomodoro_tracker.persist_data()
      0
    end
    # add a timeout to try to persist data
    @app.addTimeout(5000, repeat: true) do |sender, selector, data|
      @app.addChore() do |sender, selector, data|
        @pomodoro_tracker.persist_data()
      end
    end
  end

  def create_tips_system
    FXToolTip.new(@app)
    @app.tooltipTime = 6000
    @app.tooltipPause = 600
  end

  def create_app
    @app.create
    @app.sleepTime = 0
  end

  def create_tabbar(parent)
    @tabbook = FXTabBook.new(parent, opts: TABBOOK_NORMAL|LAYOUT_FILL, padTop: 3)
    tabitem0 = FXTabItem.new(@tabbook, 'Counter', opts: JUSTIFY_NORMAL|ICON_BEFORE_TEXT|TAB_TOP|FRAME_LINE)
    packer0 = FXPacker.new(@tabbook, opts: LAYOUT_FILL|FRAME_RAISED)
    create_tab_counter_stuff(packer0)
    tabitem1 = FXTabItem.new(@tabbook, 'Rewards', opts: JUSTIFY_NORMAL|ICON_BEFORE_TEXT|TAB_TOP|FRAME_LINE)
    packer1 = FXPacker.new(@tabbook, opts: LAYOUT_FILL|FRAME_RAISED, padRight: 6, padBottom: 15, padTop: 15)
    created_tab_gift_stuff(packer1)
    tabitem2 = FXTabItem.new(@tabbook, 'Statistics', opts: JUSTIFY_NORMAL|ICON_BEFORE_TEXT|TAB_TOP|FRAME_LINE)
    packer2 = FXPacker.new(@tabbook, opts: LAYOUT_FILL|FRAME_RAISED)
    create_tab_statistics_stuff(packer2)
    tabitem3 = FXTabItem.new(@tabbook, 'About', opts: JUSTIFY_NORMAL|ICON_BEFORE_TEXT|TAB_TOP|FRAME_LINE)
    packer3 = FXPacker.new(@tabbook, opts: LAYOUT_FILL|FRAME_RAISED)
    create_tab_about(packer3)
    @tabbook.connect(SEL_COMMAND) do |sender, selector, data|
      # each time you see the statistics update stuff
      case(data)
        when(2)
          fill_labels_general_positioning()
          fill_project_listbox_on_statistics()
          new_project_selected_on_statistics()
          draw_dinamyc_things_on_chart_graphic()
        when(0)
          fill_coins_amount_on_counter_tab()
      end
    end
    FXPainter.paint_background(FXColor::VERDE_CLARO, @tabbook)
    FXPainter.paint_background(FXColor::VERDE, tabitem0, packer0)
    FXPainter.paint_background(FXColor::VERDE_3, tabitem1, packer1)
    FXPainter.paint_background(FXColor::VERDE_2, tabitem2, packer2)
    FXPainter.paint_background(FXColor::VERDE_4, tabitem3, packer3)
  end

=begin
  COUNTER TAB
=end

  def create_tab_counter_stuff(parent)
    vertical0 = FXVerticalFrame.new(parent, LAYOUT_FILL, padding: 0)
    create_counter(vertical0)
    create_counter_button_0(vertical0)
    create_counter_button_4(vertical0)
    create_counter_button_1(vertical0)
    create_counter_button_2(vertical0)
    create_counter_button_3(vertical0)
    horizontal0 = FXHorizontalFrame.new(vertical0, opts: LAYOUT_FILL_X|PACK_UNIFORM_WIDTH, padBottom: 0, hSpacing: 0)
    create_project_selector(horizontal0)
    create_coins_label(horizontal0)
    create_boxes(vertical0)
    FXPainter.paint_background(FXColor::VERDE, vertical0, horizontal0)
  end

  def create_counter(parent)
    horizontal0 = FXHorizontalFrame.new(parent, opts: LAYOUT_FILL_X)
    @seven_segment = FX7Segment.new(horizontal0, '00:00', opts: LAYOUT_FILL|SEVENSEGMENT_NORMAL, padTop: 8, padBottom: 8)
    @seven_segment.cellHeight = 144
    @seven_segment.cellWidth = 96
    @seven_segment.thickness = 24
    @seven_segment.textColor = FXColor::ROJO_7_SEGMENT
    FXPainter.paint_background(FXColor::VERDE, horizontal0, @seven_segment)
  end

  def create_counter_button_0(parent)
    horizontal0 = FXHorizontalFrame.new(parent, opts: LAYOUT_FILL_X, padRight: 10, padLeft: 12, padBottom: 0)
    @pomodoro_button_counter = FXButton.new(horizontal0, 'Start Pomodoro', opts: BUTTON_NORMAL|LAYOUT_FILL_X)
    @pomodoro_button_counter.connect(SEL_COMMAND) {|sender, selector, data| button_0_on_counter_pressed(sender); 1}
    # add a timeout that checks button text, to send to arduino(if presents) a signal when nothing is happening
    @app.addChore do
      @app.addTimeout(1000, repeat: true) do |sender, selector, data|
        # if arduino is connected
        if(@pomodoro_tracker.arduino_connected)
          if(@pomodoro_button_counter.text == 'Start Pomodoro')
            # it is stopped
            @pomodoro_tracker.arduino_interpreter.transmit_status(:stopped)
          end
        end
      end
    end
    # paint
    FXPainter.paint_background(FXColor::VERDE, horizontal0)
    FXPainter.paint_buttons(196, 215, 196, @pomodoro_button_counter)
  end

  # Pressing this button will trigger a few things. First, it has to change its text. Second, it will impact on model, on Arduino, and on many parts of the GUI. All this depends in the current state of the pomodoro system. The
  # text of the widget could be one of 'Start Pomodoro', 'Stop Pomodoro', 'Stop Break'.
  def button_0_on_counter_pressed(button)
    case(button.text)
      when('Start Pomodoro')
        # check if there is a project selected, if there's none pomodoro can't start
        if(!@pomodoro_system.current_project)
          # advice
          FXMessageBox.information(@main_window, MBOX_OK, 'Informing', "You need to have at least one project alive\nin order to charge a pomodoro. Add one first.")
        else
          # start
          button.text = 'Stop Pomodoro'
          @seven_segment.textColor = FXColor::BLACK
          @pomodoro_system.pomodoro_started()
          # the counter must start counting
          start_counter()
        end
      when('Stop Pomodoro')
        button.text = 'Start Pomodoro'
        @pomodoro_system.pomodoro_stopped()
        # the counter arrives to a hang
        if(@app.hasTimeout?(@pomodoro_counter))
          @app.removeTimeout(@pomodoro_counter)
        end
        # refresh GUI
        @seven_segment.text = '00:00'
        @seven_segment.textColor = FXColor::ROJO_7_SEGMENT
        # update labels on gbs
        fill_labels_on_gb_on_counter(@labels_on_gb_current_project, :current_project)
        fill_labels_on_gb_on_counter(@labels_on_gb_current_working_day, :working_day)
        # and the coins
        fill_coins_amount_on_counter_tab()
      when('Stop Break')
        button.text = 'Start Pomodoro'
        @pomodoro_system.break_stopped()
        # the counter arrives to a hang
        if(@app.hasTimeout?(@break_counter))
          @app.removeTimeout(@break_counter)
        end
        # refresh GUI
        @seven_segment.text = '00:00'
        @seven_segment.textColor = FXColor::ROJO_7_SEGMENT
        # update labels on gbs
        fill_labels_on_gb_on_counter(@labels_on_gb_current_project, :current_project)
        fill_labels_on_gb_on_counter(@labels_on_gb_current_working_day, :working_day)
    end
  end

  def start_counter
    @pomodoro_counter = @app.addTimeout(1000, repeat: true) do |sender, selector, data|
      current_pomodoro = @pomodoro_system.current_pomodoro #: Pomodoro
      pomodoro_finished = current_pomodoro.increase_counter() # TrueClass or FalseClass
      # reflect the counter of the model in the GUI
      @seven_segment.text = transform_seconds_to_pretty_timeshow(current_pomodoro.current_counting) #: String
      # check if pomodoro has finished
      if(pomodoro_finished)
        # stop this counter
        @app.addChore do |sender, selector, data|
          if(@app.hasTimeout?(@pomodoro_counter))
            @app.removeTimeout(@pomodoro_counter)
          end
        end
        # update GUI
        @main_window.update()
        @main_window.repaint()
        # put window on front
        AutoItFFI::AutoIt.win_activate(@main_window.title)
        @tabbook.setCurrent(0, true)
        # update GUI
        @main_window.create()
        @main_window.update()
        @main_window.repaint()
        # add a chore repeating same thing that before, this may fix an issue
        @app.addChore do
          @main_window.create()
          @main_window.update()
          @main_window.repaint()
        end
        # start animation
        start_pomodoro_finished_animation()
        # update GUI
        fill_coins_amount_on_counter_tab()
        # update labels on gbs
        fill_labels_on_gb_on_counter(@labels_on_gb_current_project, :current_project)
        fill_labels_on_gb_on_counter(@labels_on_gb_current_working_day, :working_day)
        # start the break
        @pomodoro_button_counter.text = 'Stop Break'
        @seven_segment.textColor = FXColor::BLUE
        @main_window.update()
        @main_window.repaint()
        @break_counter = @app.addTimeout(1000, repeat: true) do |sender, selector, data|
          current_break = @pomodoro_system.current_break #: Break
          break_finished = current_break.increase_counter() # TrueClass or FalseClass
          # reflect the counter of the model in the GUI
          @seven_segment.text = transform_seconds_to_pretty_timeshow(current_break.current_counting) #: String
          # check if break finished
          if(break_finished)
            # stop this counter
            @app.addChore do |sender, selector, data|
              if(@app.hasTimeout?(@break_counter))
                @app.removeTimeout(@break_counter)
              end
            end
            # update GUI
            @main_window.update()
            @main_window.repaint()
            # put window on front
            @tabbook.setCurrent(0, true)
            AutoItFFI::AutoIt.win_activate(@main_window.title)
            @tabbook.setCurrent(0, true)
            # update GUI
            @main_window.create()
            @main_window.update()
            @main_window.repaint()
            # add a chore repeating same thing that before, this may fix an issue
            @app.addChore do
              @main_window.create()
              @main_window.update()
              @main_window.repaint()
            end
            # start animation
            start_break_finished_animation()
            # update labels on gbs
            fill_labels_on_gb_on_counter(@labels_on_gb_current_project, :current_project)
            fill_labels_on_gb_on_counter(@labels_on_gb_current_working_day, :working_day)
            @pomodoro_button_counter.text = 'Start Pomodoro'
            @seven_segment.textColor = FXColor::ROJO_7_SEGMENT
          end
        end
      end
    end
  end

  # @param seconds [Fixnum]
  # @return [String]
  # Transform raw seconds into a pretty print for showing time on seven segment.
  def transform_seconds_to_pretty_timeshow(seconds)
    pretty = ''
    minutes_part = seconds / 60
    seconds_part = seconds % 60
    # minutes polished
    if(minutes_part.to_s.size == 1)
      pretty << '0' << minutes_part.to_s << ':'
    else
      pretty << minutes_part.to_s << ':'
    end
    # seconds polished
    if(seconds_part.to_s.size == 1)
      pretty << '0' << seconds_part.to_s
    else
      pretty << seconds_part.to_s
    end
    return(pretty)
  end

  # Holds the entire system for a few seconds while an animation is performed on the seven segments.
  def start_pomodoro_finished_animation
    @app.beginWaitCursor()
      sleep(0.75)
      @seven_segment.text = '  :  '
      @seven_segment.update()
      @seven_segment.repaint()
      sleep(0.75)
      @seven_segment.text = '25:00'
      @seven_segment.update()
      @seven_segment.repaint()
      sleep(0.75)
      @seven_segment.text = '  :  '
      @seven_segment.update()
      @seven_segment.repaint()
      sleep(0.75)
      @seven_segment.text = '25:00'
      @seven_segment.update()
      @seven_segment.repaint()
      sleep(0.75)
      @seven_segment.text = '  :  '
      @seven_segment.update()
      @seven_segment.repaint()
      sleep(0.75)
      # break begins
      @seven_segment.text = '00:00'
      @main_window.update()
      @main_window.repaint()
    @app.endWaitCursor()
  end

  def start_break_finished_animation
    long_break = @pomodoro_system.current_break.long #: TrueClass or FalseClass
    @app.beginWaitCursor()
      sleep(0.75)
      @seven_segment.text = '  :  '
      @seven_segment.update()
      @seven_segment.repaint()
      sleep(0.75)
      @seven_segment.text = (long_break ? '15:00' : '05:00')
      @seven_segment.update()
      @seven_segment.repaint()
      sleep(0.75)
      @seven_segment.text = '  :  '
      @seven_segment.update()
      @seven_segment.repaint()
      sleep(0.75)
      @seven_segment.text = (long_break ? '15:00' : '05:00')
      @seven_segment.update()
      @seven_segment.repaint()
      sleep(0.75)
      @seven_segment.text = '  :  '
      @seven_segment.update()
      @seven_segment.repaint()
      sleep(0.75)
      # break begins
      @seven_segment.text = '00:00'
      @seven_segment.update()
      @seven_segment.repaint()
    @app.endWaitCursor()
  end

  def create_counter_button_1(parent)
    horizontal0 = FXHorizontalFrame.new(parent, opts: LAYOUT_FILL_X, padRight: 10, padLeft: 12, padTop: 0, padBottom: 0)
    button = FXButton.new(horizontal0, 'Synchronize', opts: BUTTON_NORMAL|LAYOUT_FILL_X)
    button.tipText = 'Synchronize with ROM/DropBox/ArduinoUno; enter button with [Ctrl] then click to invoke port selector'
    button.connect(SEL_ENTER) do |sender, selector, data|
      if((data.state & CONTROLMASK).!=(0))
        # special behaviour
        button.text = 'Select serial port'
        FXPainter.paint_buttons(176, 195, 205, button)
      end
      0
    end
    button.connect(SEL_LEAVE) do |sender, selector, data|
      # normal behaviour and view
      button.text = 'Synchronize'
      FXPainter.paint_buttons(196, 215, 205, button)
    end
    button.connect(SEL_COMMAND) {|sender, selector, data| synchronize_button_pressed(sender); 1}
    FXPainter.paint_background(FXColor::VERDE, horizontal0)
    FXPainter.paint_buttons(196, 215, 205, button)
  end

  def synchronize_button_pressed(button)
    if(button.text == 'Synchronize')
      @app.beginWaitCursor
        @pomodoro_tracker.synchronize_with_dropbox()
      @app.endWaitCursor
    else
      invoke_port_selector()
    end
  end

  def invoke_port_selector
    # raise a dialog so the user can input the name of the new proyect
    dialog = FXDialogBox.new(@main_window, 'Enter serial port name', DECOR_BORDER|DECOR_CLOSE|DECOR_TITLE|LAYOUT_FIX_WIDTH, width: 250)
    dialog.icon = @icon
    vertical0 = FXVerticalFrame.new(dialog, opts: LAYOUT_FILL)
    tf = FXTextField.new(vertical0, 15, opts: TEXTFIELD_LIMITED|TEXTFIELD_NORMAL|LAYOUT_FILL|TEXTFIELD_ENTER_ONLY)
    tf.justify = JUSTIFY_CENTER_X|JUSTIFY_CENTER_Y
    tf.tipText = 'Press [Enter] to accept'
    tf.text = @pomodoro_tracker.serial_port_number
    tf.setFocus()
    tf.connect(SEL_COMMAND) do |sender, selector, data|
      # collect port name and synchronize with arduino
      @pomodoro_tracker.synchronize_with_dropbox(@pomodoro_tracker.serial_port_number = tf.text)
      # close dialog
      dialog.handle(dialog, FXSEL(SEL_COMMAND, FXDialogBox::ID_ACCEPT), nil)
    end
    FXPainter.paint_background(FXColor::VERDE, vertical0, dialog)
    dialog.execute(PLACEMENT_OWNER)
  end

  def create_counter_button_2(parent)
    horizontal0 = FXHorizontalFrame.new(parent, opts: LAYOUT_FILL_X, padRight: 10, padLeft: 12, padTop: 0, padBottom: 0)
    button = FXButton.new(horizontal0, 'Add Project', opts: BUTTON_NORMAL|LAYOUT_FILL_X)
    button.connect(SEL_COMMAND) {|sender, selector, data| add_proyect_button_pressed(); 1}
    FXPainter.paint_background(FXColor::VERDE, horizontal0)
    FXPainter.paint_buttons(180, 215, 205, button)
  end

  def add_proyect_button_pressed
    # raise a dialog so the user can input the name of the new proyect
    dialog = FXDialogBox.new(@main_window, 'Enter proyect name', DECOR_BORDER|DECOR_CLOSE|DECOR_TITLE|LAYOUT_FIX_WIDTH, width: 250)
    dialog.icon = @icon
    vertical0 = FXVerticalFrame.new(dialog, opts: LAYOUT_FILL)
    tf = FXTextField.new(vertical0, 15, opts: TEXTFIELD_LIMITED|TEXTFIELD_NORMAL|LAYOUT_FILL|TEXTFIELD_ENTER_ONLY)
    tf.justify = JUSTIFY_CENTER_X|JUSTIFY_CENTER_Y
    tf.tipText = 'Press [Enter] to accept'
    tf.setFocus()
    tf.connect(SEL_COMMAND) do |sender, selector, data|
      project_name = tf.text #: String
      # check if this project name already exists?
      if((@pomodoro_system.exists_project?(project_name.strip)) || (project_name.strip.downcase == 'working day') || (project_name.strip.downcase == 'global') || (project_name.strip.downcase == 'working_day') ||
          (project_name.strip.downcase == 'current working day'))
        # this project already exsits, show error box
        FXMessageBox.error(@main_window, MBOX_OK, 'Error', 'That project name already exists or you\'re trying to use "working day"(or related) or "global" which are reserved.')
      else
        # this project is new, awesome
        @pomodoro_system.add_new_project(project_name.strip)
        # refresh the listbox
        fill_project_listbox_on_counter(@listbox_projects_counter)
        # if this is the first project added, update the groupbox on bottom
        if(@pomodoro_system.current_project == project_name.strip)
          fill_name_of_current_project_on_gb()
          # update labels inside
          fill_labels_on_gb_on_counter(@labels_on_gb_current_project, :current_project)
        end
        # close the dialog
        dialog.handle(dialog, FXSEL(SEL_COMMAND, FXDialogBox::ID_ACCEPT), nil)
      end
    end
    FXPainter.paint_background(FXColor::VERDE, vertical0, dialog)
    dialog.execute(PLACEMENT_OWNER)
  end

  def create_counter_button_3(parent)
    horizontal0 = FXHorizontalFrame.new(parent, opts: LAYOUT_FILL_X, padRight: 10, padLeft: 12, padTop: 0)
    button = FXButton.new(horizontal0, 'Delete Project', opts: BUTTON_NORMAL|LAYOUT_FILL_X)
    button.tipText = 'Delete current selected project'
    button.connect(SEL_COMMAND) {|sender, selector, data| delete_project_button_pressed(); 1}
    FXPainter.paint_background(FXColor::VERDE, horizontal0)
    FXPainter.paint_buttons(224, 204, 194, button)
  end

  def delete_project_button_pressed
    # check if there's any project selected
    if(@pomodoro_system.current_project)
      # raise a confirmation box
      answer = FXMessageBox.warning(@main_window, MBOX_OK_CANCEL, 'Confirmation', "Are you sure about erasing project \"#{@pomodoro_system.current_project}\"?\n All regarding data will be lost.")
      if(answer == MBOX_CLICKED_OK)
        # delete it on model
        @pomodoro_system.delete_project()
        @pomodoro_system.try_select_random_project_as_current()
        # reflect changes on GUI, other random project has become the current
        fill_project_listbox_on_counter(@listbox_projects_counter)
        # refresh the bottom box
        fill_name_of_current_project_on_gb()
        # update labels inside
        fill_labels_on_gb_on_counter(@labels_on_gb_current_project, :current_project)
      end
    else
      FXMessageBox.information(@main_window, MBOX_OK, 'Info', 'There is no project to delete.')
    end
  end

  def create_counter_button_4(parent)
    horizontal0 = FXHorizontalFrame.new(parent, opts: LAYOUT_FILL_X, padRight: 10, padLeft: 12, padTop: 0, padBottom: 0)
    button = FXButton.new(horizontal0, 'Reset Current Working Day', opts: BUTTON_NORMAL|LAYOUT_FILL_X)
    button.connect(SEL_COMMAND) {|sender, selector, data| reset_current_wd_button_pressed(); 1}
    FXPainter.paint_background(FXColor::VERDE, horizontal0)
    FXPainter.paint_buttons(218, 220, 186, button)
  end

  def reset_current_wd_button_pressed
    # ask confirmation
    answer = FXMessageBox.question(@main_window, MBOX_OK_CANCEL, 'Confirmation', "Please confirm that you want\nto start a new working day.")
    if(answer == MBOX_CLICKED_OK)
      # impact model
      @pomodoro_system.reset_working_day()
      # reflect on vista
      fill_labels_on_gb_on_counter(@labels_on_gb_current_working_day, :working_day)
    end
  end

  def create_project_selector(parent)
    horizontal0 = FXHorizontalFrame.new(parent, opts: LAYOUT_FILL, hSpacing: 0)
    label0 = FXLabel.new(horizontal0, 'Current Project:', opts: JUSTIFY_CENTER_X|JUSTIFY_CENTER_Y|LAYOUT_FILL, padRight: 0)
    packer = FXPacker.new(horizontal0, opts: LAYOUT_FILL, padLeft: 0)
    @listbox_projects_counter = FXListBox.new(packer, :opts => FRAME_NONE|LISTBOX_NORMAL|LAYOUT_CENTER_Y|LAYOUT_CENTER_X, padLeft: 6, padRight: 6)
    @listbox_projects_counter.connect(SEL_COMMAND) {|sender, selector, data| new_project_selected(sender.getItemText(data)); 1}
    fill_project_listbox_on_counter(@listbox_projects_counter)
    FXPainter.paint_background(FXColor::VERDE, label0, horizontal0, packer)
  end

  def fill_project_listbox_on_counter(listbox)
    listbox.clearItems
    @pomodoro_system.all_pomodoros.keys.sort.each do |p|
      if((p == :global) || (p == :working_day)) then next end
      listbox.appendItem(p.to_s)
    end
    # recalculate showing items
    active_projects = @pomodoro_system.all_pomodoros.keys.size.-(2) #: Fixnum
    (active_projects > 10) ? (@listbox_projects_counter.numVisible = 10) : (@listbox_projects_counter.numVisible = active_projects)
    # set current item
    cpi = listbox.findItem(@pomodoro_system.current_project) #: Fixnum
    if(cpi != -1) then listbox.currentItem = cpi end
  end

  # @param project [String]
  def new_project_selected(project)
    # modify stuff in the model
    @pomodoro_system.change_current_project(project)
    # reflect changes on GUI, refresh the bottom box
    fill_name_of_current_project_on_gb()
    # update labels inside
    fill_labels_on_gb_on_counter(@labels_on_gb_current_project, :current_project)
  end

  def create_coins_label(parent)
    # icon = FXPNGIcon.new(@app, File.read('./data/coin.png', {mode: 'rb'}), 0, IMAGE_ALPHAGUESS, 40, 42)
    icon = FXPNGIcon.new(@app, File.read('./data/vault.png', {mode: 'rb'}), 0, IMAGE_ALPHAGUESS, 42, 42)
    @label_coins_on_counter = FXLabel.new(parent, '', icon, opts: LABEL_NORMAL|LAYOUT_FILL)
    @label_coins_on_counter.tipText = 'Accumulated coins'
    fill_coins_amount_on_counter_tab()
    FXPainter.paint_background(FXColor::VERDE, @label_coins_on_counter)
  end

  def fill_coins_amount_on_counter_tab()
    @label_coins_on_counter.text = "     #{@gamification_system.gold.to_s}"
  end

  def create_boxes(parent)
    vertical0 = FXVerticalFrame.new(parent, opts: LAYOUT_FILL, padTop: 0, padLeft: 12, padRight: 11, padBottom: 10)
    gb0 = FXGroupBox.new(vertical0, 'Current Working Day', opts: GROUPBOX_TITLE_CENTER|LAYOUT_FILL|FRAME_LINE)
    @labels_on_gb_current_working_day = fill_gb_on_counter(gb0)
    fill_labels_on_gb_on_counter(@labels_on_gb_current_working_day, :working_day)
    @gb_current_project = FXGroupBox.new(vertical0, '', opts: GROUPBOX_TITLE_CENTER|LAYOUT_FILL|FRAME_LINE)
    fill_name_of_current_project_on_gb()
    @labels_on_gb_current_project = fill_gb_on_counter(@gb_current_project)
    fill_labels_on_gb_on_counter(@labels_on_gb_current_project, :current_project)
    FXPainter.paint_background(FXColor::VERDE, vertical0, gb0, @gb_current_project)
  end

  def fill_name_of_current_project_on_gb()
    @gb_current_project.text = @pomodoro_system.current_project || ' '
  end

  def fill_gb_on_counter(gb)
    vertical0 = FXVerticalFrame.new(gb, opts: LAYOUT_FILL, vSpacing: 0)
    horizontal0 = FXHorizontalFrame.new(vertical0, opts: LAYOUT_FILL|PACK_UNIFORM_WIDTH, padBottom: 0)
    l0 = FXLabel.new(horizontal0, '', opts: LAYOUT_FILL|LABEL_NORMAL)
    l1 = FXLabel.new(horizontal0, '', opts: LAYOUT_FILL|LABEL_NORMAL)
    l2 = FXLabel.new(horizontal0, '', opts: LAYOUT_FILL|LABEL_NORMAL)
    horizontal1 = FXHorizontalFrame.new(vertical0, opts: LAYOUT_FILL|PACK_UNIFORM_WIDTH, padTop: 0)
    l3 = FXLabel.new(horizontal1, '', opts: LAYOUT_FILL|LABEL_NORMAL)
    l4 = FXLabel.new(horizontal1, '', opts: LAYOUT_FILL|LABEL_NORMAL)
    l5 = FXLabel.new(horizontal1, '', opts: LAYOUT_FILL|LABEL_NORMAL)
    FXPainter.paint_background(FXColor::VERDE, vertical0, horizontal0, horizontal1, l0, l1, l2, l3, l4, l5)
    FXPainter.paint_background(FXRGB(72, 113, 88), l0, l3)
    FXPainter.paint_background(FXRGB(48, 72, 137), l1, l4)
    FXPainter.paint_background(FXRGB(119, 91, 200), l2, l5)
    FXPainter.paint_background(FXRGB(100, 0, 0), horizontal1)
    FXPainter.paint_background(FXRGB(0, 100, 0), horizontal0)
    return([l0, l1, l2, l3, l4, l5])
  end

  def fill_labels_on_gb_on_counter(labels, kind)
    labels[0].text = "P. Finished: #{(kind == :working_day) ? @pomodoro_system.pomodoros_finished[:working_day].to_s : (@pomodoro_system.pomodoros_finished[@pomodoro_system.current_project.to_sym].to_s rescue '')}"
    labels[1].text = "B. Completed: #{(kind == :working_day) ? @pomodoro_system.breaks_completed[:working_day].to_s : (@pomodoro_system.breaks_completed[@pomodoro_system.current_project.to_sym].to_s rescue '')}"
    labels[2].text = "Consecutive P.: #{(kind == :working_day) ? @pomodoro_system.consecutive_pomodoros[:working_day].to_s : (@pomodoro_system.consecutive_pomodoros[@pomodoro_system.current_project.to_sym].to_s rescue '')}"
    labels[3].text = "P. Stopped: #{(kind == :working_day) ? @pomodoro_system.pomodoros_stopped[:working_day].to_s : (@pomodoro_system.pomodoros_stopped[@pomodoro_system.current_project.to_sym].to_s rescue '')}"
    labels[4].text = "B. Stopped: #{(kind == :working_day) ? @pomodoro_system.breaks_stopped[:working_day].to_s : (@pomodoro_system.breaks_stopped[@pomodoro_system.current_project.to_sym].to_s rescue '')}"
    # next label is the more complex of all
    strop = \
      if(kind == :working_day)
        if(@pomodoro_system.stop_time_rate_of_pomodoros[:working_day])
          @pomodoro_system.stop_time_rate_of_pomodoros[:working_day].round(1).to_s
        else
          '-'
        end
      else
        if((@pomodoro_system.current_project) && (h = @pomodoro_system.stop_time_rate_of_pomodoros[@pomodoro_system.current_project.to_sym]))
          h.round(1).to_s
        else
          '-'
        end
      end
    labels[5].text = "Stop Time ROP: #{strop}"
  end

=begin
  GIFTS TAB
=end

  def created_tab_gift_stuff(parent)
    scroll_window0 = FXScrollWindow.new(parent, opts: LAYOUT_FILL|SCROLLERS_NORMAL|HSCROLLER_NEVER|HSCROLLING_OFF|SCROLLERS_TRACK)
    vertical_scrollbar = scroll_window0.verticalScrollBar
    vertical_scrollbar.hiliteColor = FXRGB(230, 255, 230)
    vertical_scrollbar.shadowColor = FXRGB(0, 100, 0)
    vertical_scrollbar.backColor = FXRGB(137, 192, 174)
    vertical_scrollbar.line = 10
    vertical0 = FXVerticalFrame.new(scroll_window0, opts: LAYOUT_FILL, padding: 11, padRight: 8, padTop: 0, padBottom: 0, vSpacing: 11) # padRight: 3, padTop: 12)
    @rewards_packer = FXVerticalFrame.new(vertical0, padding: 0, vSpacing: 11, opts: LAYOUT_FILL_X)
    rewards_created = @gamification_system.rewards_created #: Hash
    # create icons if at least exists one reward
    @cost_icon = FXPNGIcon.new(@app, File.read('./data/coin.png', {mode: 'rb'}), 0, IMAGE_ALPHAGUESS, 28, 28)
    @delete_icon = FXPNGIcon.new(@app, File.read('./data/delete.png', {mode: 'rb'}), 0, IMAGE_ALPHAGUESS, 28, 28)
    @edit_icon = FXPNGIcon.new(@app, File.read('./data/edit.png', {mode: 'rb'}), 0, IMAGE_ALPHAGUESS, 28, 28)
    @purchase_icon = FXPNGIcon.new(@app, File.read('./data/purchase.png', {mode: 'rb'}), 0, IMAGE_ALPHAGUESS, 28, 28)
    # iterate trough each reward and display its attributes
    rewards_created.each_value {|r| create_reward(r, @rewards_packer)}
    # then the box to add a new one
    plus_icon = FXPNGIcon.new(@app, File.read('./data/plus.png', {mode: 'rb'}), 0, IMAGE_ALPHAGUESS, 100, 100)
    button0 = FXButton.new(vertical0, '', plus_icon, opts: BUTTON_NORMAL|LAYOUT_FILL_X|LAYOUT_FIX_HEIGHT, padding: 7, height: 118)
    button0.connect(SEL_COMMAND) {|sender, selector, data| add_reward_button_pressed(@rewards_packer); 1}
    # colouring
    FXPainter.paint_background(FXColor::VERDE_3, vertical0, @rewards_packer)
    FXPainter.paint_buttons(56, 105, 109, button0)
  end

  def create_reward(reward, parent)
    # for each reward I do have a box
    gb0 = FXGroupBox.new(parent, nil, opts: GROUPBOX_NORMAL|LAYOUT_FILL_X|FRAME_SUNKEN)
    horizontal0 = FXHorizontalFrame.new(gb0, opts: LAYOUT_FILL_X, hSpacing: 10)
    # icon
    if(reward.icon)
      icon = FXJPGIcon.new(@app, reward.icon, width: 100, height: 100)
      label0 = FXLabel.new(horizontal0, nil, icon, opts: LABEL_NORMAL|FRAME_LINE, padding: 0)
    else
      # fake label
      label0 = FXPacker.new(horizontal0, opts: LAYOUT_FIX_WIDTH|LAYOUT_FIX_HEIGHT|FRAME_LINE, width: 102, height: 102, padding: 0)
      label0.backColor = FXRGB(104, 122, 193)
    end
    # mid stuff
    vertical1 = FXVerticalFrame.new(horizontal0, opts: LAYOUT_FILL|PACK_UNIFORM_HEIGHT)
    horizontal1 = FXHorizontalFrame.new(vertical1, opts: LAYOUT_FILL)
    label1 = FXLabel.new(horizontal1, reward.short_description, nil, opts: LABEL_NORMAL|LAYOUT_CENTER_Y, padBottom: 3)
    label1.font = FXFont.new(@app, 'Segoe UI,100,Bold,Straight')
    label1.tipText = reward.long_description
    label2 = FXLabel.new(horizontal1, reward.cost.to_s, @cost_icon, opts: LABEL_NORMAL|LAYOUT_RIGHT|LAYOUT_CENTER_Y, padRight: 11)
    horizontal2 = FXHorizontalFrame.new(vertical1, opts: LAYOUT_FILL)
    label3 = FXLabel.new(horizontal2, "Purchased: #{reward.purchased}", nil, opts: LABEL_NORMAL|LAYOUT_CENTER_Y|LAYOUT_FILL_X)
    checkbutton0 = FXCheckButton.new(horizontal2, 'Available?', opts: JUSTIFY_NORMAL|ICON_AFTER_TEXT|LAYOUT_CENTER_Y|LAYOUT_FILL_X)
    checkbutton0.checkState = reward.available ? 1 : 0
    checkbutton0.connect(SEL_COMMAND) do |sender, selector, data|
      reward.available = ((sender.checkState == 1) ? true : false)
    end
    # actions/buttons
    vertical2 = FXVerticalFrame.new(horizontal0, opts: LAYOUT_FILL_Y|LAYOUT_FIX_WIDTH|LAYOUT_FIX_HEIGHT, padding: 0, width: 34, vSpacing: 0, height: 102)
    button0 = FXButton.new(vertical2, nil, @delete_icon, opts: LAYOUT_FILL|BUTTON_NORMAL)
    button0.tipText = 'Delete'
    button0.connect(SEL_COMMAND) do |sender, selector, data|
      # raise confirmation dialog
      answer = FXMessageBox.warning(@main_window, MBOX_OK_CANCEL, 'Confirmation', "Please confirm that you want\nto delete \"#{reward.short_description}\".")
      if(answer == MBOX_CLICKED_OK)
        # delete this reward in model
        @gamification_system.delete_reward(reward)
        # reflect that on gui
        @app.addChore do
          parent.removeChild(gb0)
          parent.recalc()
          parent.layout()
        end
      end
    end
    button1 = FXButton.new(vertical2, nil, @edit_icon, opts: LAYOUT_FILL|BUTTON_NORMAL)
    button1.tipText = 'Edit'
    button1.connect(SEL_COMMAND) do |sender, selector, data|
      # put on attention all widgets under the groupbox
      update_reward_on_gui = Proc.new() do
        label1.text = reward.short_description
        label1.tipText = reward.long_description
        label2.text = reward.cost.to_s
        label3.text = "Purchased: #{reward.purchased}"
        checkbutton0.checkState = reward.available ? 1 : 0
        if(reward.icon)
          # madness
          madness = FXJPGIcon.new(@app, reward.icon, width: 100, height: 100)
          madness.create
          if(defined?(insane) && !insane.nil?)
            insane.icon = madness
          else
            if(label0.is_a?(FXLabel))
              label0.icon = madness
            else
              # welcome to insanity
              insane = FXLabel.new(label0, nil, madness, padding: 0, opts: LABEL_NORMAL|LAYOUT_FIX_WIDTH|LAYOUT_FIX_HEIGHT|FRAME_LINE, width: 102, height: 102)
              if(!insane.created?)
                insane.create
              end
            end
          end
        else
          (label0.icon = nil) rescue nil
          label0.backColor = FXRGB(104, 122, 193)
        end
        label0.parent.recalc()
        label0.parent.layout()
        label0.parent.update()
        label0.parent.repaint()
      end
      # raise thy dialog
      add_reward_button_pressed(@rewards_packer, reward, update_reward_on_gui)
      1
    end
    button2 = FXButton.new(vertical2, nil, @purchase_icon, opts: LAYOUT_FILL|BUTTON_NORMAL)
    button2.connect(SEL_COMMAND) do |sender, selector, data|
      # check if had enough money
      if(!reward.available)
        # raise error box
        FXMessageBox.error(@main_window, MBOX_OK, 'Information', "Seems that the item is not currently\navailable to be purchased.")
      elsif(reward.cost > @gamification_system.gold)
        # raise error box
        FXMessageBox.error(@main_window, MBOX_OK, 'Error', "You don't have enough gold.\nItem cost #{reward.cost} and you have #{@gamification_system.gold} coins.")
      else
        # raise confirmation
        answer = FXMessageBox.question(@main_window, MBOX_OK_CANCEL, 'Confirmation', "Please confirm the acquisition of\n\"#{reward.short_description}\".")
        if(answer == MBOX_CLICKED_OK)
          # model change
          @gamification_system.purchase_reward(reward)
          # on gui
          label3.text = "Purchased: #{reward.purchased}"
          # show the user some gratification
          FXMessageBox.information(@main_window, MBOX_OK, 'Informing', "Congratulations! ^-^ Enjoy your reward!")
        end
      end
    end
    button2.tipText = 'Purchase'
    # painting
    FXPainter.paint_borders(FXRGB(60, 60, 60), label0)
    # not a button but works
    FXPainter.paint_buttons(150, 180, 150, gb0)
    FXPainter.paint_buttons(224, 204, 194, button0)
    FXPainter.paint_buttons(180, 215, 205, button1)
    FXPainter.paint_buttons(218, 220, 186, button2)
    FXPainter.paint_background(FXRGB(80, 152, 129), gb0, horizontal0, vertical1, label1, vertical2, label2, checkbutton0, label3, horizontal1, horizontal2)
    # create this stuff is the parent is already created
    if(parent.created?)
      gb0.create()
    end
  end

  # If *actual_reward* is passed it means it's trying to modify a current reward.
  def add_reward_button_pressed(rewards_packer, actual_reward = nil, updating_procedure = nil)
    dialog = FXDialogBox.new(@main_window, (!actual_reward ? 'Creating new reward' : 'Modify reward'), DECOR_BORDER|DECOR_CLOSE|DECOR_TITLE|LAYOUT_FIX_WIDTH, width: 450)
    dialog.icon = @icon
    vertical0 = FXVerticalFrame.new(dialog, opts: LAYOUT_FILL, vSpacing: 0)
    button0 = FXButton.new(vertical0, ((!actual_reward || !actual_reward.icon.is_a?(String)) ? 'Path to icon' : 'Path to icon(already has icon)'), opts: BUTTON_NORMAL|LAYOUT_FILL_X)
    button0.tipText = 'Must be a *.jpg with size 100 x 100'
    button0.connect(SEL_COMMAND) {|sender, selector, data| @new_reward_icon_path = button_path_to_icon_pressed(sender, actual_reward); 1}
    horizontal0 = FXHorizontalFrame.new(vertical0, opts: LAYOUT_FILL_X|PACK_UNIFORM_HEIGHT, padLeft: 0, padRight: 1, padTop: 8)
    label0 = FXLabel.new(horizontal0, 'Short description:', padLeft: 0)
    textfield0 = FXTextField.new(horizontal0, 35, opts: TEXTFIELD_NORMAL|TEXTFIELD_LIMITED|LAYOUT_FILL_X)
    textfield0.justify = JUSTIFY_CENTER_Y|JUSTIFY_CENTER_X
    if(actual_reward)
      textfield0.text = actual_reward.short_description
    end
    horizontal1 = FXHorizontalFrame.new(vertical0, opts: LAYOUT_FILL_X|PACK_UNIFORM_HEIGHT, padLeft: 0, padRight: 1)
    label1 = FXLabel.new(horizontal1, 'Long description:', padLeft: 0)
    textfield1 = FXTextField.new(horizontal1, 57, opts: TEXTFIELD_NORMAL|TEXTFIELD_LIMITED|LAYOUT_FILL_X)
    textfield1.justify = JUSTIFY_CENTER_Y|JUSTIFY_CENTER_X
    if(actual_reward)
      textfield1.text = actual_reward.long_description
    end
    horizontal2 = FXHorizontalFrame.new(vertical0, opts: LAYOUT_FILL_X|PACK_UNIFORM_HEIGHT|PACK_UNIFORM_WIDTH, padTop: 5)
    checkbutton0 = FXCheckButton.new(horizontal2, 'Available?', opts: JUSTIFY_NORMAL|ICON_AFTER_TEXT|LAYOUT_FILL_X)
    if(actual_reward)
      checkbutton0.setCheckState(actual_reward.available ? 1 : 0)
    else
      checkbutton0.setCheckState(1)
    end
    horizontal4 = FXHorizontalFrame.new(horizontal2, opts: LAYOUT_FILL_X, padding: 0)
    horizontal5 = FXHorizontalFrame.new(horizontal4, opts: LAYOUT_CENTER_X|LAYOUT_CENTER_Y|PACK_UNIFORM_HEIGHT, padding: 0)
    label2 = FXLabel.new(horizontal5, 'Cost:', padLeft: 0)
    textfield2 = FXTextField.new(horizontal5, 4, opts: TEXTFIELD_NORMAL|TEXTFIELD_INTEGER|TEXTFIELD_LIMITED)
    if(actual_reward)
      textfield2.text = actual_reward.cost.to_s
    end
    horizontal3 = FXHorizontalFrame.new(vertical0, opts: LAYOUT_FILL_X|PACK_UNIFORM_WIDTH, padBottom: 0, padLeft: 0, padRight: 0, padTop: 6)
    button1 = FXButton.new(horizontal3, 'Accept', opts: BUTTON_NORMAL|LAYOUT_FILL_X)
    button1.connect(SEL_COMMAND) {|sender, selector, data| button_new_reward_accepted_pressed(textfield0, textfield1, textfield2, checkbutton0, button0, dialog, rewards_packer, actual_reward, updating_procedure); 1}
    button2 = FXButton.new(horizontal3, 'Cancel', opts: BUTTON_NORMAL|LAYOUT_FILL_X)
    button2.connect(SEL_COMMAND) do |sender, selector, data|
      dialog.handle(dialog, FXSEL(SEL_COMMAND, FXDialogBox::ID_ACCEPT), nil)
      1
    end
    FXPainter.paint_background(FXColor::VERDE, vertical0, dialog, horizontal0, label0, horizontal1, label1, horizontal2, checkbutton0, label2, horizontal3, horizontal4, horizontal5)
    FXPainter.paint_buttons(200, 233, 247, button0)
    FXPainter.paint_buttons(196, 215, 196, button1)
    FXPainter.paint_buttons(224, 204, 194, button2)
    dialog.execute(PLACEMENT_OWNER)
  end

  # @param button [FXButton]
  # @param actual_reward [Reward or NilClass]
  # @return [String or NilClass]
  def button_path_to_icon_pressed(button, actual_reward = nil)
    filepath = FXFileDialog.getOpenFilename(@main_window, 'Select JPG of size 100 x 100', nil, 'JPG files (*.jpg)').gsub('\\', '/') #: String
    if(filepath != '')
      button.text = "Path to icon(#{filepath.length > 25 ? "...#{filepath.chars.last(25).join('')}" : filepath})"
      return(filepath)
    else
      if(actual_reward)
        if(actual_reward.icon.is_a?(String))
          button.text = 'Path to icon(already has icon)'
        else
          button.text = 'Path to icon'
        end
      else
        button.text = 'Path to icon'
      end
      return(nil)
    end
  end

  # @param short_description_widget [FXTextField]
  # @param long_description_widget [FXTextField]
  # @param cost_widget [FXTextField]
  # @param available_widget [FXCheckButton]
  # @param button_path_to_icon [FXButton]
  # @param dialog [FXDialogBox]
  # @param rewards_packer [FXVerticalFrame]
  # @param actual_reward [NilClass, Reward]
  # @param updating_procedure [Proc]
  # This creates a new reward only validating some data. The must are the short description and the cost.
  def button_new_reward_accepted_pressed(short_description_widget, long_description_widget, cost_widget, available_widget, button_path_to_icon, dialog, rewards_packer, actual_reward = nil, updating_procedure = nil)
    # check for short description first
    if((short_description_widget.text.strip == '') || (cost_widget.text.strip == ''))
      # invalidated
      FXMessageBox.error(dialog, MBOX_OK, 'Error', 'The short description and the cost are required attributes.')
    else
      if(actual_reward)
        if((actual_reward.short_description != short_description_widget.text.strip) && (@gamification_system.exists_reward?(short_description_widget.text.strip)))
          # show error message
          FXMessageBox.error(dialog, MBOX_OK, 'Error', "This reward(short description)\nalready exists on the database.")
        else
          # modify thy attributes
          icon_binary_data = \
            if(button_path_to_icon.text != 'Path to icon(already has icon)')
              # check if right now the actual picture exists
              if(@new_reward_icon_path)
                if(File.exists?(@new_reward_icon_path))
                  # check if it is a jpg image
                  if(FastImage.type(@new_reward_icon_path) != :jpeg)
                    FXMessageBox.error(dialog, MBOX_OK, 'Error', "The image you passed as icon is not a real JPG.")
                    return
                  end
                  # check if the sizes are fine
                  if(FastImage.size(@new_reward_icon_path) != [100, 100])
                    FXMessageBox.error(dialog, MBOX_OK, 'Error', "The image you passed as icon haven't 100 x 100 size.")
                    return
                  end
                  File.read(@new_reward_icon_path, encoding: 'ASCII-8BIT', mode: 'rb') #: String
                else
                  actual_reward.icon
                end
              else
                actual_reward.icon
              end
            else
              actual_reward.icon
            end
          @gamification_system.edit_reward(actual_reward, icon_binary_data, short_description_widget.text.strip, long_description_widget.text.strip, (available_widget.checkState == 0 ? false : true), cost_widget.text.strip.to_i)
          # update the GUI
          updating_procedure.call
          # close the dialog
          dialog.handle(dialog, FXSEL(SEL_COMMAND, FXDialogBox::ID_ACCEPT), nil)
          1
        end
      elsif(@gamification_system.exists_reward?(short_description_widget.text.strip))
        # invalidated
        FXMessageBox.error(dialog, MBOX_OK, 'Error', "This reward(short description)\nalready exists on the database.")
      else
        # valid, build a reward, get the icon data(binary)
        icon_binary_data = \
          if(button_path_to_icon.text != 'Path to icon')
            # check if right now the actual picture exists
            if(File.exists?(@new_reward_icon_path))
              File.read(@new_reward_icon_path, encoding: 'ASCII-8BIT', mode: 'rb') #: String
            else
              nil
            end
          else
            nil
          end
        reward = @gamification_system.create_reward(icon_binary_data, short_description_widget.text.strip, long_description_widget.text.strip, (available_widget.checkState == 0 ? false : true), cost_widget.text.strip.to_i)
        # reflect this on GUI
        create_reward(reward, rewards_packer)
        # close the dialog
        dialog.handle(dialog, FXSEL(SEL_COMMAND, FXDialogBox::ID_ACCEPT), nil)
        1
      end
    end
  end

=begin
  STATISTICS TAB
=end

  def create_tab_statistics_stuff(parent)
    vertical0 = FXVerticalFrame.new(parent, opts: LAYOUT_FILL, padRight: 11, padLeft: 12, padBottom: 10)
    create_gb_general_on_statistics_tab(vertical0)
    create_gb_individual_on_statistics_tab(vertical0)
    # paintings
    FXPainter.paint_background(FXColor::VERDE_2, vertical0)
  end

  def create_gb_general_on_statistics_tab(parent)
    gb0 = FXGroupBox.new(parent, 'General', opts: GROUPBOX_TITLE_CENTER|LAYOUT_FILL_X|FRAME_LINE)
    vertical0 = FXVerticalFrame.new(gb0, opts: LAYOUT_FILL)
    @listbox_general_chart = FXListBox.new(vertical0, opts: LISTBOX_NORMAL|LAYOUT_CENTER_X|FRAME_SUNKEN|FRAME_THICK, padLeft: 6, padRight: 6)
    items = ['Greater amount of pomodoros completed on last 7 days', 'Greater amount of pomodoros interrupted on last 7 days', 'Greater amount of consecutive p. completed on last 7 days',
      'Greater amount of pomodoros completed ever', 'Greater amount of pomodoros interrupted ever', 'Greater amount of consecutive p. completed ever']
    @listbox_general_chart.fillItems(items)
    @listbox_general_chart.numVisible = 6
    if(@current_item_selected_on_listbox_general_chart)
      @listbox_general_chart.currentItem = @current_item_selected_on_listbox_general_chart #: Fixnum
    end
    @listbox_general_chart.connect(SEL_COMMAND) {|sender, selector, data| @current_item_selected_on_listbox_general_chart = sender.currentItem; fill_labels_general_positioning(); 1}
    vertical1 = FXVerticalFrame.new(vertical0, opts: LAYOUT_FILL, padTop: 8)
    @labels_general_positioning = []
    5.times do
      @labels_general_positioning << FXLabel.new(vertical1, '', opts: LABEL_NORMAL|LAYOUT_CENTER_X, padding: 0)
    end
    fill_labels_general_positioning()
    # paintings
    FXPainter.paint_background(FXColor::VERDE_2, vertical0, gb0, vertical0, vertical1, *@labels_general_positioning)
    FXPainter.paint_buttons(150, 200, 150, @listbox_general_chart)
  end

  def fill_labels_general_positioning()
    # inspect current parameter selected
    chart = \
      case @listbox_general_chart.currentItem
        when 0
          @pomodoro_system.show_me_greater_amount_of_pomodoros_completed_on_last_7_days()
        when 1
          @pomodoro_system.show_me_greater_amount_of_pomodoros_interrupted_on_last_7_days()
        when 2
          @pomodoro_system.show_me_greater_amount_of_consecutive_pomodoros_completed_on_last_7_days()
        when 3
          @pomodoro_system.show_me_greater_amount_of_pomodoros_completed_ever()
        when 4
          @pomodoro_system.show_me_greater_amount_of_pomodoros_interrupted_ever()
        when 5
          @pomodoro_system.show_me_greater_amount_of_consecutive_pomodoros_completed_ever()
      end
    # now that have the chart fill labels
    @labels_general_positioning.each_with_index do |label, index|
      if(chart[index])
        label.text = "#{index + 1}. #{chart[index][0]} => #{chart[index][1]}"
      else
        label.text = "#{index + 1}."
      end
    end
  end

  def create_gb_individual_on_statistics_tab(parent)
    gb0 = FXGroupBox.new(parent, 'Individual', opts: GROUPBOX_TITLE_CENTER|LAYOUT_FILL|FRAME_LINE, padBottom: 0)
    vertical0 = FXVerticalFrame.new(gb0, opts: LAYOUT_FILL, padLeft: 11, padRight: 11, padBottom: 11)
    horizontal0 = FXHorizontalFrame.new(vertical0, opts: LAYOUT_CENTER_X, padding: 0, padBottom: 7)
    label0 = FXLabel.new(horizontal0, 'Project:', opts: JUSTIFY_CENTER_X|JUSTIFY_CENTER_Y|LAYOUT_FILL, padRight: 0)
    @lb_individual_project_on_stats = FXListBox.new(horizontal0, :opts => LISTBOX_NORMAL|LAYOUT_CENTER_X|FRAME_SUNKEN|FRAME_THICK, padLeft: 6, padRight: 6)
    fill_project_listbox_on_statistics()
    @lb_individual_project_on_stats.connect(SEL_COMMAND) {|sender, selector, data| @current_selected_project_on_statistics = sender.getItemText(data); new_project_selected_on_statistics(); 1}
    @labels_on_gb_individual_project_on_statistics = fill_individual_project_statistics(vertical0)
    fill_labels_on_gb_individual_project_on_statistics()
    # bottom part
    p0 = FXPacker.new(vertical0, padding: 0, padTop: 6, opts: LAYOUT_FILL_X)
    @lb_individual_chart = FXListBox.new(p0, opts: LISTBOX_NORMAL|LAYOUT_CENTER_X|FRAME_SUNKEN|FRAME_THICK, padLeft: 6, padRight: 6)
    items = ['Pomodoros finished on last twelve weeks', 'Consecutive p. finished on last twelve weeks', 'Pomodoros stopped on last twelve weeks']
    @lb_individual_chart.fillItems(items)
    @lb_individual_chart.numVisible = 3
    if(@current_item_selected_on_lb_individual_chart)
      @lb_individual_chart.currentItem = @current_item_selected_on_lb_individual_chart #: Fixnum
    end
    @lb_individual_chart.connect(SEL_COMMAND) {|sender, selector, data| @current_item_selected_on_lb_individual_chart = sender.currentItem; draw_dinamyc_things_on_chart_graphic(); 1}
    # chart
    draw_fixed_things_on_chart_graphic(vertical0)
    draw_dinamyc_things_on_chart_graphic()
    # paintings
    FXPainter.paint_background(FXColor::VERDE_2, gb0, label0, horizontal0, vertical0, p0)
    FXPainter.paint_buttons(150, 200, 150, @lb_individual_project_on_stats, @lb_individual_chart)
  end

  def fill_project_listbox_on_statistics()
    @lb_individual_project_on_stats.clearItems
    @pomodoro_system.all_pomodoros.keys.<<(:'Current Working Day').sort.each do |p|
      if((p == :global) || (p == :working_day)) then next end
      @lb_individual_project_on_stats.appendItem(p.to_s)
    end
    # recalculate showing items
    active_projects = @pomodoro_system.all_pomodoros.keys.size.-(1) #: Fixnum
    (active_projects > 10) ? (@lb_individual_project_on_stats.numVisible = 10) : (@lb_individual_project_on_stats.numVisible = active_projects)
    # set current item
    if(@current_selected_project_on_statistics)
      # see if exists
      cpi = @lb_individual_project_on_stats.findItem(@current_selected_project_on_statistics) #: Fixnum
      if(cpi != -1)
        @lb_individual_project_on_stats.currentItem = cpi
      else
        @lb_individual_project_on_stats.currentItem = @lb_individual_project_on_stats.findItem('Current Working Day')
        # update
        @current_selected_project_on_statistics = nil
      end
    end
  end

  def new_project_selected_on_statistics()
    fill_labels_on_gb_individual_project_on_statistics()
    draw_dinamyc_things_on_chart_graphic()
  end

  # @return [Array].
  def fill_individual_project_statistics(parent)
    vertical0 = FXVerticalFrame.new(parent, opts: LAYOUT_FILL_X|LAYOUT_FIX_HEIGHT, height: 112, vSpacing: 0, padRight: 2, padLeft: 2)
    horizontal0 = FXHorizontalFrame.new(vertical0, opts: LAYOUT_FILL|PACK_UNIFORM_WIDTH, padBottom: 0)
    l0 = FXLabel.new(horizontal0, ' ', opts: LAYOUT_FILL|LABEL_NORMAL)
    l1 = FXLabel.new(horizontal0, ' ', opts: LAYOUT_FILL|LABEL_NORMAL)
    l2 = FXLabel.new(horizontal0, ' ', opts: LAYOUT_FILL|LABEL_NORMAL)
    horizontal1 = FXHorizontalFrame.new(vertical0, opts: LAYOUT_FILL|PACK_UNIFORM_WIDTH, padTop: 0)
    l3 = FXLabel.new(horizontal1, ' ', opts: LAYOUT_FILL|LABEL_NORMAL)
    l4 = FXLabel.new(horizontal1, ' ', opts: LAYOUT_FILL|LABEL_NORMAL)
    l5 = FXLabel.new(horizontal1, ' ', opts: LAYOUT_FILL|LABEL_NORMAL)
    FXPainter.paint_background(FXColor::VERDE_2, vertical0, horizontal0, horizontal1, l0, l1, l2, l3, l4, l5)
    FXPainter.paint_background(FXRGB(72, 113, 88), l0, l3)
    FXPainter.paint_background(FXRGB(48, 72, 137), l1, l4)
    FXPainter.paint_background(FXRGB(119, 91, 200), l2, l5)
    FXPainter.paint_background(FXRGB(100, 0, 0), horizontal1)
    FXPainter.paint_background(FXRGB(0, 100, 0), horizontal0)
    return([l0, l1, l2, l3, l4, l5])
  end

  def fill_labels_on_gb_individual_project_on_statistics()
    @labels_on_gb_individual_project_on_statistics[0].text = "P. Finished: #{((!@current_selected_project_on_statistics) || (@current_selected_project_on_statistics == 'Current Working Day')) ? @pomodoro_system.pomodoros_finished[:working_day] : @pomodoro_system.pomodoros_finished[@current_selected_project_on_statistics.to_sym]}"
    @labels_on_gb_individual_project_on_statistics[1].text = "B. Completed: #{((!@current_selected_project_on_statistics) || (@current_selected_project_on_statistics == 'Current Working Day')) ? @pomodoro_system.breaks_completed[:working_day] : @pomodoro_system.breaks_completed[@current_selected_project_on_statistics.to_sym]}"
    @labels_on_gb_individual_project_on_statistics[2].text = "Consecutive P.: #{((!@current_selected_project_on_statistics) || (@current_selected_project_on_statistics == 'Current Working Day')) ? @pomodoro_system.consecutive_pomodoros[:working_day] : @pomodoro_system.consecutive_pomodoros[@current_selected_project_on_statistics.to_sym]}"
    @labels_on_gb_individual_project_on_statistics[3].text = "P. Stopped: #{((!@current_selected_project_on_statistics) || (@current_selected_project_on_statistics == 'Current Working Day')) ? @pomodoro_system.pomodoros_stopped[:working_day] : @pomodoro_system.pomodoros_stopped[@current_selected_project_on_statistics.to_sym]}"
    @labels_on_gb_individual_project_on_statistics[4].text = "B. Stopped: #{((!@current_selected_project_on_statistics) || (@current_selected_project_on_statistics == 'Current Working Day')) ? @pomodoro_system.breaks_stopped[:working_day] : @pomodoro_system.breaks_stopped[@current_selected_project_on_statistics.to_sym]}"
    # next label is the more complex of all
    strop = \
      if((!@current_selected_project_on_statistics) || (@current_selected_project_on_statistics == 'Current Working Day'))
        if(@pomodoro_system.stop_time_rate_of_pomodoros[:working_day])
          @pomodoro_system.stop_time_rate_of_pomodoros[:working_day].round(1).to_s
        else
          '-'
        end
      else
        if(h = @pomodoro_system.stop_time_rate_of_pomodoros[@current_selected_project_on_statistics.to_sym])
          h.round(1).to_s
        else
          '-'
        end
      end
    @labels_on_gb_individual_project_on_statistics[5].text = "Stop Time ROP: #{strop}"
  end

  def draw_fixed_things_on_chart_graphic(parent)
    vertical0 = FXVerticalFrame.new(parent, opts: LAYOUT_FILL, padLeft: 2, vSpacing: 0, padTop: 0, padBottom: 0, padRight: 0)
    horizontal0 = FXHorizontalFrame.new(vertical0, opts: LAYOUT_FILL, padLeft: 10, padBottom: 0, padTop: 1)
    # labels pomodoros
    vertical1 = FXVerticalFrame.new(horizontal0, opts: LAYOUT_FILL_Y|PACK_UNIFORM_HEIGHT|PACK_UNIFORM_WIDTH, padLeft: 0, padTop: 0)
    @labels_pomodoros = []
    7.times do |n|
      @labels_pomodoros << FXLabel.new(vertical1, '', opts: LABEL_NORMAL|LAYOUT_FILL_Y|LAYOUT_FIX_WIDTH, padLeft: 1, width: 21)
    end
    @labels_pomodoros[0].text = 'P'
    @labels_pomodoros[0].justify = JUSTIFY_BOTTOM
    # horizontal separation
    vertical2 = FXVerticalFrame.new(horizontal0, padding: 0, opts: LAYOUT_FILL_Y, vSpacing: 0)
    packer4 = FXPacker.new(vertical2, padding: 0, opts: LAYOUT_FIX_HEIGHT|LAYOUT_FIX_WIDTH, width: 1, height: 28)
    packer0 = FXPacker.new(vertical2, padding: 0, opts: LAYOUT_FIX_WIDTH|LAYOUT_FILL_Y|FRAME_LINE, width: 1)
    # bars
    horizontal1 = FXHorizontalFrame.new(horizontal0, opts: LAYOUT_FILL|PACK_UNIFORM_WIDTH, padRight: 23, hSpacing: 0, padBottom: 0, padLeft: 0)
    @graphic_bars = []
    12.times do |t|
      h = FXPacker.new(horizontal1, opts: LAYOUT_FILL_Y|LAYOUT_FILL_X, padBottom: 0)
      FXPainter.paint_background(FXColor::VERDE_2, h)
      @graphic_bars << (p = FXPacker.new(h, opts: LAYOUT_FILL_X|LAYOUT_SIDE_BOTTOM|LAYOUT_FIX_HEIGHT, padTop: 0, padBottom: 0, height: 0))
      p.height = 0
    end
    # vertical separation
    horizontal3 = FXHorizontalFrame.new(vertical0, padding: 0, opts: LAYOUT_FILL_X, hSpacing: 0)
    packer2 = FXPacker.new(horizontal3, padding: 0, opts: LAYOUT_FIX_HEIGHT|LAYOUT_FIX_WIDTH, height: 1, width: 39)
    packer1 = FXPacker.new(horizontal3, padding: 0, opts: LAYOUT_FIX_HEIGHT|LAYOUT_FILL_X|FRAME_LINE, height: 1)
    packer3 = FXPacker.new(horizontal3, padding: 0, opts: LAYOUT_FIX_HEIGHT|LAYOUT_FIX_WIDTH, height: 1, width: 25)
    # labels weeks
    horizontal2 = FXHorizontalFrame.new(vertical0, opts: LAYOUT_FILL_X|PACK_UNIFORM_WIDTH|PACK_UNIFORM_HEIGHT, padLeft: 44, padBottom: 0, hSpacing: 0, padRight: -6)
    @labels_week = []
    13.times do |n|
      @labels_week << FXLabel.new(horizontal2, '', opts: LABEL_NORMAL|LAYOUT_FILL, padBottom: 0)
    end
    @labels_week[-1].text = 'W'
    @labels_week[-1].justify = JUSTIFY_LEFT
    # painting
    FXPainter.paint_background(FXRGB(100, 100, 100), packer0, packer1)
    FXPainter.paint_background(FXColor::VERDE_2, horizontal0, packer3, packer4, packer2, vertical1, horizontal1, horizontal2, vertical0, *@labels_week, *@labels_pomodoros)
  end

  def draw_dinamyc_things_on_chart_graphic
    current_project = \
      if(@current_selected_project_on_statistics)
        if(@current_selected_project_on_statistics == 'Current Working Day')
          :working_day
        else
          @current_selected_project_on_statistics.to_sym
        end
      else
        :working_day
      end
    # inspect option selected
    info_to_work_with = \
      case @lb_individual_chart.currentItem
        when 0
          @pomodoro_system.show_me_pomodoros_finished_on_last_twelve_weeks(current_project)
        when 1
          @pomodoro_system.show_me_consecutive_pomodoros_finished_on_last_twelve_weeks(current_project)
        when 2
          @pomodoro_system.show_me_pomodoros_stopped_on_last_twelve_weeks(current_project)
      end
    # get last twelve weeks
    last_12_weeks = []
    t = Time.now
    d = Date.new(t.year, t.month, t.day)
    12.times do
      last_12_weeks << d.cweek
      d = d - 7
    end
    # write this data into GUI
    last_12_weeks.reverse.each_with_index do |wn, i|
      @labels_week[i].text = wn.to_s
    end
    # get a bit personal
    if(info_to_work_with && (info_to_work_with.size > 0))
      # have info, process it
      _pomodoros_per_week = {}
      info_to_work_with.each do |p|
        case @lb_individual_chart.currentItem
          when 0, 1
            # find the week in which the pomodoro went finished
            t = p.finished_time #: Time
            d = Date.new(t.year, t.month, t.day)
            cweek = d.cweek #: Fixnum
            _pomodoros_per_week[cweek] ? _pomodoros_per_week[cweek] += 1 : _pomodoros_per_week[cweek] = 1
          when 2
            # find the week in which the pomodoro went stopped
            t = p.stop_time #: Time
            d = Date.new(t.year, t.month, t.day)
            cweek = d.cweek #: Fixnum
            _pomodoros_per_week[cweek] ? _pomodoros_per_week[cweek] += 1 : _pomodoros_per_week[cweek] = 1
        end
      end
      # go ahead, do some cleaning, also find which is the highest amount of pomodoros in a week?
      pomodoros_per_week = {}
      highest_pomodoro_in_a_week = 0
      _pomodoros_per_week.each_pair do |week, amount|
        if(last_12_weeks.include?(week))
          pomodoros_per_week[week] = amount
          if(amount > highest_pomodoro_in_a_week)
            highest_pomodoro_in_a_week = amount #: Fixnum
          end
        end
      end
      # do the maths
      marks_each = (highest_pomodoro_in_a_week / 6.0).ceil
      current_mark_counter = 0
      # fille the text on labels
      0.upto(5) do |n|
        current_mark_counter += marks_each
        @labels_pomodoros.reverse[n].text = current_mark_counter.to_s
      end
      # now get with the bars
      _factor = 188.0 / current_mark_counter #: Float
      # before setting specifi height for the bars clean them
      @graphic_bars.each_with_index do |gb, index|
        gb.height = 0
        # about color
        case @lb_individual_chart.currentItem
          when 0
            # green rules
            if(index.even?)
              gb.backColor = FXRGB(100, 255, 150)
            else
              gb.backColor = FXRGB(100, 255, 200)
            end
          when 1
            # blue rules
            if(index.even?)
              gb.backColor = FXRGB(75, 75, 125)
            else
              gb.backColor = FXRGB(25, 25, 255)
            end
          when 2
            # red rules
            if(index.even?)
              gb.backColor = FXRGB(255, 33, 33)
            else
              gb.backColor = FXRGB(255, 75, 75)
            end
        end
      end
      # now yes, perfrom the specific height on bars
      pomodoros_per_week.sort.each_with_index do |data, index|
        amount = data[1] #: Fixnum
        graphic_bar_number = last_12_weeks.reverse.find_index(data[0]) #: Fixnum
        @graphic_bars[graphic_bar_number].height = (amount * _factor).floor #: Fixnum
        @graphic_bars[graphic_bar_number].update()
      end
    else
      # clean everything, no data to show, place default values
      0.upto(5) do |n|
        @labels_pomodoros.reverse[n].text = n.+(1).to_s
      end
      # bars
      @graphic_bars.each do |gb|
        gb.height = 0
      end
    end
  end

=begin
  ABOUT TAB
=end

  def create_tab_about(parent)
    vertical0 = FXVerticalFrame.new(parent, opts: LAYOUT_CENTER_X|LAYOUT_CENTER_Y)
    l0 = FXLabel.new(vertical0, "Version #{PomodoroTracker::VERSION}", opts: LABEL_NORMAL|LAYOUT_CENTER_X)
    l0.font = big_font = FXFont.new(@app, 'Segoe UI,100,Bold,Straight')
    horizontal0 = FXHorizontalFrame.new(vertical0, padding: 0, padTop: 10, opts: LAYOUT_CENTER_X, hSpacing: 0)
    l1 = FXLabel.new(horizontal0, "\u{1 f 4 1e} Bug report && feature requests:", padRight: 0)
    l1.tipText = 'Label "bug" to point a bug, and "enhancement" to point a feature request'
    l2 = FXLabel.new(horizontal0, PomodoroTracker::BUG_REPORTS_AND_FEATURES_REQUEST_URI, padLeft: 0)
    l2.textColor = blue_link_color = FXRGB(34, 52, 83)
    copy_s = 'Left click to copy on clipboard'
    l2.tipText = copy_s
    l2.connect(SEL_LEFTBUTTONPRESS) {|sender, selector, data| Win32::Clipboard.set_data(sender.text)}
    horizontal1 = FXHorizontalFrame.new(vertical0, padding: 0, opts: LAYOUT_CENTER_X)
    l3 = FXLabel.new(horizontal1, "\u2764 To donate:")
    l4 = FXLabel.new(horizontal1, PomodoroTracker::DONATIONS_URI)
    l4.textColor = blue_link_color
    l4.tipText = copy_s
    l4.connect(SEL_LEFTBUTTONPRESS) {|sender, selector, data| Win32::Clipboard.set_data(sender.text)}
    horizontal2 = FXHorizontalFrame.new(vertical0, padding: 0, padTop: 10, opts: LAYOUT_CENTER_X, hSpacing: 0)
    l5 = FXLabel.new(horizontal2, 'Developed by ', padRight: 0, opts: JUSTIFY_CENTER_Y|LAYOUT_CENTER_Y|LAYOUT_FILL_Y)
    l6 = FXLabel.new(horizontal2, 'JorobusLab', padTop: 0)
    l6.textColor = FXRGB(150, 0, 0)
    l6.font = big_font
    horizontal3 = FXHorizontalFrame.new(vertical0, padding: 0, opts: LAYOUT_CENTER_X)
    l7 = FXLabel.new(horizontal3, "Official website:")
    l8 = FXLabel.new(horizontal3, PomodoroTracker::JOROBUSLAB_WEBSITE)
    l8.textColor = blue_link_color
    l8.tipText = copy_s
    l8.connect(SEL_LEFTBUTTONPRESS) {|sender, selector, data| Win32::Clipboard.set_data(sender.text)}
    # painting
    to_paint = [vertical0]
    vertical0.each_child_recursive {|ch| to_paint << ch}
    FXPainter.paint_background(FXColor::VERDE_4, *to_paint)
  end
end

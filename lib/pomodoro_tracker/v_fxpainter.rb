class FXPainter

  RATE_HILITE_COLOR = 106.3
  RATE_BASE_COLOR = 102.1
  RATE_SHADOW_COLOR = 66.6
  RATE_BORDER_COLOR = 41.6

  # @param color [FXColor], @param widgets [FXWindow].
  def self.paint_background(color, *widgets)
    widgets.each do |w|
      w.backColor = color
    end
  end

  # @param red [Fixnum], @param green [Fixnum], @param blue [Fixnum], @param buttons [FXButton].
  def self.paint_buttons(red, green, blue, *buttons)
    buttons.each do |b|
      b.hiliteColor = FXRGB(validate_rgb_value(red, 15), validate_rgb_value(green, 15), validate_rgb_value(blue, 15))
      b.baseColor = FXRGB(validate_rgb_value(red, 5), validate_rgb_value(green, 5), validate_rgb_value(blue, 5))
      b.backColor = FXRGB(red, green, blue)
      b.shadowColor = FXRGB(validate_rgb_value(red, -80), validate_rgb_value(green, -80), validate_rgb_value(blue, -80))
      b.borderColor = FXRGB(validate_rgb_value(red, -140), validate_rgb_value(green, -140), validate_rgb_value(blue, -140))
    end
  end

  # @param color [FXColor], @param widgets [FXWindow].
  def self.paint_borders(color, *widgets)
    widgets.each do |w|
      w.borderColor = color
    end
  end

  private

  # @param pristine [Fixnum], @param add [Fixnum]. @return [Fixnum]. A RGB value must be between 0 and 255. This adds *add* to the pristine returning a valid rgb value, limitating the result if needed.
  def self.validate_rgb_value(pristine, add)
    _result = pristine + add #: Fixnum
    if(_result < 0)
      0
    elsif(_result > 255)
      255
    else
      _result
    end
  end
end
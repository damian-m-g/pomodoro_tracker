# A reward is part of the gamification system.
class Reward

  attr_accessor :available
  attr_reader :purchased, :icon, :short_description, :long_description, :cost

  # @param icon [String]
  # @param short_description [String]
  # @param long_description [String]
  # @param available [TrueClass or FalseClass]
  # @param cost [Fixnum]
  def initialize(icon, short_description, long_description, available, cost)
    @purchased = 0 #: Fixnum
    # under the hood cast redefine_reward() which helps to write less code
    redefine_reward(icon, short_description, long_description, available, cost)
  end

  # @param icon [String]
  # @param short_description [String]
  # @param long_description [String]
  # @param available [TrueClass or FalseClass]
  # @param cost [Fixnum]
  # Supposed to be called when the user edit the reward in any way. The GUI system is responsible for making sure that the short_description doesn't crash with an existing one. That's the only requirement.
  def redefine_reward(icon, short_description, long_description, available, cost)
    @icon = icon #: String
    @short_description = short_description #: String
    @long_description = long_description #: String
    @available = available #: FalseClass or TrueClass
    @cost = cost #: Fixnum
    self
  end

  # @param amount [Fixnum].
  def purchase(amount = 1)
    @purchased += amount
  end
end
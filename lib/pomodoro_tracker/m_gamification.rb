# An instance of this class is a gamification system, compromise/reward style.
class Gamification

  attr_accessor :gold, :rewards_created

  # @param persisted_data [Array]
  # @param pomodoro_tracker [PomodoroTracker]
  def initialize(persisted_data, pomodoro_tracker)
    @pomodoro_tracker = pomodoro_tracker
    if(persisted_data)
      load_persisted_data(persisted_data)
    else
      start_fresh()
    end
  end

  # @return [Array]
  # Returns an Array with the data to persist in time.
  def build_package_to_persist
    package = []
    [@gold, @rewards_created].each do |data|
      package << data
    end
    return(package)
  end

  # Increases the gold stack. It can also reduce it, by passing a negative number.
  def raise_gold(amount)
    @gold += amount
  end

  # @param short_description [String, Reward]
  # @return [TrueClass, FalseClass].
  def exists_reward?(short_description)
    sd = short_description.is_a?(Reward) ? short_description.short_description : short_description #: String
    @rewards_created.has_key?(sd)
  end

  # @param icon [String]
  # @param short_description [String]
  # @param long_description [String]
  # @param available [TrueClass, FalseClass]
  # @param cost [Fixnum]
  # @return [Reward]
  # Creates a new reward.
  def create_reward(icon, short_description, long_description, available, cost)
    @rewards_created[short_description] = Reward.new(icon, short_description, long_description, available, cost)
  end

  # @param reward [String, Reward]
  # @return [TrueClass, FalseClass]
  # Returns true if the item has been purchased, false otherwise.
  def purchase_reward(reward, amount = 1)
    rw = reward.is_a?(Reward) ? reward : @rewards_created[reward] #: Reward
    # see if have gold to buy it
    if(reward.available && (@gold >= reward.cost))
      @gold -= reward.cost
      reward.purchase(amount)
    else
      false
    end
  end

  # @param reward [Reward]
  # @param icon [String]
  # @param short_description [String]
  # @param long_description [String]
  # @param available [TrueClass, FalseClass]
  # @param cost [Fixnum]
  def edit_reward(reward, icon, short_description, long_description, available, cost)
    if(reward.short_description != short_description)
      @rewards_created.delete(reward.short_description)
      @rewards_created[short_description] = reward.redefine_reward(icon, short_description, long_description, available, cost)
    else
      reward.redefine_reward(icon, short_description, long_description, available, cost)
    end
  end

  # @param reward [String, Reward]
  # @return [TrueClass or FalseClass]
  # *reward* is the short description of a reward. Returns true if succesfully deleted the reward, otherwise false.
  def delete_reward(reward)
    sd = reward.is_a?(Reward) ? reward.short_description : reward #: String
    @rewards_created.delete(sd)
  end

  private

  # @param persisted_data [Array]
  # If there's some persisted data, load it into self.
  def load_persisted_data(persisted_data)
    @gold = persisted_data[0]
    @rewards_created = persisted_data[1]
  end

  # If there's not persisted data, initialize some variables to self.
  def start_fresh
    @gold = 0
    # the keys of next hash should be the short description of rewards and the value is the reward itself
    @rewards_created = {}
  end
end
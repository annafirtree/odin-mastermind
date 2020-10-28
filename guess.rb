# frozen_string_literal:true

# GuessInfo class stores information about a guess and handles string-array conversion
# strings are assumed to be 5-letter combos that Pattern takes
# but guesses are stored as 6-index array with a placeholder in index 0 so index matches position 1-5
class Guess
  PLACEHOLDER = '*'

  attr_reader :guess

  def initialize(guess = default_guess, result = [-1, -1])
    @guess = guess.class == Array ? guess : convert_guess_to_useable_array(guess)
    @result = result
  end

  def to_s
    # binding.pry
    without_initial_placeholder = @guess.dup
    without_initial_placeholder.shift
    without_initial_placeholder.join
  end

  def correct_colors
    @result[0]
  end

  def correct_positions
    @result[1]
  end

  def has?(color_or_combo)
    if color_or_combo.length > 1
      color1, color2 = color_or_combo.split('')
      @guess.include?(color1) || @guess.include?(color2)
    else
      @guess.include?(color_or_combo)
    end
  end

  def number_of(color_or_combo)
    if color_or_combo.length > 1
      color1, color2 = color_or_combo.split('')
      @guess.count(color1) + @guess.count(color2)
    else
      @guess.count(color_or_combo)
    end
  end

  def color_at_position(color, position)
    @guess[position] = color
  end

  def available_positions
    available_positions = []
    @guess.each_with_index do |color, position|
      next if position.zero?
      next unless color == PLACEHOLDER

      available_positions << position
    end
    available_positions
  end

  def full?
    @guess.each_with_index do |color, position|
      next if position.zero?
      return false if color == PLACEHOLDER
    end
    true
  end

  private

  def convert_guess_to_useable_array(guess)
    array = guess.split('')
    array.unshift(PLACEHOLDER)
  end

  def default_guess
    Array.new(6, PLACEHOLDER)
  end
end

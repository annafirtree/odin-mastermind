# frozen_string_literal:true

# Pattern class represents a set of colors in a particular order, for the mastermind game
class Pattern
  POSSIBLE_COLORS = %i[red yellow green blue magenta cyan light_white light_red].freeze
  LETTER_CODES = %w[m y g b p c s r].freeze
  PUBLIC_NAMES = %w[marroon yellow green blue purple cyan silver red].freeze
  MAX_LENGTH = 5 # if change this, refactor example in welcome_message in mastermind accordingly

  class << self
    def valid_color_pattern?(colors)
      colors = colors.split('') unless colors.class == Array
      return false unless colors.length == MAX_LENGTH

      colors.each { |color| return false unless valid_color?(color) }
      true
    end

    def full_printable_color_list
      PUBLIC_NAMES.join(', ')
    end

    def printable_letter_code_list
      " \[#{LETTER_CODES.join(' ')}\]"
    end

    private

    def valid_color?(color)
      POSSIBLE_COLORS.include?(color) || LETTER_CODES.include?(color)
    end
  end

  def initialize(color_pattern = create_random)
    @color_pattern = interpret_input(color_pattern)
  end

  def compare(second_instance)
    correct_colors = 0
    correct_places = 0
    POSSIBLE_COLORS.each do |possible_color|
      correct_colors += [second_instance.pattern.count(possible_color), @color_pattern.count(possible_color)].min
    end
    second_instance.pattern.each_with_index do |guessed_color, guessed_placement|
      correct_places += 1 if @color_pattern[guessed_placement] == guessed_color
    end
    [correct_colors, correct_places]
  end

  def draw
    puts ' '
    @color_pattern.each do |color|
      if %i[red blue magenta light_red].include?(color)
        print convert_to_printable(color).colorize(color: :white, background: color)
      else
        print convert_to_printable(color).colorize(background: color)
      end
      print ' '
    end
  end

  protected

  def pattern
    @color_pattern
  end

  private

  def create_random
    new_pattern = []
    (1..MAX_LENGTH).each { new_pattern << POSSIBLE_COLORS.sample }
    new_pattern
  end

  def interpret_input(input)
    return input if input.class == Array && input[0].class == Symbol

    output = input.class == String ? input.split('') : input
    output.map { |character| convert_to_symbol(character) }
  end

  def convert_to_symbol(character)
    POSSIBLE_COLORS[LETTER_CODES.index(character)]
  end

  def convert_to_printable(symbol)
    PUBLIC_NAMES[POSSIBLE_COLORS.index(symbol)]
  end
end

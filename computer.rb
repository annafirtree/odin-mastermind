# frozen_string_literal:true

# Computer class represents the computer as a mastermind guesser
class Computer
  COLOR_SINGLETONS = %w[m y g b p c s r].freeze
  COLOR_COMBOS = %w[my gb pc sr].freeze
  GUESS_1 = 'mmmyy'
  GUESS_2 = 'bgbgb'
  GUESS_3 = 'ppccc'
  NO_POSITION_FOUND = -1
  MAX = Pattern::MAX_LENGTH

  def initialize
    @what_i_know_about_colors = {}
    @what_i_know_about_positions = {}
    @list_of_guesses = []
    COLOR_SINGLETONS.each { |color| @what_i_know_about_colors[color] = Info.new }
    COLOR_COMBOS.each { |color_combo| @what_i_know_about_colors[color_combo] = Info.new }
    (1..MAX).each { |position| @what_i_know_about_positions[position] = %w[m y g b p c s r] }
  end

  def process_result(guess_code, result)
    guess = Guess.new(guess_code, result)
    @list_of_guesses << guess
    initial_combo_max_and_mins(guess) if @list_of_guesses.length < 4 && !enough_info_to_skip_default_guesses?
    update_max_and_mins(guess)
    find_immediately_ruled_out_positions(guess)
    delete_ruled_out_colors_from_all_positions
    2.times { cross_check_info }
  end

  def generate_guess
    if @list_of_guesses.length < 3 && !enough_info_to_skip_default_guesses?
      default_guess
    else
      generate_guess_based_on_info.to_s
    end
  end

  private

  # INFORMATION-PROCESSING METHODS

  def initial_combo_max_and_mins(guess)
    COLOR_COMBOS.each do |color_combo|
      next unless guess.has?(color_combo)

      info = @what_i_know_about_colors.fetch(color_combo)
      info.raise_min_to_at_least(guess.correct_colors)
      info.lower_max_to_no_more_than(guess.correct_colors) if guess.correct_colors < 2
    end
  end

  def update_max_and_mins(guess)
    COLOR_SINGLETONS.each do |color|
      info = @what_i_know_about_colors.fetch(color)
      next unless guess.has?(color)

      info.raise_min_to_at_least(guess.correct_colors - (MAX - guess.number_of(color)))
      info.lower_max_to_no_more_than(guess.correct_colors) if guess.correct_colors < guess.number_of(color)
    end
  end

  def find_immediately_ruled_out_positions(guess)
    return unless guess.correct_positions.zero?

    guess.guess.each_with_index do |color, position|
      next if position.zero?

      delete_color_from_positions(color, [position])
    end
  end

  def delete_ruled_out_colors_from_all_positions
    ruled_out_colors.each { |color| delete_color_from_positions(color, (1..MAX)) }
  end

  def cross_check_info
    if_a_position_has_only_one_color_left_update_that_color_min_to_one
    if_all_colors_known_delete_other_colors_as_possibilities_in_all_positions
    adjust_max_mins_relative_to_each_other
  end

  def if_a_position_has_only_one_color_left_update_that_color_min_to_one
    @what_i_know_about_positions.each_value do |color_possibilities|
      next unless color_possibilities.length == 1

      @what_i_know_about_colors.fetch(color_possibilities[0]).raise_min_to_at_least(1)
    end
  end

  def if_all_colors_known_delete_other_colors_as_possibilities_in_all_positions
    return unless colors_known.length == MAX

    @what_i_know_about_positions.each_value do |color_possibilities|
      color_possibilities.each do |color|
        next if colors_known.include?(color)

        color_possibilities.delete(color)
      end
    end
  end

  def adjust_max_mins_relative_to_each_other
    one_color_min_is_its_combo_min_minus_other_pair_max
    one_color_max_is_its_combo_max_minus_other_pair_min
    combo_is_sum_of_components
    combos_cant_add_up_to_more_than_limit
    single_colors_cant_add_up_to_more_than_limit
  end

  def one_color_min_is_its_combo_min_minus_other_pair_max
    COLOR_COMBOS.each do |color_combo|
      color1, color2, combo = retrieve_color1_color2_combo_infos(color_combo)
      # binding.pry
      color1.raise_min_to_at_least(combo.min - color2.max)
      color2.raise_min_to_at_least(combo.min - color1.max)
    end
  end

  def one_color_max_is_its_combo_max_minus_other_pair_min
    COLOR_COMBOS.each do |color_combo|
      color1, color2, combo = retrieve_color1_color2_combo_infos(color_combo)
      # binding.pry
      color1.lower_max_to_no_more_than(combo.max - color2.min)
      color2.lower_max_to_no_more_than(combo.max - color1.min)
    end
  end

  def combo_is_sum_of_components
    COLOR_COMBOS.each do |color_combo|
      color1, color2, combo = retrieve_color1_color2_combo_infos(color_combo)
      # binding.pry
      combo.raise_min_to_at_least(color1.min + color2.min)
      combo.lower_max_to_no_more_than(color1.max + color2.max)
    end
  end

  def combos_cant_add_up_to_more_than_limit
    COLOR_COMBOS.each do |color_combo|
      combo = @what_i_know_about_colors.fetch(color_combo)
      combo.lower_max_to_no_more_than(MAX - (sum_of_combo_mins - combo.min))
      combo.raise_min_to_at_least(MAX - (sum_of_combo_maxes - combo.max))
    end
  end

  def single_colors_cant_add_up_to_more_than_limit
    COLOR_SINGLETONS.each do |color|
      info = @what_i_know_about_colors.fetch(color)
      highest_possible_max = MAX - (colors_known.length - colors_known.count(color))
      info.lower_max_to_no_more_than(highest_possible_max)
    end
  end

  # GUESS-GENERATING METHODS

  def enough_info_to_skip_default_guesses?
    sum_of_combo_mins == MAX
  end

  def default_guess
    case @list_of_guesses.length
    when 0
      GUESS_1
    when 1
      GUESS_2
    when 2
      GUESS_3
    end
  end

  def generate_guess_based_on_info
    unless already_made_all_one_color_guess?
      useful_or_not, guess = check_if_useful_to_do_all_one_color_guess
      return guess if useful_or_not
    end
    generate_more_complicated_guess
  end

  def generate_more_complicated_guess
    guess = Guess.new
    while contradicts_previous_guess_results?(guess)
      guess = fill_in_known_positions
      guess = guess_generating_while_loop(guess) { |new_guess| put_known_colors_in_available_position!(new_guess) }
      guess = guess_generating_while_loop(guess) { |new_guess| fill_empty_slots_based_on_color_combos!(new_guess) }
    end
    guess
  end

  def check_if_useful_to_do_all_one_color_guess
    return [false, 'error'] if colors_known.length > 3

    COLOR_SINGLETONS.each do |color|
      @list_of_guesses.each do |guess|
        next unless guess.number_of(color) == 2 &&
                    guess.correct_colors > 2 &&
                    @what_i_know_about_colors.fetch(color).max > 2

        return [true, Guess.new(Array.new(MAX + 1, color))]
      end
    end
    [false, 'error']
  end

  def fill_in_known_positions
    guess = Guess.new
    @what_i_know_about_positions.each do |position, color_possibilities|
      guess.color_at_position(color_possibilities[0], position) if color_possibilities.length == 1
    end
    guess
  end

  def guess_generating_while_loop(guess)
    keep_going = true
    new_guess = Guess.new
    while keep_going
      new_guess = Guess.new(guess.guess.dup)
      keep_going = yield(new_guess)
    end
    new_guess
  end

  def put_known_colors_in_available_position!(new_guess)
    colors_known.each do |color|
      position = new_guess.available_positions.sample
      return true unless color_can_be_in_position?(color, position)

      new_guess.color_at_position(color, position)
    end
    false
  end

  def fill_empty_slots_based_on_color_combos!(new_guess)
    keep_going = false
    known_combos_plus_random_selection_of_available_combos(new_guess).each do |combo|
      color = pick_random_color_from_combo_but_check_if_its_ruled_out(combo)
      position = new_guess.available_positions.sample
      color_can_be_in_position?(color, position) ? new_guess.color_at_position(color, position) : keep_going = true
    end
    keep_going
  end

  def known_combos_plus_random_selection_of_available_combos(guess)
    useable_combos = color_combos_known
    COLOR_COMBOS.each do |combo|
      guess.number_of(combo).times do
        useable_combos.delete_at(useable_combos.index(combo))
      end
    end
    (guess.available_positions.length - useable_combos.length).times { useable_combos << find_random_available_combo }
    useable_combos
  end

  def contradicts_previous_guess_results?(tentative_guess)
    return true unless tentative_guess.available_positions.length.zero?

    tentative_pattern = Pattern.new(tentative_guess.to_s)
    @list_of_guesses.each do |guess|
      pattern = Pattern.new(guess.to_s)
      return true unless pattern.compare(tentative_pattern) == [guess.correct_colors, guess.correct_positions]
    end
    false
  end

  # HASH MANAGEMENT METHODS

  def delete_color_from_positions(color, positions)
    positions.each do |position|
      @what_i_know_about_positions.fetch(position).delete(color)
    end
  end

  def sum_of_combo_maxes
    sum = 0
    COLOR_COMBOS.each { |combo| sum += @what_i_know_about_colors.fetch(combo).max }
    sum
  end

  def sum_of_combo_mins
    sum = 0
    COLOR_COMBOS.each { |combo| sum += @what_i_know_about_colors.fetch(combo).min }
    sum
  end

  def color_can_be_in_position?(color, position)
    @what_i_know_about_positions.fetch(position).include?(color)
  end

  def ruled_out_colors
    COLOR_SINGLETONS.select { |color| @what_i_know_about_colors.fetch(color).max.zero? }
  end

  def colors_known
    colors_known = []
    COLOR_SINGLETONS.each do |color|
      @what_i_know_about_colors.fetch(color).min.times { colors_known << color }
    end
    colors_known
  end

  def color_combos_known
    color_combos_known = []
    COLOR_COMBOS.each do |color_combo|
      @what_i_know_about_colors.fetch(color_combo).min.times { color_combos_known << color_combo }
    end
    color_combos_known
  end

  def find_random_available_combo
    COLOR_COMBOS.select { |combo| @what_i_know_about_colors.fetch(combo).max.positive? }.sample
  end

  def pick_random_color_from_combo_but_check_if_its_ruled_out(combo)
    color = combo.split('').sample
    color = combo.split('').reject { |a| a == color }[0] if @what_i_know_about_colors.fetch(color).max.zero?
    color
  end

  def retrieve_color1_color2_combo_infos(combo)
    color1, color2 = combo.split('')
    info_combo = @what_i_know_about_colors.fetch(combo)
    info_color1 = @what_i_know_about_colors.fetch(color1)
    info_color2 = @what_i_know_about_colors.fetch(color2)
    [info_color1, info_color2, info_combo]
  end

  def already_made_all_one_color_guess?
    @list_of_guesses.each do |guess|
      all_one_color = true
      first_color = guess.guess[1]
      guess.guess.each_with_index do |color, position|
        all_one_color = false unless color == first_color || position.zero?
      end
      return true if all_one_color
    end
    false
  end
end

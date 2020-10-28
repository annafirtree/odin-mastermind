# frozen_string_literal:true

require 'colorize'
require './pattern'
require './computer'
require './guess'
require './info'

MAX_TRIES = 12
MASTERMIND = 'm'
GUESSER = 'g'

def play_game
  puts welcome_explanation
  mastermind_or_guesser = ask_for_mastermind_or_guesser
  correct_pattern = correct_pattern(mastermind_or_guesser)
  did_guesser_win = loop_through_guesses(correct_pattern, mastermind_or_guesser)
  handle_end(did_guesser_win, correct_pattern, mastermind_or_guesser)
end

def welcome_explanation
  "\n Welcome to Mastermind! \n
  In this game, a mastermind chooses a pattern of #{Pattern::MAX_LENGTH} colors,
  and a guesser has #{MAX_TRIES} tries to guess it.
  To represent a pattern, pick #{Pattern::MAX_LENGTH} colors by writing their initials in a row.
  The color options are #{Pattern.full_printable_color_list}.
  For example, enter \'rrybb\' to select the pattern \'red red yellow blue blue\'. \n\n"
end

def ask_for_mastermind_or_guesser
  keep_going = true
  puts 'Would you like to be the mastermind (who chooses the colors) or be the guesser?'
  while keep_going
    puts "Enter #{MASTERMIND} for mastermind or #{GUESSER} for guesser."
    input = gets.chomp
    keep_going = false if [MASTERMIND, GUESSER].include?(input)
  end
  input
end

def loop_through_guesses(correct_pattern, mastermind_or_guesser)
  did_guesser_win = false
  computer = Computer.new if mastermind_or_guesser == MASTERMIND
  (1..MAX_TRIES).each do |tries|
    did_guesser_win = play_a_turn(correct_pattern, tries, mastermind_or_guesser, computer)
    break if did_guesser_win
  end
  did_guesser_win
end

def correct_pattern(mastermind_or_guesser)
  return Pattern.new if mastermind_or_guesser == GUESSER

  ask_for_pattern
end

def play_a_turn(correct_pattern, tries, mastermind_or_guesser, computer = 0)
  if mastermind_or_guesser == GUESSER
    player_guess(correct_pattern, tries)
  else
    computer_guess(correct_pattern, computer, tries)
  end
end

def player_guess(correct_pattern, tries)
  guess = ask_for_pattern
  result = correct_pattern.compare(guess)
  print_result(guess, result, tries, GUESSER)
  did_guesser_win(result)
end

def ask_for_pattern
  keep_going = true
  while keep_going
    puts "Choose a pattern. Pick #{Pattern::MAX_LENGTH} from #{Pattern.printable_letter_code_list}, like \'rrybb\'."
    input = gets.chomp
    keep_going = false if Pattern.valid_color_pattern?(input)
  end
  Pattern.new(input)
end

def print_result(pattern, result, tries, mastermind_or_guesser)
  puts 'The computer guesses:' if mastermind_or_guesser == MASTERMIND
  pattern.draw
  puts "#{result[0]} correct colors, #{result[1]} in the right place. \n\n"
  return if result[1] == Pattern::MAX_LENGTH

  print mastermind_or_guesser == MASTERMIND ? 'The computer has ' : 'You have '
  print "#{number_of_tries_left(tries)} guesses left. \n\n"
end

def did_guesser_win(result)
  result[1] == Pattern::MAX_LENGTH
end

def handle_end(did_guesser_win, correct_pattern, mastermind_or_guesser)
  if did_guesser_win && mastermind_or_guesser == GUESSER
    puts "\n Congrats! You won. \n\n"
  elsif mastermind_or_guesser == GUESSER
    puts 'Sorry. You are out of tries. The correct answer was:'
    correct_pattern.draw
  elsif did_guesser_win
    puts "\n The computer is smarter than you and guessed your arrangement. \n\n"
  else
    puts "\n This miserable AI failed to guess your pattern. You are so smart!\n\n"
  end
end

def number_of_tries_left(tries)
  MAX_TRIES - tries
end

def computer_guess(correct_pattern, computer, tries)
  computers_guess = computer.generate_guess
  result = correct_pattern.compare(Pattern.new(computers_guess))
  print_result(Pattern.new(computers_guess), result, tries, MASTERMIND)
  computer.process_result(computers_guess, result)
  did_guesser_win(result)
end

play_game

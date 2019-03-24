require_relative 'hangman_display.rb'
require_relative 'player.rb'
require 'json'

class Game
  attr_accessor :hangman, :valid_answer, :secret_word, :guessed_word, :guessed_letter, :player, :incorrect_guessed_letters
  attr_accessor :filename, :incorrect_guess_count

  INVALIDCHARACTERS = [ "\nThe guessed letter is invalid.\n\n", "Please guess again.\n" ]
  MULTIPLEGUESSEDLETTERS = [ "\nThe guessed letter has to be only 1 letter.\n\n", "Please guess again.\n" ]

  def initialize(incorrect_guessed_letters, hangman=nil, secret_word=nil, guessed_word=nil, filename=nil)
    self.hangman = hangman
    self.hangman ||= HangmanDisplay.new
    self.player = Player.new
    self.incorrect_guessed_letters = incorrect_guessed_letters
    self.secret_word = secret_word
    self.guessed_word = guessed_word
    self.filename = filename
  end

  def to_json
    JSON.dump({
                :hangman_display => @hangman.display,
                :incorrect_guessed_letters => @incorrect_guessed_letters,
                :incorrect_guess_count => @hangman.incorrect_guess_count,
                :secret_word => @secret_word,
                :guessed_word => @guessed_word,
                :filename => @filename
             })
  end

  def from_json(string)
    data = JSON.load string
    self.update_instance_variables(data['hangman_display'], data['incorrect_guessed_letters'], data['incorrect_guess_count'],
                                   data['secret_word'], data['guessed_word'], data['filename'])
  end

  def update_instance_variables(hangman_display, incorrect_guessed_letters, incorrect_guess_count, secret_word, guessed_word, filename)
    self.hangman.display = hangman_display
    self.incorrect_guessed_letters = incorrect_guessed_letters
    self.hangman.incorrect_guess_count = incorrect_guess_count
    self.secret_word = secret_word
    self.guessed_word = guessed_word
    self.filename = filename
  end

  def generate_secret_word
    dictionary = File.open("5desk.txt", "r") { |f| f.read }
    dictionary = dictionary.split("\r\n")
                           .select! { |word| word.length >= 5 && !(/[A-Z]/ =~ word) }
    
    self.secret_word = dictionary[rand(dictionary.length - 1)].downcase
    puts "The secret word has been created."
    secret_word
  end

  def introduction
    File.open("introduction.txt","r") { |f| puts f.read }
    ask_question("\nDo you want to play? (y/n)", start_game, leave_game)
  end

  def invalid_characters?(answer)
    /[\d\!\@\#\$\%\^\&\*\(\)\-\=\+\/\.\,\:\;\'\"\|\\\{\}\[\]\s]/ =~ answer
  end

  def valid_answer
    self.valid_answer = lambda { |valid_answer| valid_answer == answer }
  end

  def ask_question(question, yes_answer, no_answer)
    loop { determine_valid_answer(question, yes_answer, no_answer) }
  end

  def determine_valid_answer(question, yes_answer, no_answer)
    puts question
    answer = gets.chomp.downcase

    yes_answer.call if ["y", "yes"].one?(answer, &valid_answer)
    no_answer.call if ["n", "no"].one?(answer, &valid_answer)
    puts "\nInvalid characters detected." if invalid_characters?(answer)
    puts "\nYou didn't select an appropriate response." if ["y", "n", "yes", "no"].none?(answer, &valid_answer)
    raise StopIteration if ["y", "n", "yes", "no"].any?(answer, &valid_answer)
  end

  def start_game
    start_game = Proc.new do
      puts "\nLet's play!\n\n"
      self.filename = nil
      self.play
    end
  end

  def leave_game
    leave_game = Proc.new do
      puts "\nGoodbye."
      exit
    end
  end

  def save_game
    ask_question("\nBefore you begin the round, do you want to save the game? (y/n)", save_game_to_file, continue_play)
  end

  def save_game_to_file
    save_game_to_file = Proc.new do
      Dir.mkdir "saved_games" unless Dir.exists? "saved_games"
      puts "\nPlease name your saved game:"
      game_name = gets.chomp
      self.filename ||= "saved_games/#{game_name}.txt"
      File.open(filename, "w") { |file| file.puts self.to_json }

      puts "\nYou have saved the game."
    end
  end

  def load_game
    ask_question("\nDo you want to load and play a saved game instead? (y/n)", select_game_to_load, continue_play)
  end

  def determine_game_number_valid(game_number, saved_games_dir)
    puts "\nNumber has to be a whole number.\n\nNumber invalid.\n\n" if game_number.nil?
    determine_game_to_load_exist(game_number, saved_games_dir) if game_number
  end

  def load_game_file(game_number, saved_games_dir)
    loaded_game = saved_games_dir[game_number[0].to_i - 1]
    File.open(loaded_game, "r") { |f| self.from_json(f) }
    loaded_game.gsub!(/saved_games\//, "")
    puts "\n'#{loaded_game}' has been loaded.\n\n"
  end

  def determine_game_to_load_exist(game_number, saved_games_dir)
    load_game_file(game_number, saved_games_dir) if game_number[0].to_i <= saved_games_dir.length
    puts "\nSave game doesn't exist. Please pick again\n\n" if game_number[0].to_i > saved_games_dir.length
    raise StopIteration if game_number[0].to_i <= saved_games_dir.length
  end

  def print_save_games
    saved_games_dir = Dir.glob("saved_games/*")
    saved_games_dir.each_with_index { |game, idx| puts "#{idx + 1}- #{game}" }
    saved_games_dir
  end

  def choose_game_number_to_load
    puts "\nPlease select the number of the game you would like to load."
    game_number = gets.chomp.match(/^[^0]?[1-9]\d*/)
  end

  def select_game_to_load
    select_game_to_load = Proc.new do
      loop do
        saved_games_dir = print_save_games
        game_number = choose_game_number_to_load
        determine_game_number_valid(game_number, saved_games_dir)
      end
    end
  end

  def continue_play
    continue_play = Proc.new { puts "\nContinue play." }
  end

  def play
    self.generate_secret_word
    create_guessed_word_display
    load_game unless Dir.glob("saved_games/*").empty?
    loop do
      puts hangman.display
      save_game
      round_of_guesses
      game_over?
    end
    ask_question("\nDo you want to play again? (y/n)", start_game, leave_game)
  end

  def create_guessed_word_display
    self.guessed_word = secret_word.split("").map { |letter| "_"}
    puts guessed_word.join(" ")
  end

  def round_of_guesses
    ask_guess_letter
    determine_right_and_wrong_answers
  end

  def ask_guess_letter
    loop do
      puts "\nPlease guess a letter of the secret word."
      puts "\n" + guessed_word.join(" ")
      self.player.guessed_letter = gets.chomp.downcase
      puts "Guessed letter is #{player.guessed_letter}"
      ensure_valid_guess(player.guessed_letter)
    end
    guessed_letter
  end

  def determine_right_and_wrong_answers
    if secret_word.split("").any?(&word_contains_guessed_letter)
      find_and_update_position_of_guessed_letter
      puts "\nThe secret word contains \"#{player.guessed_letter}\"."
      puts "\nIncorrect Letters: #{incorrect_guessed_letters}"
    elsif secret_word.split("").none?(&word_contains_guessed_letter)
      list_and_count_wrong_guesses
      puts "\nThe secret word doesn't contain \"#{player.guessed_letter}\"."
      puts "\nIncorrect Letters: #{incorrect_guessed_letters}"
    end
  end
  
  def ensure_valid_guess(guessed_letter)
    puts INVALIDCHARACTERS if invalid_characters?(guessed_letter) || guessed_letter.empty?
    puts MULTIPLEGUESSEDLETTERS if guessed_letter.length > 1
    raise StopIteration unless invalid_characters?(guessed_letter) || guessed_letter.empty? || guessed_letter.length > 1
  end

  def word_contains_guessed_letter
    word_contains_guessed_letter = lambda { |letter| letter == player.guessed_letter }
  end

  def find_and_update_position_of_guessed_letter
    index_of_correct_guess = secret_word.split("").each_index.select { |i| secret_word[i] == player.guessed_letter }
    index_of_correct_guess.each { |num| guessed_word[num] = player.guessed_letter }
    puts "\n" + guessed_word.join(" ")
  end

  def list_and_count_wrong_guesses
    (self.incorrect_guessed_letters << player.guessed_letter).uniq!
    self.hangman.incorrect_guess_count += 1
    self.hangman.display_incorrect_guesses(hangman.incorrect_guess_count, hangman.display)
    puts "\n" + guessed_word.join(" ")
  end

  def game_over?
    puts victory_message if victory?
    puts defeat_message if defeat?
  end
  
  def victory?
    guessed_word.none? { |letter| letter == "_"}
  end
  
  def defeat?
    hangman.incorrect_guess_count == 6
  end
  
  def victory_message
    puts "You have guessed all the letters of the choosen word! YOU WIN!!!"
    raise StopIteration
  end
  
  def defeat_message
    puts "\nYou have failed to guess the correct word in time."
    puts "\nThe secret word is '#{secret_word}'"
    puts "\nThe man has been hung!"
    puts "\nYOU LOSE!"
    raise StopIteration
  end
end

game = Game.new([])
game.introduction

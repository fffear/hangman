class HangmanDisplay
  attr_accessor :display, :incorrect_guess_count

  HANGMANDISPLAY = [ "+-----+".rjust(20, " "),
                     "|     |".rjust(20, " "),
                     "      |".rjust(20, " "),
                     "      |".rjust(20, " "),
                     "      |".rjust(20, " "),
                     "      |".rjust(20, " "),
                     "      |".rjust(20, " "),
                     "      |".rjust(20, " "),
                     "============".rjust(25, " ")
                   ]
  
  def initialize
    self.update_hangman_display(HANGMANDISPLAY)
    self.incorrect_guess_count = 0
  end

  def update_hangman_display(hangman_display)
    self.display = hangman_display.each_with_object([]) { |line, array| array << line }
  end

  def display_incorrect_guesses(incorrect_guess_count, hangman_display)
    case incorrect_guess_count
    when 1 then hangman_display[2] = "O     |".rjust(20, " ")
    when 2 then hangman_display[3] = "|     |".rjust(20, " ")
    when 3 then hangman_display[3] = "/|     |".rjust(20, " ")
    when 4 then hangman_display[3] = "/|\\    |".rjust(20, " ")
    when 5 then hangman_display[4] = "/      |".rjust(20, " ")
    when 6 then hangman_display[4] = "/ \\    |".rjust(20, " ")
    end
  end
end

#display = HangmanDisplay.new

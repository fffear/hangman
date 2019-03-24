class Player
  attr_accessor :guessed_letter

  def guess_letter
    self.guessed_letter = gets.chomp.downcase
  end
end
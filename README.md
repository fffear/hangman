# Hangman Game
This is a Hangman game in Ruby, as part of the 'File I/O and Serialization' project in TheOdinProject Intermediate Ruby Course.

## Run the Game

To run the game, please ensure that you have Ruby installed on your machine.
Navigate into the root folder which holds the `lib` folder, and type `ruby lib/game.rb` in the command line to start the game.

## Home Screen Game

Upon entering the game, the below should appear, giving a basic description of the game.

![Introduction](./screenshots/introduction.png)

Enter 'y' or 'n' to decide if you would like to play the game.

![Play_game](./screenshots/play_game.png)

## Load Saved Game

You will have the option of loading a saved game to play, if you have saved a game previously.

![Load_saved_game](./screenshots/load_saved_game.png)

## Save Current Game

Before the beginning of each turn, you will also have the option of saving the game.

![Save_current_game](./screenshots/save_game.png)

## Guess Letters

When letters of the secret word have been guessed correctly, the position of the letters will be displayed.

![Guess_letter_correct](./screenshots/guess_letter_correct.png)

If you guessed a letter incorrectly, the incorrect letter you have guessed will be added to a list of wrong letters previously guessed. Additionally, the man will be 1 step closer to being hung!

![Guess_letter_wrong](./screenshots/guess_letter_wrong.png)

## Game Results

If you fail to guess the secret word before the man is hung, you lose.

![Lose_game}(./screenshots/lose_game.png)

Otherwise, if you can guess the secret word before the man is hung, you win.

![Win_game](./screenshots/win_game.png)

## Restart Game

An option to restart the game with a different word is available, so you can play as many times as you like.

![Restart_game](./screenshots/restart_game.png)

## Helpful Links

- [The Odin Project](https://www.theodinproject.com/courses/ruby-programming/lessons/file-i-o-and-serialization)
- [Wikipedia description on the game](https://en.wikipedia.org/wiki/Hangman_(game))
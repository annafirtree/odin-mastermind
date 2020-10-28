This is Anna LaVergne's implementation of the Odin Project's [Mastermind assignment](https://www.theodinproject.com/lessons/mastermind).

## Mastermind

In this game, one person chooses a set of colors, and the other person makes guesses based on feedback. In this command-line version of the game, one of the players is the computer; it is the user's choice whether to play against the computer as the mastermind or as the guesser.

## Not Your Ordinary Mastermind

I am a fan of Simon Tatham's puzzle app (free and ad-free, available on [Android](https://play.google.com/store/apps/details?id=name.boyle.chris.sgtpuzzles&hl=en_US&gl=US) or [Apple](https://apps.apple.com/app/id622220631)), which implements both the ordinary four-color Mastermind game and a five-color option. For this challenge, I decided to make my version follow the latter. So the mastermind picks five colors from a set of eight (instead of four from a set of six), and the guesser has twelve chances (instead of ten) to guess the pattern.

## How To Play

[Play it here in a browser](https://Mastermind.annafirtree.repl.run).

If you clone this and play it on your own device, it's important to note that this game relies on the Ruby gem [colorize](https://github.com/fazibear/colorize). Install this gem before trying to play it.

## The Challenges of Building an AI

Although the project allowed simpler algorithms, I decided to challenge myself by making the computer implement the strategies I myself use while guessing. 

This was the hardest part of the project: turning very specific thoughts like "red-red-red-yellow-yellow has two colors  correct, but all-yellow has none, so there must be two reds" into a structure of generalized methods and variables that the computer could use. At this stage, I ignored all rubocop warnings, making no attempt to name things well, follow best practices, or keep my code neat and orderly, focusing instead on simply getting rough versions of my thoughts down.

Later, when I had my AI going and it had completed a couple games but was still glitchy, I took a step back and looked at what I was asking my code to do. I re-factored it into better classes and methods, organizing my thinking, and then proceeded to finish debugging.

There is more improvement that could happen - the Guess and Pattern classes have way too much conceptual overlap and should be merged, the Computer file that handles the AI-guesser is too long and might be shortened if another class were to handle the two hashes that the computer uses to store what is known - but those changes would have no appreciable difference on the functioning of the program, so that will be a project for the future, perhaps.
#!/bin/bash
echo -e "\n\t~~~ Welcome to Guessing number game ~~~\n"

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# number to guess
NUMBER=$((1 + $RANDOM % 1000))

# user handle
echo "Enter your username:"
read USERNAME
USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$USERNAME'")

if [[ -z $USER_ID ]]
then
  USER=$($PSQL "INSERT INTO users (name) VALUES ('$USERNAME')")
  if [[ $USER=="INSERTED 0 1" ]]
  then
    echo "Welcome, $USERNAME! It looks like this is your first time here."
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$USERNAME'")
  fi
else
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id=$USER_ID")
  BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games WHERE user_id=$USER_ID")
  if [[ -z $BEST_GAME ]]
  then
    BEST_GAME="?"
  fi
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# game
INPUT(){
  read GUESS

  if ! [[ $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    INPUT
  else
    if [ $GUESS -lt $NUMBER ]
    then
      echo "It's higher than that, guess again:"
      TRIES=$((TRIES+1))
      INPUT
    elif [ $GUESS -gt $NUMBER ]
    then
     echo "It's lower than that, guess again:"
      TRIES=$((TRIES+1))
      INPUT
    else
      echo "You guessed it in $TRIES tries. The secret number was $NUMBER. Nice job!"
      GAME_ADD=$($PSQL "INSERT INTO games (guesses,user_id) VALUES ($TRIES,$USER_ID)")
    fi
  fi
}

echo "Guess the secret number between 1 and 1000:"
TRIES=1
INPUT

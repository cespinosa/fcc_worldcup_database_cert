#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE TABLE games, teams")
arrTeams=()
while IFS=, read -r y r w o wg og
do
  if [[ ! ${arrTeams[@]} =~ $w ]]
  then
    arrTeams+=("$w")  
  fi
  if [[ ! ${arrTeams[@]} =~ $o ]]
  then
    arrTeams+=("$o")  
  fi
done < <(tail -n +2 games.csv)
for team in "${arrTeams[@]}"
do
	echo $($PSQL "INSERT INTO teams(name) VALUES('$team')")
done
while IFS=, read -r y r w o wg og
do
  winnerID=$($PSQL "SELECT team_id FROM teams WHERE name='$w'")
  opID=$($PSQL "SELECT team_id FROM teams WHERE name='$o'") 
  echo $($PSQL "INSERT INTO games(year,round,winner_id,opponent_id,winner_goals,opponent_goals) VALUES($y,'$r',$winnerID,$opID,$wg,$og)")
done < <(tail -n +2 games.csv)

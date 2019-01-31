#!/bin/bash

# Run grading script a given number of times, sending grade outputs into 
# grades.txt and returns lowest score in the shell

printf "Enter path to executable file: "
read file
if [ ! -f $file ]; then
  printf "File not found\n"
  exit 1
fi

if [ ! -d "gradeScriptOutput" ]; then
  mkdir gradeScriptOutput
fi

# checks if grades.txt already exists
if [ -f "grades.txt" ]; then
  printf "grades.txt exists. Would you like to overwrite? (y/n): "
  read overwrite
  if [ "$overwrite" = "y" ]; then
    rm grades.txt
  else
    printf "Exiting to preserve grades.txt\n"
    exit 1
  fi
fi

cp $file gradeScript

mv gradeScript gradeScriptOutput
cd gradeScriptOutput
if [ -f "grades.txt" ]; then
  rm grades.txt
fi
printf "Enter number of times to run: "
read numTimes
if [ $numTimes -lt 1 ]; then
  printf "Can't execute less than 1 time\n"
  exit 1
fi

# code for progress bar from mywiki BashFAQ/044

bar="=============================="
barlength=${#bar}
printf "\nExecuting grading script...\n"
# run grading executable "gradeScript" numTimes and save output to grades.txt
for (( x = 0; x < numTimes; x++ ))
do
  gradeScript >> grades.txt
  n=$(((x + 1)*barlength / numTimes))
  printf "\r[%-${barlength}s] #%d" "${bar:0:n}" $((x+1))
done

numLines=$(grep -c $ grades.txt)

# find lowest score of all attempts
curMin=1000
curMinLine=0

# possibility to overflow lineNumber if you run gradeScript an obscene amount of times
lineNumber=1
printf "\n\nSearching for lowest score...\n"
while read line
do
  # parse line for score if it includes string
  if [[ $line =~ 'Your projected total score for this assignment: ' ]]; then
    score=${line:48:50}
    if [ $score -lt $curMin ]; then
      curMin=$score
      curMinLine=$lineNumber
    fi
    n=$(((lineNumber + 1) *barlength / numLines))
    printf "\r[%-${barlength}s] #%d" "${bar:0:n}" $((lineNumber+1))
  fi
  ((lineNumber++))
done < grades.txt

mv grades.txt ../grades.txt

printf "\n\n# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #\n"
printf "Anything generated by the grade script will be located in 'gradeScriptOutput'\n"
printf "# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #\n\n"
printf "Lowest grade is: %d at line %d of grades.txt\n" $curMin $curMinLine

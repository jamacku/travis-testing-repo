while read -r DATA; do 
  OLD=$DATA
done < <(git rev-list --all --max-count=2)

# get paths to changed shell files
# git log --name-only --oneline --max-count=2

#Check for New commit
shellcheck "$PWD"/script.sh

if [ $? -eq 0 ]; then
  echo "NEW BUILD is OK!"
else
  echo "NEW BUILD is WRONG!"
fi

#Check for prev commit
git checkout "$OLD"
shellcheck "$PWD"/script.sh

if [ $? -eq 0 ]; then
  echo "OLD BUILD is OK!"
else
  echo "OLD BUILD is WRONG!"
fi

#Pass final exit status for build
#exit 

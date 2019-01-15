while read -r DATA; do 
  OLD=$DATA
done < <(git rev-list --all --max-count=2)

echo "$OLD"

# get paths to changed shell files

#Check for New commit
shellcheck "$PWD"/script.sh

if [ $? -eq 0 ]; then
  echo "NEW BUILD is OK!"
else
  echo "NEW BUIL is WRONG!"
fi

#Check for prev commit
git checkout "$OLD"
shellcheck "$PWD"/script.sh

if [ $? -eq 0 ]; then
  echo "NEW BUILD is OK!"
else
  echo "NEW BUIL is WRONG!"
fi

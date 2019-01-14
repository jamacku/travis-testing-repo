while read DATA; do 
  OLD=$DATA
done < <(git rev-list --all --max-count=2)

echo $OLD

# get paths to changed shell files

#Check for New commit
shellcheck $PWD/script.sh

#Check for prev commit
git checkout $OLD
shellcheck $PWD/script.sh


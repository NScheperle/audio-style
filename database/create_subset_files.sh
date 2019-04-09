rm ./database/balanced_training_subset.tsv
rm ./database/evaluation_subset.tsv

while read class; do
	ID=`mysql -s -e "select ID from AudioSet.Ontology where Name = trim('${class}')"`
	echo $class: $ID
	count=`mysql -s -N -e "select count(*) from AudioSet.Balanced_Train where positive_labels like '%${ID}%'"`
	echo Balanced Training: $count
	count=`mysql -s -N -e "select count(*) from AudioSet.Evaluation where positive_labels like '%${ID}%'"`
	echo Evaluation: $count
	
	query="select YouTubeID as YTID, 
	cast(start_seconds as decimal(5,2)) as start_seconds, cast(end_seconds as decimal(5,2)) as end_seconds, 
	positive_labels from AudioSet.Balanced_Train 
	where find_in_set(trim('${ID}'), positive_labels)"
	
	mysql -s -e "$query" >> ./database/balanced_training_subset.tsv
	
	query="select YouTubeID as YTID, 
	cast(start_seconds as decimal(5,2)) as start_seconds, cast(end_seconds as decimal(5,2)) as end_seconds, 
	positive_labels from AudioSet.Evaluation 
	where find_in_set(trim('${ID}'), positive_labels)"

	mysql -s -e "$query" >> ./database/evaluation_subset.tsv
done < ./database/training_classes.csv

echo Total:
echo Training:
wc -l ./database/balanced_training_subset.tsv
echo Evaluation:
wc -l ./database/evaluation_subset.tsv
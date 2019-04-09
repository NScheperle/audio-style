# download label reference csv's and ontology json
function download_data {
	rm ./database/balanced_train_segments.csv
	wget -P ./database http://storage.googleapis.com/us_audioset/youtube_corpus/v1/csv/balanced_train_segments.csv

	rm ./database/eval_segments.csv
	wget -P ./database http://storage.googleapis.com/us_audioset/youtube_corpus/v1/csv/eval_segments.csv

	rm ./database/ontology.json
	wget -P ./database https://raw.githubusercontent.com/audioset/ontology/master/ontology.json
}

# create database 
function create_database {
	mysql << EOF
	create database AudioSet;

	grant all privileges on *.* to 'nes31'@'localhost';

	grant reload, process on *.* to 'vcm'@'localhost';

	grant all privileges on AudioSet.* to 'jm622'@'localhost';

	grant all privileges on AudioSet.* to 'bl199'@'localhost';

	grant all privileges on AudioSet.* to 'mxd'@'localhost';

	grant all privileges on AudioSet.* to 'jh608'@'localhost';
EOF
	
}

# create label reference tables for training and eval as well as ontology
function create_tables {
echo Creating tables...
mysql << EOF
delete from AudioSet.Balanced_Train;
drop table AudioSet.Balanced_Train;
create table AudioSet.Balanced_Train 
	(
	YouTubeID VARCHAR(11),
	start_seconds FLOAT,
	end_seconds FLOAT,
	positive_labels VARCHAR(100),
	primary key(YouTubeID)
	);

delete from AudioSet.Evaluation;
drop table AudioSet.Evaluation;
create table AudioSet.Evaluation 
	(
	YouTubeID VARCHAR(11),
	start_seconds FLOAT,
	end_seconds FLOAT,
	positive_labels VARCHAR(100),
	primary key(YouTubeID)
	);

delete from AudioSet.Ontology;
drop table AudioSet.Ontology;
create table AudioSet.Ontology
	(
	ID VARCHAR(20),
	Name VARCHAR(50),
	Description VARCHAR(500),
	Citation_uri VARCHAR(64),
	/*Positive_Examples VARCHAR(500),*/
	Child_IDs VARCHAR(500),
	/*Restrictions VARCHAR(100),*/
	primary key(ID)
	);
EOF
}

# load downloaded data to database
function load_data {
echo Loading data to Balanced_Train and Evaluation...
mysql --local-infile <<EOF
SET GLOBAL local_infile = 1;
load data local infile './database/balanced_train_segments.csv' 
	into table AudioSet.Balanced_Train 
	fields terminated by ', ' optionally enclosed by '"'
	ignore 3 lines
	;

load data local infile './database/eval_segments.csv' 
	into table AudioSet.Evaluation 
	fields terminated by ', ' optionally enclosed by '"'
	ignore 3 lines
	;
EOF

echo Loading data to Ontology...
# load data to ontology from JSON using python
python ./database/parse_ontology_json.py
}

download_data
#create_database
create_tables
load_data


